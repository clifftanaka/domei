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
            self.statusLabel.textColor = Constants.timerRed
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
}

