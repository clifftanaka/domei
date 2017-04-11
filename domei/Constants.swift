//
//  Constants.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

struct Constants {
    static let statusChanting = "chanting"
    static let statusOnline = "online"
    static let statusOffline = "offline"
    
    static let statusReset = 0
    static let statusStarted = 1
    static let statusStopped = 2
    
    static let timerDarkGrey : UIColor = UIColor(colorLiteralRed: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
    static let timerLightGrey : UIColor = UIColor(colorLiteralRed: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    static let timerOrange : UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 142.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    static let timerBlue : UIColor = UIColor(colorLiteralRed: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let timerBlueLightt : UIColor = UIColor(colorLiteralRed: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let timerGrey : UIColor = UIColor(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    static let timerRed : UIColor = UIColor(colorLiteralRed: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    static let timerGreen : UIColor = UIColor(colorLiteralRed: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    static let timerLightGreen : UIColor = UIColor(colorLiteralRed: 116.0/255.0, green: 242.0/255.0, blue: 131.0/255.0, alpha: 1.0)
    
    static func timerReminderNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Just checking in 🙏"
        content.subtitle = "Timer running. Still chanting?"
        content.body = "Ignore this if you are still chanting 😊"
        content.sound = UNNotificationSound.default()
        return content
    }
    
    static func timerGoalReachedNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Congratulations! 🙏"
        content.subtitle = "You have reached your goal!!!"
        content.body = "Log your minutes or reset your timer 😊"
        content.sound = UNNotificationSound.default()
        return content
    }
}
