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

class TimerViewController: UIViewController {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var msLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    
    var status : Int = Constants.statusReset
    var timer = Timer()
    var totalTime = TimeInterval()
    let dateFormatter = DateFormatter()
    
    var timerLog : TimerLog = TimerLog()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        if MyTimerLog.log.startTime > 0.0 {
            print(MyTimerLog.log.startTime)
            print(MyTimerLog.log.pausedInterval)
            print(MyTimerLog.log.pausedTime)
            print(MyTimerLog.log.isPaused)
            
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
        totalTime = currentTime - MyTimerLog.log.startTime - pausedInterval
        
        var elapsedTime = totalTime
        
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
            "interval" : "\(totalTime)",
            "timeStamp" : dateFormatter.string(from: Date())
        ]
        FIRDatabase.database().reference().child("users").child(user.uid).child("timerLogs").childByAutoId().setValue(log)
        
    }
    
    func updateStatus(status: String) {
        let user = FIRAuth.auth()!.currentUser!
        
        FIRDatabase.database().reference().child("status").child(user.uid).setValue(status)
    }
}
