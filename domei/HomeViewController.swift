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
    var goal : [String:TimeInterval] = [:]
    var goalInterval : [String:TimeInterval] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        statuses[Constants.statusChanting] = NSMutableDictionary()
        statuses[Constants.statusOnline] = NSMutableDictionary()
        statuses[Constants.statusOffline] = NSMutableDictionary()

        FIRDatabase.database().reference().child("goalRemaining").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                self.goal[snapshot.key] = TimeInterval(snapshot.value as! Double)
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("goalRemaining").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                self.goal[snapshot.key] = TimeInterval(snapshot.value as! Double)
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("goalRemaining").observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            if snapshot.exists() {
                self.goal.removeValue(forKey: snapshot.key)
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("goalInterval").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                self.goalInterval[snapshot.key] = TimeInterval(snapshot.value as! Double)
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("goalInterval").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                self.goalInterval[snapshot.key] = TimeInterval(snapshot.value as! Double)
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("goalInterval").observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            if snapshot.exists() {
                self.goalInterval.removeValue(forKey: snapshot.key)
                self.tableView.reloadData()
            }
        })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath) as! MainCell
        let uid = self.friends[indexPath.row]["uid"] as! String
        let name = self.friends[indexPath.row]["name"] as! String
        let g = self.goal[uid]
        let gI = self.goalInterval[uid]
        var status = Constants.statusOffline
        cell.untilLabel.isHidden = true
        cell.goalLabel.isHidden = true
        if self.statuses[Constants.statusChanting]?.object(forKey: uid) != nil {
            status = Constants.statusChanting
            cell.untilLabel.isHidden = false
            if g != nil {
                cell.updateUntilLabel(interval: g!)
            } else {
                cell.updateUntilLabel(interval: 0.0)
            }
            cell.goalLabel.isHidden = false
            let until = g == nil ? 0.0 : g!
            if gI != nil {
                cell.updateGoalLabel(interval: gI!, until: until)
            } else {
                cell.updateGoalLabel(interval: 0.0, until: until)
            }
        } else if self.statuses[Constants.statusOnline]?.object(forKey: uid) != nil {
            status = Constants.statusOnline
        }
        cell.updateName(name: name)
        cell.updateStatus(status: status)
        return cell
    }
}
