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
import FirebaseAuthUI

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var allPeople: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var statuses : [String:NSMutableDictionary] = [:]
    var friends : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        statuses[Constants.statusChanting] = NSMutableDictionary()
        statuses[Constants.statusOnline] = NSMutableDictionary()
        statuses[Constants.statusOffline] = NSMutableDictionary()
        
        
        FIRDatabase.database().reference().child("status").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let status = snapshot.value as! String
                switch status {
                case  Constants.statusChanting :
                    self.statuses[Constants.statusChanting]?.setValue(snapshot.value, forKey: snapshot.key)
                    break
                case Constants.statusOnline :
                    self.statuses[Constants.statusOnline]?.setValue(snapshot.value, forKey: snapshot.key)
                    break
                case Constants.statusOffline :
                    self.statuses[Constants.statusOffline]?.setValue(snapshot.value, forKey: snapshot.key)
                    break
                default:
                    break
                }
                self.allPeople.text = "\((self.statuses[Constants.statusChanting]?.count)!)"
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("status").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                let status = snapshot.value as! String
                switch status {
                case  Constants.statusChanting :
                    self.statuses[Constants.statusChanting]?.setValue(snapshot.value, forKey: snapshot.key)
                    self.statuses[Constants.statusOnline]?.removeObject(forKey: snapshot.key)
                    self.statuses[Constants.statusOffline]?.removeObject(forKey: snapshot.key)
                    break
                case Constants.statusOnline :
                    self.statuses[Constants.statusChanting]?.removeObject(forKey: snapshot.key)
                    self.statuses[Constants.statusOnline]?.setValue(snapshot.value, forKey: snapshot.key)
                    self.statuses[Constants.statusOffline]?.removeObject(forKey: snapshot.key)
                    break
                case Constants.statusOffline :
                    self.statuses[Constants.statusChanting]?.removeObject(forKey: snapshot.key)
                    self.statuses[Constants.statusOnline]?.removeObject(forKey: snapshot.key)
                    self.statuses[Constants.statusOffline]?.setValue(snapshot.value, forKey: snapshot.key)
                    break
                default:
                    break
                }
                self.allPeople.text = "\((self.statuses[Constants.statusChanting]?.count)!)"
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
        var status = Constants.statusOffline
        if self.statuses[Constants.statusChanting]?.object(forKey: uid) != nil {
            status = Constants.statusChanting
        } else if self.statuses[Constants.statusOnline]?.object(forKey: uid) != nil {
            status = Constants.statusOnline
        }
        cell.updateName(name: name)
        cell.updateStatus(status: status)
        
        return cell
    }
}
