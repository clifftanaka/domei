//
//  Util.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/05.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

class Util {
    
    static let currentCalendar : Calendar = Calendar.current
    static let dateFormatter : DateFormatter = DateFormatter()
    
    static func getStartDate() -> Date{
        return Util.getDateFromString(string: "2017/01/01 00:00:00")
    }
    
    static func getEndDate() -> Date{
        return Util.getDateFromString(string: "2017/12/31 00:00:00")
    }
    
    static func calculateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        let start = currentCalendar.startOfDay(for: start)
        let end = currentCalendar.startOfDay(for: end)
        
        guard let s = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let e = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return e - s
    }
    
    static func getDateFromString(string: String) -> Date {
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return dateFormatter.date(from: string)!
    }
    
    static func getStringKeyFromDate(date: Date) -> String {
        let d = currentCalendar.startOfDay(for: date)
        dateFormatter.dateFormat = "yyyy MM dd"
        return dateFormatter.string(from: d)
    }
    
    static func isRightIntervalGreater(left: TimeInterval, right: TimeInterval) -> Bool{
        return left.isLessThanOrEqualTo(right)
    }
}
