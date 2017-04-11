//
//  TimerViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications
import UserNotificationsUI

class TimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var msLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var infinitiButton: UIButton!
    @IBOutlet weak var timerHourLabel: UILabel!
    @IBOutlet weak var timerMinLabel: UILabel!
    @IBOutlet weak var goalMetLabel: UILabel!
    @IBOutlet weak var setGoalView: UIView!
    @IBOutlet weak var setGoalLabel: UILabel!
    
    
    var status : Int = Constants.statusReset
    var timer = Timer()
    let dateFormatter = DateFormatter()
    var timerLog : TimerLog = TimerLog()
    var hours: [Int] = []
    var mins: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        self.timerPicker.delegate = self
        self.timerPicker.dataSource = self
        enableInfiniti()
        goalMetLabel.isHidden = true
        setGoalLabel.alpha = 0.0
        
        for i in 0..<24 {
            hours.append(i)
        }
        for i in 0..<60 {
            mins.append(i)
        }
        let user = FIRAuth.auth()!.currentUser!
        FIRDatabase.database().reference().child("chantInterval").child(user.uid).observe(FIRDataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                MyTimerLog.goalInterval = TimeInterval(snapshot.value as! Double)
                if MyTimerLog.goalInterval > 0.0 {
                    self.disableInfiniti()
                    var elapsedTime = MyTimerLog.goalInterval
                    // calculate the hours in elapsed time
                    let hours = UInt8(elapsedTime / 3600.0)
                    elapsedTime -= (TimeInterval(hours) * 3600)
                    
                    // calculate the minutes in elapsed time
                    let minutes = UInt8(elapsedTime / 60.0)
                    self.timerPicker.selectRow(Int(hours), inComponent: 0, animated: false)
                    self.timerPicker.selectRow(Int(minutes), inComponent: 1, animated: false)
                }
            }
        })
        
        if MyTimerLog.log.startTime > 0.0 {
            if MyTimerLog.log.isPaused {
                updatePaused(true)
                status = Constants.statusStopped
                updateTime(true)
            } else {
                updatePaused(true)
                MyTimerLog.log.pausedTime = NSDate.timeIntervalSinceReferenceDate
                status = Constants.statusStarted
                start()
            }
            updateButtons()
        } else {
            updatePaused(false)
            updateButtons()
        }
        
    }
    
    func updateButtons() {
        startButton.updateStartButton(status)
        resetButton.updateResetButton(status)
        logButton.updateLogButton(status)
    }
    
    func start() {
        if !timer.isValid {
            let actionSelector : Selector = #selector(TimerViewController.updateTime)
            if !MyTimerLog.log.isPaused {
                MyTimerLog.log.startTime = NSDate.timeIntervalSinceReferenceDate
                MyTimerLog.log.pausedInterval = 0.0
            } else {
                MyTimerLog.log.pausedInterval += (NSDate.timeIntervalSinceReferenceDate - MyTimerLog.log.pausedTime)
            }
            timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:actionSelector, userInfo: nil, repeats: true)
        }
        updatePaused(false)
    }
    
    func pause() {
        MyTimerLog.log.pausedTime = NSDate.timeIntervalSinceReferenceDate
        updatePaused(true)
        timer.invalidate()
    }
    
    
    func reset() {
        updatePaused(false)
        timer.invalidate()
        timer = Timer()
        hourLabel.text = "00"
        minLabel.text = "00"
        secLabel.text = "00"
        msLabel.text = "00"
        
        resetTimerLog()
    }
    
    func resetTimerLog() {
        MyTimerLog.reset()
    }
    
    func updatePaused(_ isP: Bool) {
        MyTimerLog.log.isPaused = isP
        pausedLabel.isHidden = !MyTimerLog.log.isPaused
    }
    
    func updateTime(_ isStored: Bool = false) {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        // Find the difference between current time and strart time
        var pausedInterval = MyTimerLog.log.pausedInterval
        if isStored {
            pausedInterval += NSDate.timeIntervalSinceReferenceDate - MyTimerLog.log.pausedTime
        }
        MyTimerLog.totalTime = currentTime - MyTimerLog.log.startTime - pausedInterval
        
        showHideGoalLabel(goal: MyTimerLog.goalInterval, actual: MyTimerLog.totalTime)
        
        var elapsedTime = MyTimerLog.totalTime
        
        // calculate the hours in elapsed time
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (TimeInterval(hours) * 3600)
        
        // calculate the minutes in elapsed time
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        // calculate the seconds in elapsed time
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        // find out the fraction of millisends to be displayed
        let fraction = UInt8(abs(elapsedTime) * 100)
        
        // add the leading zero for minutes, seconds and millseconds and store them as string constants
        let startHours    = hours > 9 ? String(hours):"0" + String(hours)
        let startMinutes  = minutes > 9 ? String(minutes):"0" + String(minutes)
        let startSeconds  = seconds > 9 ? String(seconds):"0" + String(seconds)
        let startFraction = fraction > 9 ? String(fraction):"0" + String(fraction)
        
        hourLabel.text = "\(startHours)"
        minLabel.text = "\(startMinutes)"
        secLabel.text = "\(startSeconds)"
        msLabel.text = "\(startFraction)"
    }
    
    @IBAction func startStopTapped(_ sender: Any) {
        if status == Constants.statusReset {
            start()
            status = Constants.statusStarted
            updateStatus(status: "chanting")
        } else if status == Constants.statusStarted {
            pause()
            status = Constants.statusStopped
            updateStatus(status: "online")
        } else if status == Constants.statusStopped {
            start()
            status = Constants.statusStarted
            updateStatus(status: "chanting")
        }
        updateButtons()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        if status == Constants.statusReset || status == Constants.statusStarted {
            print("reset should be disabled")
        } else if status == Constants.statusStopped {
            reset()
            status = Constants.statusReset
        }
        updateButtons()
    }
    
    @IBAction func logTapped(_ sender: Any) {
        if status == Constants.statusReset || status == Constants.statusStarted {
            print("log should be disabled")
        } else if status == Constants.statusStopped {
            reset()
            status = Constants.statusReset
        }
        logData()
        updateButtons()
    }
    
    func logData() {
        let user = FIRAuth.auth()!.currentUser!
        
        let log = [
            "interval" : "\(MyTimerLog.totalTime)",
            "timeStamp" : dateFormatter.string(from: Date())
        ]
        FIRDatabase.database().reference().child("users").child(user.uid).child("timerLogs").childByAutoId().setValue(log)
        
    }
    
    func updateStatus(status: String) {
        let user = FIRAuth.auth()!.currentUser!
        
        FIRDatabase.database().reference().child("status").child(user.uid).setValue(status)
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
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var str = ""
        if component == 0 {
            str = "\(hours[row])"
            if timerPicker.isUserInteractionEnabled {
                return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.white])
            } else {
                return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.darkGray])
            }
        } else {
            str = "\(mins[row])"
            if timerPicker.isUserInteractionEnabled {
                return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.white])
            } else {
                return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.darkGray])
            }
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        MyTimerLog.goalInterval = TimeInterval()
        if component == 0 {
            MyTimerLog.goalInterval.add(Double(row) * 3600.0)
            MyTimerLog.goalInterval.add(getMinIntervalFromPicker())
        } else {
            MyTimerLog.goalInterval.add(Double(row) * 60.0)
            MyTimerLog.goalInterval.add(getHourIntervalFromPicker())
        }
        
        showHideGoalLabel(goal: MyTimerLog.goalInterval, actual: MyTimerLog.totalTime)
        
        let user = FIRAuth.auth()!.currentUser!
        if MyTimerLog.goalInterval == 0.0 {
            FIRDatabase.database().reference().child("chantInterval").child(user.uid).removeValue()
        } else {
            FIRDatabase.database().reference().child("chantInterval").child(user.uid).setValue(MyTimerLog.goalInterval)
        }
        
        var elapsedTime = MyTimerLog.goalInterval
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (TimeInterval(hours) * 3600)
        let minutes = UInt8(elapsedTime / 60.0)
        animateGoalLabel(text: "\(hours) hours \(minutes) minutes")
    }
    
    @IBAction func inifinitiTapped(_ sender: Any) {
        MyTimerLog.goalInterval = TimeInterval()
        if timerPicker.isUserInteractionEnabled {
            enableInfiniti()
            let user = FIRAuth.auth()!.currentUser!
            FIRDatabase.database().reference().child("chantInterval").child(user.uid).removeValue()
            animateGoalLabel(text: "until the heart's desires")
        } else {
            disableInfiniti()
            MyTimerLog.goalInterval.add(getHourIntervalFromPicker())
            MyTimerLog.goalInterval.add(getMinIntervalFromPicker())
            let user = FIRAuth.auth()!.currentUser!
            var elapsedTime = MyTimerLog.goalInterval
            let hours = UInt8(elapsedTime / 3600.0)
            elapsedTime -= (TimeInterval(hours) * 3600)
            let minutes = UInt8(elapsedTime / 60.0)
            if MyTimerLog.goalInterval == 0.0 {
                FIRDatabase.database().reference().child("chantInterval").child(user.uid).removeValue()
            } else {
                FIRDatabase.database().reference().child("chantInterval").child(user.uid).setValue(MyTimerLog.goalInterval)
            }
            animateGoalLabel(text: "\(hours) hours \(minutes) minutes")
        }
        showHideGoalLabel(goal: MyTimerLog.goalInterval, actual: MyTimerLog.totalTime)
    }
    
    func getHourIntervalFromPicker() -> Double {
        return Double(timerPicker.selectedRow(inComponent: 0)) * 3600.0
    }
    
    func getMinIntervalFromPicker() -> Double {
        return Double(timerPicker.selectedRow(inComponent: 1)) * 60.0
    }
    
    func enableInfiniti() {
        infinitiButton.updateInfinitiButton(isSelected: true)
        timerPicker.isUserInteractionEnabled = false
        timerHourLabel.textColor = UIColor.darkGray
        timerMinLabel.textColor = UIColor.darkGray
        timerPicker.reloadAllComponents()
    }
    
    func disableInfiniti() {
        infinitiButton.updateInfinitiButton(isSelected: false)
        timerPicker.isUserInteractionEnabled = true
        timerHourLabel.textColor = UIColor.white
        timerMinLabel.textColor = UIColor.white
        timerPicker.reloadAllComponents()
    }
    
    func showHideGoalLabel(goal: TimeInterval, actual: TimeInterval) {
        if goal == 0.0 {
            goalMetLabel.isHidden = true
        } else {
            goalMetLabel.isHidden = !Util.isRightIntervalGreater(left: goal, right: actual)
        }
    }
    
    func animateGoalLabel(text: String) {
        setGoalLabel.text = text
        setGoalLabel.alpha = 1.0
        UIView.animate(withDuration: 2.0, animations: {
            self.setGoalLabel.alpha = 0.0
        })
    }
}
