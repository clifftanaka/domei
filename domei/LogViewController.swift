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
    var logData : [TimerLog] = []
    let dateFormatter = DateFormatter()
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView") // Registering your cell is manditory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.scrollToDate(Date())
        dateFormatter.dateFormat = "YYYY-MM-dd HH:MM:ss"
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func todayTapped(_ sender: Any) {
        calendarView.scrollToDate(Date())
    }
    
}

extension  LogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let log = logData[indexPath.row]
        var elapsedTime = log.interval
        
        // calculate the hours in elapsed time
        let hours = UInt8(elapsedTime / 360.0)
        elapsedTime -= (TimeInterval(hours) * 360)
        
        // calculate the minutes in elapsed time
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        // calculate the seconds in elapsed time
        let seconds = UInt8(elapsedTime)
        
        var message = ""
        if (hours > 0) {
            message += "\(hours) hrs "
        }
        if (minutes > 0) {
            message += "\(minutes) mins "
        }
        message += "\(seconds) secs "
        
        cell.textLabel?.text = "\(message) at: \(log.timeStamp)"
        
        return cell
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
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text

        // Setup text color
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
        
        // Todays text color
        let currentDateString = dateFormatter.string(from: Date())
        let cellStateDateString = dateFormatter.string(from: cellState.date)
        if  currentDateString ==  cellStateDateString && cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = Constants.timerBlue
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
        
        let from = dateFormatter.string(from: date)
        var dateComponent =  DateComponents()
        dateComponent.day = 1
        let calendar = NSCalendar.current
        let newDate = calendar.date(byAdding: dateComponent, to: date)
        let to = dateFormatter.string(from: newDate!)
        
        
        
        logData = []
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("timerLogs").queryOrdered(byChild: "timeStamp").queryStarting(atValue: from).queryEnding(atValue: to).observe(FIRDataEventType.childAdded, with: { (snapshot) in
            print(snapshot)
            
            
            let log = TimerLog()
            let val = snapshot.value as! NSDictionary
            log.timeStamp = val["timeStamp"] as! String
            log.interval = Double(val["interval"] as! String)!
            log.key = snapshot.key
            
            self.logData.append(log)
            
            self.tableView.reloadData()
        })
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if !visibleDates.outdates.isEmpty {
            let date = visibleDates.monthDates[0]
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let months = dateFormatter.monthSymbols
            yearLabel.text = String(year)
            monthLabel.text = months?[month-1]
        }
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState) {
        
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = UIColor.black
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = UIColor.black
            } else {
                myCustomCell.dayLabel.textColor = Constants.timerGrey
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
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
}
