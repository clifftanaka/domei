//
//  StatusUILabel.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/15.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

extension UILabel {
    
    
    func updateStatus(status: String) {
        switch status {
        case "online" :
            self.text = "●"
            self.textColor = Constants.timerGreen
            break;
        case "offline" :
            self.text = "●"
            self.textColor = Constants.timerGrey
            break;
        case "chanting" :
            self.text = "🙏"
            break;
        default:
            break;
        }
    }
}
