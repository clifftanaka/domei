//
//  NewPrayerViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/13.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

class NewPrayerViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var targetDateSwitch: UISwitch!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var shareFriendsSwitch: UISwitch!
    
    var prayer : Prayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if prayer != nil {
            headerLabel.text = "Edit Prayer"
            titleField.text = prayer?.title
            targetDateSwitch.isOn = prayer?.targetDate != nil
            if targetDateSwitch.isOn {
                datePickerView.isHidden = false
                datePicker.date = (prayer?.targetDate)!
            }
            shareFriendsSwitch.isOn = (prayer?.shareWithFriends)!
            textView.text = prayer?.notes
        }
    }
    
    @IBAction func targetDateSwithAction(_ sender: Any) {
        if targetDateSwitch.isOn {
            datePickerView.isHidden = false
        } else {
            datePickerView.isHidden = true
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        if prayer == nil {
            let prayer = Prayer()
            prayer.title = titleField.text!
            prayer.targetDate = targetDateSwitch.isOn ? datePicker.date : nil
            prayer.shareWithFriends = shareFriendsSwitch.isOn
            prayer.notes = textView.text
            prayer.createdAt = Date()
            if !(titleField.text?.isEmpty)! {
                PrayerService.savePrayer(prayer: prayer)
                dismiss(animated: true, completion: nil)
                print("save")
            }
        } else {
            prayer?.title = titleField.text!
            prayer?.targetDate = targetDateSwitch.isOn ? datePicker.date : nil
            prayer?.shareWithFriends =  shareFriendsSwitch.isOn
            prayer?.notes = textView.text
            if !(titleField.text?.isEmpty)! {
                PrayerService.updatePrayer(prayer: prayer!)
                dismiss(animated: true, completion: nil)
            }

        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
