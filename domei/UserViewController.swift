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
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numFriendsButton: UIButton!
    
    var user : User = User()
    var myFriends : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authUser = FIRAuth.auth()!.currentUser!
        FIRDatabase.database().reference().child("users").child(authUser.uid).child("user").observe(FIRDataEventType.value, with: { (snapshot) in
            let dic = snapshot.value as! NSDictionary
            self.user.name = (dic["name"] as? String)!
            self.nameLabel.text = self.user.name
        })
        FIRDatabase.database().reference().child("users").child(authUser.uid).child("friends").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            if snapshot.exists() {
                let key = snapshot.key 
                let value = snapshot.value as! String
                self.myFriends.append(["uid": key, "name": value])
                self.numFriendsButton.setTitle("\(self.myFriends.count) friends", for: UIControlState.normal)
            }
        })
    }
    
    
    @IBAction func editTapped(_ sender: Any) {
        performSegue(withIdentifier: "editusersegue", sender: self.user)
    }
    
    @IBAction func viewFriendsTapped(_ sender: Any) {
        performSegue(withIdentifier: "viewfriendssegue", sender: self.myFriends)
    }
    
    @IBAction func addFriendTapped(_ sender: Any) {
        performSegue(withIdentifier: "addfriendsegue", sender: self.myFriends)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editusersegue" {
            let nextVC = segue.destination as! EditUserViewController
            nextVC.user = sender as! User
        } else if segue.identifier == "viewfriendssegue" {
            let nextVC = segue.destination as! ViewFriendsViewController
            nextVC.friends = sender as! [NSDictionary]
        } else if segue.identifier == "addfriendsegue" {
            let nextVC = segue.destination as! AddFriendViewController
            nextVC.friends = sender as! [NSDictionary]
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true)
    }
}
