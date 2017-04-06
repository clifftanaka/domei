//
//  AddFriendViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/06.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var friends : [NSDictionary] = []
    var filteredFriends : [User] = []
    var everyone : [User] = []
    var resultsSearchController = UISearchController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.resultsSearchController = UISearchController(searchResultsController: nil)
        self.resultsSearchController.searchResultsUpdater = self
        
        self.resultsSearchController.dimsBackgroundDuringPresentation = false
        self.resultsSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultsSearchController.searchBar
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let authUser = FIRAuth.auth()!.currentUser!
        everyone = []
        FIRDatabase.database().reference().child("users").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            if snapshot.exists() && snapshot.key != authUser.uid {
                let dic = snapshot.value as! NSDictionary
                let fbUser = dic["user"] as! NSDictionary
                let user = User()
                user.id = snapshot.key
                user.name = fbUser["name"] as! String
                user.onlineStatus = fbUser["onlineStatus"] as! String
                self.everyone.append(user)
            }
        })
    }
    
    @IBAction func dontTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addfriendviewcell", for: indexPath) as! AddFriendViewCell
        
        if self.resultsSearchController.isActive {
            cell.nameLabel?.text = self.filteredFriends[indexPath.row].name
            cell.uid = self.filteredFriends[indexPath.row].id
            cell.name = self.filteredFriends[indexPath.row].name
            var exists = false
            for i in 0..<self.friends.count {
                let dic = self.friends[i] as NSDictionary
                if (dic.value(forKey: "uid") as! String) == cell.uid {
                    exists = true
                    continue
                }
            }
            cell.updateButton(isFriend: exists)
        }
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredFriends.removeAll(keepingCapacity: false)
        
        if searchController.searchBar.text! != "" {
            self.filteredFriends = self.everyone.filter() {
                
                return $0.name.hasPrefix(searchController.searchBar.text!)
            }
        }
        
        self.tableView.reloadData()
    }
    
}
