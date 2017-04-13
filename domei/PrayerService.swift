//
//  PrayerService.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/13.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PrayerService {
    static func savePrayer(prayer: Prayer) {
        let user = FIRAuth.auth()!.currentUser!
        let value = prayer.getValueForDB()
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").childByAutoId().setValue(value)
    }
    
    static func updatePrayer(prayer: Prayer) {
        let user = FIRAuth.auth()!.currentUser!
        let value = prayer.getValueForDB()
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").child(prayer.key).setValue(value)
    }
    
    static func removePrayer(key: String) {
        let user = FIRAuth.auth()!.currentUser!
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").child(key).removeValue()
    }
    
    static func updatePrayerComplete(key: String, isComplete: Bool) {
        let user = FIRAuth.auth()!.currentUser!
        let value = isComplete ? 1 : 0
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").child(key).child("isCompleted").setValue(value)
    }
    
    static func getPrayerFromSnapshop(snapshot: FIRDataSnapshot) -> Prayer{
        let key = snapshot.key
        let dic = snapshot.value as! NSDictionary
        let p = Prayer()
        p.key = key
        p.title = dic.value(forKey: "title") as! String
        let targetDate = dic.value(forKey: "targetDate") as! String
        p.targetDate = targetDate == "" ? nil : Util.getDateFromString(string: targetDate)
        p.notes = dic.value(forKey: "notes") as! String
        p.createdAt = Util.getDateFromString(string: dic.value(forKey: "createdAt") as! String)
        p.isCompleted = Bool(dic.value(forKey: "isCompleted") as! NSNumber)
        p.shareWithFriends = Bool(dic.value(forKey: "shareWithFriends") as! NSNumber)
        return p
    }
}
