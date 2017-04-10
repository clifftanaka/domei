//
//  AddFriendViewCell.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddFriendViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var uid : String = ""
    var name : String = ""
    var isFriend = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        self.updateStatus()
        self.updateDatabase()
        self.updateButton()
        
    }
    
    func updateStatus() {
        isFriend = !isFriend
    }
    
    func updateDatabase() {
        let user = FIRAuth.auth()!.currentUser!
        if isFriend {
        FIRDatabase.database().reference().child("users").child(user.uid).child("friends").child(self.uid).setValue(self.name)
        } else {
            FIRDatabase.database().reference().child("users").child(user.uid).child("friends").child(self.uid).removeValue()
        }

    }
    
    func updateButton() {
        if isFriend {
            self.addButton.frame.size = CGSize(width: 30, height: 30)
            self.addButton.setTitle("✓", for: UIControlState.normal)
            self.addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.addButton.backgroundColor = Constants.timerBlue
            self.addButton.layer.borderColor = UIColor.white.cgColor
            self.addButton.layer.borderWidth = 1.0
            self.addButton.layer.cornerRadius = 3
        } else {
            self.addButton.frame.size = CGSize(width: 90, height: 30)
            self.addButton.setTitle("follow", for: UIControlState.normal)
            self.addButton.setTitleColor(Constants.timerBlue, for: UIControlState.normal)
            self.addButton.backgroundColor = UIColor.white
            self.addButton.layer.borderColor = Constants.timerBlue.cgColor
            self.addButton.layer.borderWidth = 1.0
            self.addButton.layer.cornerRadius = 3
        }
    }
}
