//
//  PrayerViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/13.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PrayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var prayers : [[Prayer]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.prayers.append([])
        self.prayers.append([])
        
        let user = FIRAuth.auth()!.currentUser!
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let prayer = PrayerService.getPrayerFromSnapshop(snapshot: snapshot)
                
                if prayer.isCompleted {
                    self.prayers[1].append(prayer)
                } else {
                    self.prayers[0].append(prayer)
                }
                
                self.tableView.reloadData()
            }
        })
        FIRDatabase.database().reference().child("users").child(user.uid).child("prayers").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                let prayer = PrayerService.getPrayerFromSnapshop(snapshot: snapshot)
                if prayer.isCompleted {
                    self.prayers[1].append(prayer)
                    for (index, element) in self.prayers[0].enumerated() {
                        if element.key == snapshot.key {
                            self.prayers[0].remove(at: index)
                        }
                    }
                } else {
                    self.prayers[0].append(prayer)
                    for (index, element) in self.prayers[1].enumerated() {
                        if element.key == snapshot.key {
                            self.prayers[1].remove(at: index)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Prayers"
        } else {
            return "Completed Prayers"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if prayers[section].count == 0 {
            return 1
        }
        return prayers[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (prayers[indexPath.section].count == 0) {
            let cell = UITableViewCell()
            cell.textLabel?.text = "no prayers 🙃"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "prayerviewcell", for: indexPath) as! PrayerViewCell
        let prayer = prayers[indexPath.section][indexPath.row] as Prayer
        cell.key = prayer.key
        cell.titleLabel.text = prayer.title
        print(prayer.totalChanted)
        cell.hoursLabel.text = String(Util.getHoursFromInterval(interval: prayer.totalChanted))
        cell.minsLabel.text = String(Util.getMinsFromInterval(interval: prayer.totalChanted))
        if prayer.targetDate == nil {
            cell.targetDateLabel.text = "not set 🤘"
        } else {
            cell.targetDateLabel.text = Util.getMediumFromDate(date: prayer.targetDate!)
        }
        if prayer.isCompleted {
            cell.setIsComplete()
        } else {
            cell.setIsIncomplete()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if prayers[indexPath.section].count > 0 {
            self.performSegue(withIdentifier: "newPrayerSegue", sender: prayers[indexPath.section][indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            PrayerService.removePrayer(key: prayers[indexPath.section][indexPath.row].key)
            prayers[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }


    @IBAction func newPrayerTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "newPrayerSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newPrayerSegue" {
            let nextVC = segue.destination as! NewPrayerViewController
            if sender == nil {
                nextVC.prayer = nil
            } else {
                nextVC.prayer = sender as? Prayer
            }
        }
    }
}
