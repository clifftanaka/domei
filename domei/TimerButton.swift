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
            self.backgroundColor = Constants.timerGreen
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerLightGreen.cgColor
            break
            
        case Constants.statusStarted:
            //title
            self.setTitle("Stop", for: UIControlState.normal)
            self.setTitleColor(Constants.timerGreen, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerGreen.cgColor
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
            self.setTitleColor(Constants.timerGrey, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerGrey.cgColor
            break
        case Constants.statusStopped:
            self.isEnabled = true
            //title
            self.setTitleColor(Constants.timerRed, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerRed.cgColor
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
            self.setTitleColor(Constants.timerGrey, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerGrey.cgColor
            break
        case Constants.statusStopped:
            self.isEnabled = true
            //title
            self.setTitleColor(Constants.timerBlue, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = Constants.timerBlue.cgColor
            break
            
        default: break
            
        }
    }
    
    func updateInfinitiButton (isSelected: Bool) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        
        if isSelected {
            //title
            self.setTitleColor(Constants.timerBlue, for: UIControlState.normal)
            //background
            self.backgroundColor = UIColor.white
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            //title
            self.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            //background
            self.backgroundColor = Constants.timerDarkGrey
            //border
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.darkGray.cgColor
        }
    }

}
