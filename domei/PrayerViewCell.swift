//
//  PrayerViewCell.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/13.
//  Copyright © 2017 kurifu. All rights reserved.
//
import UIKit

class PrayerViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    
    var key : String = ""
    var isCompleted = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        checkAction()
    }
    
    @IBAction func checkContainerTapped(_ sender: Any) {
        checkAction()
    }
    
    func checkAction() {
        if isCompleted {
            setIsIncomplete()
            PrayerService.updatePrayerComplete(key: key, isComplete: false)
            isCompleted = false
        } else {
            setIsComplete()
            PrayerService.updatePrayerComplete(key: key, isComplete: true)
            isCompleted = true
        }
    }
    
    func setIsComplete() {
        checkButton.layer.cornerRadius = 0.5 * checkButton.bounds.size.width
        //background
        checkButton.backgroundColor = Constants.timerGreen
        //border
        checkButton.layer.borderWidth = 1.0
        checkButton.layer.borderColor = Constants.timerGreen.cgColor
    }
    
    func setIsIncomplete() {
        checkButton.layer.cornerRadius = 0.5 * checkButton.bounds.size.width
        //background
        checkButton.backgroundColor = UIColor.white
        //border
        checkButton.layer.borderWidth = 1.0
        checkButton.layer.borderColor = Constants.timerGreen.cgColor
    }
}
