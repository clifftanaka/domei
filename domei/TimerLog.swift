//
//  Log.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/01.
//  Copyright © 2017 kurifu. All rights reserved.
//

import Foundation

class TimerLog {
    var key = ""
    var interval = 0.0
    var timeStamp = ""
    var startTime : TimeInterval = TimeInterval()
    var pausedTime : TimeInterval = TimeInterval()
    var pausedInterval : TimeInterval = TimeInterval()
    var isPaused : Bool = false
    
    func reset()
    {
        key = ""
        interval = 0.0
        timeStamp = ""
        startTime = TimeInterval()
        pausedTime = TimeInterval()
        pausedInterval = TimeInterval()
        isPaused = false
    }
}
