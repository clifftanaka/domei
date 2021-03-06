//
//  EditUserViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EditUserViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    
    var user : User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.text = user.name
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let authUser = FIRAuth.auth()!.currentUser!
    
        FIRDatabase.database().reference().child("users").child(authUser.uid).child("user").child("name").setValue(nameField.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
