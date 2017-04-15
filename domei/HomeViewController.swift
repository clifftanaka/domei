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
    
    @IBOutlet weak var homeUserView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chantButton: UIButton!
    @IBOutlet weak var cheerButton: UIButton!
    @IBOutlet weak var homeUserTableView: UITableView!
    @IBOutlet weak var modalShadowView: UIView!
    @IBOutlet weak var chantStatus: UILabel!
    
    var statuses : [String:NSMutableDictionary] = [:]
    var friends : [NSDictionary] = []
    var goal : [String:TimeInterval] = [:]
    var goalInterval : [String:TimeInterval] = [:]
    var prayers : [String:[String]] = [:]
    var homePrayers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        homeUserTableView.dataSource = self
        homeUserTableView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        modalShadowView.addGestureRecognizer(tap)
        modalShadowView.isUserInteractionEnabled = true
        self.view.addSubview(homeUserView)
        setUpSubView()
        
        statuses[Constants.statusChanting] = NSMutableDictionary()
        statuses[Constants.statusOnline] = NSMutableDictionary()
        statuses[Constants.statusOffline] = NSMutableDictionary()
        
        FIRDatabase.database().reference().child("users").queryOrdered(byChild: "prayers").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as! NSDictionary
                if value["prayers"] != nil {
                    let key = snapshot.key
                    let array = value["prayers"] as! NSDictionary
                    for (_,element) in array {
                        let prayer = element as! NSDictionary
                        if Bool(prayer.value(forKey: "shareWithFriends") as! NSNumber) {
                            if self.prayers[key] == nil {
                                self.prayers[key] = []
                            }
                            self.prayers[key]?.append(prayer.value(forKey: "title") as! String)
                        }
                    }
                }
            }
        })
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
        if tableView == self.tableView {
            let uid = self.friends[indexPath.row]["uid"] as! String
            let name = self.friends[indexPath.row]["name"] as! String
            var status = Constants.statusOffline
            if self.statuses[Constants.statusChanting]?.object(forKey: uid) != nil {
                status = Constants.statusChanting
            } else if self.statuses[Constants.statusOnline]?.object(forKey: uid) != nil {
                status = Constants.statusOnline
            }
            setSubView(uid: uid, name: name, status: status)
            showSubView()
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.friends.count;
        } else {
            return self.prayers.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath) as! MainCell
            let uid = self.friends[indexPath.row]["uid"] as! String
            let name = self.friends[indexPath.row]["name"] as! String
            let g = self.goal[uid]
            let gI = self.goalInterval[uid]
            var status = Constants.statusOffline
            cell.untilLabel.isHidden = true
            cell.goalLabel.isHidden = true
            cell.profileImage.layer.borderWidth = 1.0
            cell.profileImage.layer.borderColor = UIColor.lightGray.cgColor
            cell.profileImage.layer.cornerRadius = 0.5 * cell.profileImage.bounds.size.width
            cell.profileImage.layer.masksToBounds = true
            
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
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = homePrayers[indexPath.row]
            return cell
        }
    }
    
    func setUpSubView() {
        homeUserView.isHidden = true
        homeUserView.layer.cornerRadius = 13.0
        homeUserView.layer.borderWidth = 1.0
        homeUserView.layer.borderColor = UIColor.lightGray.cgColor
        
        modalShadowView.isHidden = true
        
        closeButton.layer.cornerRadius = 5.0
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.borderColor = Constants.timerBlue.cgColor
        
        imageView.layer.cornerRadius = 10.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.masksToBounds = true
        
        chantButton.layer.cornerRadius = 5.0
        chantButton.layer.borderWidth = 1.0
        chantButton.layer.borderColor = Constants.timerBlue.cgColor
        chantButton.layer.masksToBounds = true
        
        cheerButton.layer.cornerRadius = 5.0
        cheerButton.layer.borderWidth = 1.0
        cheerButton.layer.borderColor = Constants.timerBlue.cgColor
        cheerButton.layer.masksToBounds = true
    }
    
    func hideSubView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.homeUserView.alpha = 0.0
            self.modalShadowView.alpha = 0.0
        }) { (bool) in
            self.homeUserView.isHidden = true
            self.modalShadowView.isHidden = true
        }
    }
    
    
    func showSubView() {
        self.homeUserView.alpha = 0.0
        self.modalShadowView.alpha = 0.0
        homeUserView.isHidden = false
        modalShadowView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.homeUserView.alpha = 1.0
            self.modalShadowView.alpha = 0.4
        })
    }
    
    func setSubView(uid: String, name: String, status: String) {
        nameLabel.text = name
        chantStatus.updateStatus(status: status)
        homePrayers = []
        if prayers[uid] != nil {
            homePrayers = prayers[uid]!
        }
        homeUserTableView.reloadData()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        hideSubView()
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if modalShadowView.isHidden {
            hideSubView()
        } else {
            showSubView()
        }
    }
}
