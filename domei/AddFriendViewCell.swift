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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        let user = FIRAuth.auth()!.currentUser!
        FIRDatabase.database().reference().child("users").child(user.uid).child("friends").child(uid).setValue(name)
        updateButton(isFriend: true)
    }
    
    func updateButton(isFriend: Bool) {
        if isFriend {
            self.addButton.setTitle("✓", for: UIControlState.normal)
            self.addButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.addButton.backgroundColor = Constants.timerBlue
            self.addButton.layer.cornerRadius = 3
        } else {
            self.addButton.setTitle("+", for: UIControlState.normal)
            self.addButton.setTitleColor(Constants.timerBlue, for: UIControlState.normal)
            self.addButton.backgroundColor = UIColor.white
            self.addButton.layer.cornerRadius = 3
        }
    }
}
