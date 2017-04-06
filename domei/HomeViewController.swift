//
//  HomeViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allPeople: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var chanting : [String:String] = [:]
    var friends : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        FIRDatabase.database().reference().child("status").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let status = snapshot.value as! String
                if status == "chanting" {
                    self.chanting[snapshot.key] = status
                }
                self.allPeople.text = "\(self.chanting.count)"
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("status").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                let status = snapshot.value as! String
                if status == "chanting" {
                    self.chanting[snapshot.key] = snapshot.value as? String
                } else if status == "online" || status == "offline" {
                    self.chanting.removeValue(forKey: snapshot.key)
                }
                self.allPeople.text = "\(self.chanting.count)"
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        friends = []
        if let authUser = FIRAuth.auth()?.currentUser {
            FIRDatabase.database().reference().child("users").child(authUser.uid).child("friends").observe(FIRDataEventType.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    self.friends.append(["uid":snapshot.key, "name":(snapshot.value as! String)])
                }
                self.tableView.reloadData()
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath) as! MainCell
        let uid = self.friends[indexPath.row]["uid"] as! String
        let name = self.friends[indexPath.row]["name"] as! String
        var status = "online"
        if self.chanting[uid] != nil {
            status = "chanting"
        }
        cell.updateName(name: name)
        cell.updateStatus(status: status)
        
        return cell
    }
}
