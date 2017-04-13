//
//  MainCell.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var untilLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateStatus(status: String) {
        switch status {
        case "online" :
            self.statusLabel.text = "●"
            self.statusLabel.textColor = Constants.timerGreen
            break;
        case "offline" :
            self.statusLabel.text = "●"
            self.statusLabel.textColor = Constants.timerGrey
            break;
        case "chanting" :
            self.statusLabel.text = "🙏"
            break;
        default:
            break;
        }
    }
    
    func updateName(name: String) {
        nameLabel.text = name
    }
    
    func updateUntilLabel(interval: TimeInterval) {
        var date = Date()
        date.addTimeInterval(interval)
        let time = Util.getHourMinFromString(date: date)
        if interval == 0.0 {
            untilLabel.text = "the heart desires"
            untilLabel.font = UIFont(name: untilLabel.font.fontName, size: 12)
        } else {
            untilLabel.text = "\(time)"
            untilLabel.font = UIFont(name: untilLabel.font.fontName, size: 20)
        }
    }
    
    func updateGoalLabel(interval: TimeInterval, until: TimeInterval) {
        var elapsedTime = interval
        let hours = UInt8(elapsedTime / 3600.0)
        elapsedTime -= (TimeInterval(hours) * 3600)
        let minutes = UInt8(elapsedTime / 60.0)
        if interval == 0.0 {
            goalLabel.text = "∞"
            goalLabel.font = UIFont(name: goalLabel.font.fontName, size: 30)
        } else if until == 0.0 {
            goalLabel.text = "finished!"
            goalLabel.font = UIFont(name: goalLabel.font.fontName, size: 16)
        } else {
            if hours == 0 {
                goalLabel.text = "\(minutes) mins"
                goalLabel.font = UIFont(name: goalLabel.font.fontName, size: 20)
            } else {
                goalLabel.text = "\(hours) hrs \(minutes) mins"
                goalLabel.font = UIFont(name: goalLabel.font.fontName, size: 14)
            }
        }
    }
}

