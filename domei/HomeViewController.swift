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
    
    var chantingCount : Int = 0
    var friends : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRDatabase.database().reference().child("users").child("XHaMiFEsE4ZFijYbTyPKLuDyyFn1").child("user").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                //let record = snapshot.value as! NSDictionary
                //let user = record["user"] as! NSDictionary
                //let status = user["status"] as! String
                print(snapshot)
                let status = snapshot.value as! String
                if status == "chanting" {
                    self.chantingCount += 1
                    self.allPeople.text = "\(self.chantingCount)"
                } else if status == "online" {
                    self.chantingCount -= 1
                    self.allPeople.text = "\(self.chantingCount)"
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath) as! MainCell
        
        return cell
    }
    
    @IBAction func tapped(_ sender: Any) {
        FIRDatabase.database().reference().child("users").child("XHaMiFEsE4ZFijYbTyPKLuDyyFn1").child("user").child("status").observe(FIRDataEventType.childChanged, with: { (snapshot) in
            print(snapshot)
            if !snapshot.exists() {
                if (snapshot.value as! String) == "chanting" {
                    self.chantingCount += 1
                } else {
                    self.chantingCount -= 1
                }
                print(snapshot.value as! String)
                self.allPeople.text = "\(self.chantingCount)"
            }
        })
    }
}
