//
//  MyTimerLog.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/11.
//  Copyright © 2017 kurifu. All rights reserved.
//

import Foundation

class MyTimerLog {
    static var log : TimerLog = TimerLog()
    static var totalTime : TimeInterval = TimeInterval()
    static var goalInterval : TimeInterval = TimeInterval()

    static let requestTimerIdentifier = "timerRequest"
    
    
    static func reset() {
        MyTimerLog.log.isPaused = false
        MyTimerLog.log.interval = 0.0
        MyTimerLog.log.key = ""
        MyTimerLog.log.pausedInterval = 0.0
        MyTimerLog.log.pausedTime = 0.0
        MyTimerLog.log.startTime = 0.0
        MyTimerLog.log.timeStamp = ""
    }
}
