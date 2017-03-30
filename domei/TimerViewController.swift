//
//  TimerViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

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
    var startTime = TimeInterval()
    var isPaused : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePaused(false)
        updateButtons()
    }
    
    func updateButtons() {
        startButton.updateStartButton(status)
        resetButton.updateResetButton(status)
        logButton.updateLogButton(status)
    }
    
    func start() {
        if !timer.isValid {
            let actionSelector : Selector = #selector(TimerViewController.updateTime)
            if !isPaused {
                startTime = NSDate.timeIntervalSinceReferenceDate
            }
            timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:actionSelector, userInfo: nil, repeats: true)
        }
        updatePaused(false)
    }
    
    func pause() {
        updatePaused(true)
        timer.invalidate()
    }
    
    
    func reset() {
        updatePaused(false)
        timer.invalidate()
        timer == nil
    }
    
    func updatePaused(_ isP: Bool) {
        isPaused = isP
        pausedLabel.isHidden = !isPaused
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        // Find the difference between current time and strart time
        var elapsedTime: TimeInterval = currentTime - startTime
        
        // calculate the hours in elapsed time
        let hours = UInt8(elapsedTime / 360.0)
        elapsedTime -= (TimeInterval(hours) * 360)
        
        // calculate the minutes in elapsed time
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        // calculate the seconds in elapsed time
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        // find out the fraction of millisends to be displayed
        let fraction = UInt8(elapsedTime * 100)
        
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
        } else if status == Constants.statusStarted {
            pause()
            status = Constants.statusStopped
        } else if status == Constants.statusStopped {
            start()
            status = Constants.statusStarted
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
        updateButtons()
    }
    
}
