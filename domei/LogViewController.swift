//
//  LogViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseDatabase
import FirebaseAuth

class LogViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var firstView : Bool = true
    var selectedDate : Date = Date()
    var logData : [String :[TimerLog]] = [:]
    var calendarHeader : [String] = []
    var allData : [[TimerLog]] = []
    let dateFormatter = DateFormatter()
    let currentCalendar : Calendar = Calendar.current
    var startDate : Date = Date()
    var count = 0
    
    override func viewDidAppear(_ animated: Bool) {
        if firstView {
            calendarView.deselectAllDates()
            calendarView.selectDates([Date()])
            
            jumpToDate(date: Date())
        }
        firstView = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView") // Registering your cell is manditory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        dateFormatter.dateFormat = "YYYY/MM/dd"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // 365 days since startDate
        startDate = Util.getStartDate()
        let endDate = Util.getEndDate()
        
        var incrementDate = startDate
        while incrementDate.compare(endDate) != ComparisonResult.orderedSame {
            let key = dateFormatter.string(from: incrementDate)
            calendarHeader.append(key)
            
            let logs : [TimerLog] = []
            allData.append(logs)
            
            incrementDate = currentCalendar.date(byAdding: .day, value: 1, to: incrementDate)!
        }
        
        // get data from firebase
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("timerLogs").queryOrdered(byChild: "timeStamp").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            let log = TimerLog()
            let val = snapshot.value as! NSDictionary
            log.timeStamp = val["timeStamp"] as! String
            log.interval = Double(val["interval"] as! String)!
            log.key = snapshot.key
            
            let date = Util.getDateFromString(string: log.timeStamp)
            let numOfDays = Util.calculateDaysBetweenTwoDates(start: self.startDate, end: date)
            self.allData[numOfDays].append(log)
            
            self.loadList()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: calendarView.frame.size.height - width, width:  calendarView.frame.size.width, height: calendarView.frame.size.height)
        
        border.borderWidth = width
        calendarView.layer.addSublayer(border)
        calendarView.layer.masksToBounds = true
    }
    
    @IBAction func todayTapped(_ sender: Any) {
        
        // onSelect stuff
        calendarView.deselectAllDates()
        calendarView.selectDates([Date()])
        
        jumpToDate(date: Date())
    }
    
    @IBAction func newLogTapped(_ sender: Any) {
        performSegue(withIdentifier: "newLogSegue", sender: allData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newLogSegue" {
            let nextVC = segue.destination as! NewLogViewController
            nextVC.allData = sender as! [[TimerLog]]
            nextVC.startDate = startDate
        }
    }
    
    func updateMonthYear(date: Date) {
        let year = currentCalendar.component(.year, from: date)
        let month = currentCalendar.component(.month, from: date)
        let months = dateFormatter.monthSymbols
        yearLabel.text = String(year)
        monthLabel.text = months?[month-1]
    }
    
    func loadList() {
        self.calendarView.reloadData()
        self.tableView.reloadData()
    }
}

