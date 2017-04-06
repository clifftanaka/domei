//
//  UserViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authUser = FIRAuth.auth()!.currentUser!
        
        FIRDatabase.database().reference().child("users").child(authUser.uid).child("user").child("name").observe(FIRDataEventType.value, with: { (snapshot) in
            
            guard !snapshot.exists() else{
                self.usernameField.text = snapshot.value as! String
                return
            }
        })
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let authUser = FIRAuth.auth()!.currentUser!
        let text = usernameField.text!
        if text != "" {
            let user = [
                "name" : text
            ]
            FIRDatabase.database().reference().child("users").child(authUser.uid).child("user").setValue(user)
        } else {
            showAlert(title: "Oops", message: "You cannot entery an empty string")
        }
    }
    
    @IBAction func viewFriendsTapped(_ sender: Any) {
        performSegue(withIdentifier: "viewfriendssegue", sender: nil)
    }
    
    @IBAction func addFriendTapped(_ sender: Any) {
        performSegue(withIdentifier: "addfriendsegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addfriendsegue" {
            //let nextVC = segue.destination as! NewLogViewController
            //nextVC.allData = sender as! [[TimerLog]]
            //nextVC.startDate = startDate
        } else if segue.identifier == "viewfriendssegue" {
            
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true)
    }
}
