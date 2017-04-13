//
//  Prayer.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/13.
//  Copyright © 2017 kurifu. All rights reserved.
//

import Foundation

class Prayer {
    var key : String = ""
    var createdAt : Date? = nil
    var targetDate : Date? = nil
    var title : String = ""
    var notes : String = ""
    var isCompleted : Bool = false
    var shareWithFriends : Bool = false
    var totalChanted : TimeInterval = TimeInterval()
    
    func getValueForDB() -> [String:Any] {
        let p = [
            "title": self.title,
            "targetDate": self.targetDate == nil ? "" : Util.getStringFromDate(date: self.targetDate!),
            "notes": self.notes,
            "createdAt": self.createdAt == nil ? "" : Util.getStringFromDate(date: self.createdAt!),
            "isCompleted": self.isCompleted.hashValue,
            "shareWithFriends": self.shareWithFriends.hashValue
            ] as [String : Any]
        print(self.shareWithFriends.hashValue)
        return p
    }
}
