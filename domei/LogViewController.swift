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
    
    var selectedDate : Date = Date()
    var logData : [String :[TimerLog]] = [:]
    var calendarHeader : [String] = []
    var allData : [[TimerLog]] = []
    let dateFormatter = DateFormatter()
    let currentCalendar : Calendar = Calendar.current
    var startDate : Date = Date()
    var count = 0
    
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
        startDate = dateFormatter.date(from: "2017/01/01")!
        var incrementDate = startDate
        let endDate = dateFormatter.date(from: "2017/12/31")
        while incrementDate.compare(endDate!) != ComparisonResult.orderedSame {
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
            
            self.dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let date = self.dateFormatter.date(from: log.timeStamp)
            self.dateFormatter.dateFormat = "YYYY/MM/dd"
            
            let numOfDays = self.calculateDaysBetweenTwoDates(start: self.startDate, end: date!)
            self.allData[numOfDays].append(log)
            self.tableView.reloadData()
        })
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    }
    
    @IBAction func todayTapped(_ sender: Any) {
        jumpToDate(date: Date())
    }
    
    func calculateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    // logic that comes along with tapping to a particular date
    func jumpToDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let date = currentCalendar.startOfDay(for: date)
        // caledar scrolling
        calendarView.scrollToDate(date)
        
        // onSelect stuff
        calendarView.deselectAllDates()
        calendarView.selectDates([date])
        
        // section scrolling
        jumpToSection(startDate: startDate, endDate: date)
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendarHeader[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: (header.textLabel?.font.fontName)!, size: 16)
        header.textLabel?.textColor = UIColor.darkGray
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return calendarHeader.count
    }
}

extension LogViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2017 01 01")! // You can use date generated from a formatter
        let endDate = Date(timeIntervalSinceNow: 60*60*24*365) // You can also use dates created from this function
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        // Setup text color
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
        
        jumpToSection(startDate: startDate, endDate: date)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState, date: date)
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        //change the month and year after scrolling through months
        if !visibleDates.outdates.isEmpty {
            let date = visibleDates.monthDates[0]
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            let months = dateFormatter.monthSymbols
            yearLabel.text = String(year)
            monthLabel.text = months?[month-1]
        }
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = UIColor.black
        } else {
            myCustomCell.dayLabel.textColor = Constants.timerGrey
        }
        
        let currentDateString = formatter.string(from: Date())
        let cellStateDateString = formatter.string(from: cellState.date)
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
    func jumpToSection(startDate: Date, endDate: Date) {
        let numOfDates = calculateDaysBetweenTwoDates(start: startDate, end: endDate)
        var row = 0
        //some sections contain 0 rows
        if allData[numOfDates].count == 0 {
            row = NSNotFound
        }
        let indexPath = IndexPath(row: row, section: numOfDates)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
    }
}
