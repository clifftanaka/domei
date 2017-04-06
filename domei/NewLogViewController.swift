//
//  NewLogViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/05.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewLogViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var allData : [[TimerLog]] = []
    var startDate : Date = Date()
    var hours: [Int] = []
    var mins: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerPicker.delegate = self
        self.timerPicker.dataSource = self
        
        for i in 0..<24 {
            hours.append(i)
        }
        for i in 0..<60 {
            mins.append(i)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction(_ sender: Any) {
        
        let date = datePicker.date
        let hours = timerPicker.selectedRow(inComponent: 0)
        let mins = timerPicker.selectedRow(inComponent: 1)
        
        let title = "Oh no!"
        
        if hours == 0 && mins == 0 {
            showAlert(title: title, message: "You must input at least 1 minute")
            return
        }
        
        let hoursInSecs = Double(hours * 3600)
        let minsInSecs = Double(mins * 60)
        
        let maxInDay = 24.0 * 60.0 * 60.0
        var loggedInterval = 0.0
        let newLogInterval = hoursInSecs + minsInSecs
        
        
        let num = Util.calculateDaysBetweenTwoDates(start: startDate, end: date)
        
        if allData[num].count > 0 {
            for i in 0..<allData[num].count {
                loggedInterval += allData[num][i].interval
            }
        }
        
        if loggedInterval + newLogInterval > maxInDay {
            let limit = Int (loggedInterval + newLogInterval - maxInDay / 60.0)
            showAlert(title: title, message: "You are chanting too much! You can only chant 24 hours a day! You're \(limit) minutes over the limit")
        } else {
            logData(interval: newLogInterval, date: date)
            dismiss(animated: true, completion: { 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        } else {
            return mins.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(hours[row])"
        } else {
            return "\(mins[row])"
        }
    }
    
    func logData(interval: Double, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let user = FIRAuth.auth()!.currentUser!
        
        let log = [
            "interval" : "\(interval)",
            "timeStamp" : dateFormatter.string(from: date)
        ]
        FIRDatabase.database().reference().child("users").child(user.uid).child("timerLogs").childByAutoId().setValue(log)
        
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true)
    }
}
