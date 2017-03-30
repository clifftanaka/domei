//
//  StartButton.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

extension UIButton {
    
    func updateStartButton (_ status: Int) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
        switch status {
        case Constants.statusReset,
             Constants.statusStopped:
            //title
            self.setTitle("Start", for: UIControlState.normal)
            self.setTitleColor(UIColor.white, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor(colorLiteralRed: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0)
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = ((UIColor(colorLiteralRed: 116.0/255.0, green: 242.0/255.0, blue: 131.0/255.0, alpha: 1.0)) as UIColor).cgColor
            break
            
        case Constants.statusStarted:
            //title
            self.setTitle("Stop", for: UIControlState.normal)
            self.setTitleColor(UIColor(colorLiteralRed: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0), for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = (UIColor(colorLiteralRed: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0) as UIColor).cgColor
            break
            
        default: break
            
        }
    }
    
    func updateResetButton (_ status: Int) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
        switch status {
        case Constants.statusReset,
             Constants.statusStarted:
            self.isEnabled = false
            //title
            self.setTitleColor(UIColor(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0), for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = (UIColor(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0) as UIColor).cgColor
            break
        case Constants.statusStopped:
            self.isEnabled = true
            //title
            self.setTitleColor(UIColor(colorLiteralRed: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0), for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor(colorLiteralRed: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
            break
        
        default: break
            
        }
    }
    
    func updateLogButton (_ status: Int) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
        switch status {
        case Constants.statusReset,
             Constants.statusStarted:
            self.isEnabled = false
            //title
            self.setTitleColor(UIColor(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0), for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = (UIColor(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0) as UIColor).cgColor
            break
        case Constants.statusStopped:
            self.isEnabled = true
            //title
            self.setTitleColor(UIColor(colorLiteralRed: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0), for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = (UIColor(colorLiteralRed: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0) as UIColor).cgColor
            break
            
        default: break
            
        }
    }

}