extension  LogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData[section].count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCustomCell", for: indexPath) as! CustomCell
        
        // display for days that contain a log
        if allData[indexPath.section].count > 0 {
            let log = allData[indexPath.section][indexPath.row]
            var elapsedTime = log.interval
            
            // calculate the hours in elapsed time
            let hours = UInt8(elapsedTime / 3600.0)
            elapsedTime -= (TimeInterval(hours) * 3600)
            
            // calculate the minutes in elapsed time
            let minutes = UInt8(elapsedTime / 60.0)
            
            // date converstion costly, using substring based on format: YYYY-MM-dd HH:mm:ss
            var finishedAt = log.timeStamp
            let start = finishedAt.index(finishedAt.startIndex, offsetBy: 10)
            let end = finishedAt.index(finishedAt.endIndex, offsetBy: -3)
            let range = start..<end
            finishedAt = finishedAt.substring(with: range)
            
            cell.hourLabel?.text = "\(hours)"
            cell.minLabel?.text = "\(minutes)"
            cell.finishedAtLabel?.text = finishedAt
            cell.resetMedals()
            for i in 0..<hours {
                cell.showMedal(ts: log.timeStamp, index: i, type: 0)
            }
            if minutes >= 45 {
                cell.showMedal(ts: log.timeStamp, index: hours, type: 3)
            } else if minutes >= 30 {
                cell.showMedal(ts: log.timeStamp, index: hours, type: 2)
            } else if minutes >= 15 {
                cell.showMedal(ts: log.timeStamp, index: hours, type: 1)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendarHeader[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "system", size: 14)
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return calendarHeader.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let dateString = calendarHeader[section]
        let date = dateFormatter.date(from: dateString)
        
        calendarView.deselectAllDates()
        calendarView.selectDates([date!])
        
        jumpToDate(date: date!)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension LogViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Util.getStartDate()
        let endDate = Util.getEndDate()

        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        
        return parameters
    }
    
    public func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        let dateNum = Util.calculateDaysBetweenTwoDates(start: startDate, end: date)
        if allData[dateNum].count > 0 {
            myCustomCell.showTime()
            var interval = 0.0
            for i in 0..<allData[dateNum].count {
                let log = allData[dateNum][i]
                interval += log.interval
            }
            // calculate the hours in elapsed time
            let hours = UInt8(interval / 3600.0)
            interval -= (TimeInterval(hours) * 3600)
            
            // calculate the minutes in elapsed time
            let minutes = UInt8(interval / 60.0)
            
            myCustomCell.cellViewHourLabel?.text = "\(hours)"
            myCustomCell.cellViewMinLabel?.text = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        } else {
            myCustomCell.hideTime()
        }
        
        // Setup text color
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
        
        jumpToSection(date: date)
        if cellState.dateBelongsTo != .thisMonth {
            jumpToDate(date: date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        //change the month and year after scrolling through months
        if !visibleDates.outdates.isEmpty {
            let date = visibleDates.monthDates[0]
            updateMonthYear(date: date)
        }
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState, date: Date) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = UIColor.black
            myCustomCell.cellViewHourLabel.textColor = Constants.timerOrange
            myCustomCell.cellViewMinLabel.textColor = Constants.timerOrange
            myCustomCell.cellViewColonLabel.textColor = Constants.timerOrange
            myCustomCell.layer.backgroundColor = UIColor.white.cgColor
            myCustomCell.clockImage.image?.alpha(1.0)
        } else {
            myCustomCell.dayLabel.textColor = Constants.timerGrey
            myCustomCell.cellViewHourLabel.textColor = Constants.timerOrange.withAlphaComponent(0.5)
            myCustomCell.cellViewMinLabel.textColor = Constants.timerOrange.withAlphaComponent(0.5)
            myCustomCell.cellViewColonLabel.textColor = Constants.timerOrange.withAlphaComponent(0.5)
            myCustomCell.layer.backgroundColor = Constants.timerLightGrey.cgColor
            myCustomCell.clockImage.image?.alpha(0.5)
        }
        
        let currentDateString = Util.getStringKeyFromDate(date: Date())
        let cellStateDateString = Util.getStringKeyFromDate(date: cellState.date)
        if  currentDateString ==  cellStateDateString {
            myCustomCell.dayLabel.textColor = Constants.timerBlue
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState, date: Date) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.layer.borderWidth = 1.0
            myCustomCell.layer.borderColor = Constants.timerBlue.cgColor
        } else {
            myCustomCell.layer.borderWidth = 0.0
        }
    }
    
    // scroll to appropriate section
    func jumpToSection(date: Date) {
        let numOfDates = Util.calculateDaysBetweenTwoDates(start: startDate, end: date)
        var row = 0
        //some sections contain 0 rows
        if allData[numOfDates].count == 0 {
            row = NSNotFound
        }
        let indexPath = IndexPath(row: row, section: numOfDates)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    // logic that comes along with tapping to a particular date
    func jumpToDate(date: Date) {
        let date = currentCalendar.startOfDay(for: date)
        // caledar scrolling
        calendarView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: true, preferredScrollPosition: UICollectionViewScrollPosition.top) {
            self.calendarView.layer.borderWidth = 0.0
        }
        updateMonthYear(date: date)
    }
    
    
}

extension UIImage{
    
    func alpha(_ value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
}
