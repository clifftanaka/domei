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

    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincell", for: indexPath) as! MainCell
        
        return cell
    }
}
