//
//  CustomCell.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/04/03.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var finishedAtLabel: UILabel!
    @IBOutlet weak var medal1: UIImageView!
    @IBOutlet weak var medal2: UIImageView!
    @IBOutlet weak var medal3: UIImageView!
    @IBOutlet weak var medal4: UIImageView!
    @IBOutlet weak var medal5: UIImageView!
    @IBOutlet weak var medal6: UIImageView!
    @IBOutlet weak var medal7: UIImageView!
    @IBOutlet weak var medal8: UIImageView!
    @IBOutlet weak var medal9: UIImageView!
    @IBOutlet weak var medal10: UIImageView!
    @IBOutlet weak var medal11: UIImageView!
    @IBOutlet weak var medal12: UIImageView!
    @IBOutlet weak var medal13: UIImageView!
    @IBOutlet weak var medal14: UIImageView!
    @IBOutlet weak var medal15: UIImageView!
    @IBOutlet weak var medal16: UIImageView!
    @IBOutlet weak var medal17: UIImageView!
    @IBOutlet weak var medal18: UIImageView!
    @IBOutlet weak var medal19: UIImageView!
    @IBOutlet weak var medal20: UIImageView!
    @IBOutlet weak var medal21: UIImageView!
    @IBOutlet weak var medal22: UIImageView!
    @IBOutlet weak var medal23: UIImageView!
    @IBOutlet weak var medal24: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func resetMedals() {
        for i in 0..<24 {
            getMedal(index: UInt8(i)).image = UIImage(named: "gold-medal")
            getMedal(index: UInt8(i)).isHidden = true
        }
    }
    
    func showMedal(ts: String, index: UInt8, type: UInt8) {
        // show medal
        getMedal(index: index).isHidden = false
        // 1/4 medal
        if type == 1 {
            getMedal(index: index).image = UIImage(named: "gold-medal-1")
        }
        // 2/4 medal
        if type == 2 {
            getMedal(index: index).image = UIImage(named: "gold-medal-2")
        }
        // 3/4 medal
        if type == 3 {
            getMedal(index: index).image = UIImage(named: "gold-medal-3")
        }
    }
    
    func getMedal (index: UInt8) -> UIImageView {
        let medals : [UIImageView] = [medal1, medal2, medal3, medal4, medal5, medal6, medal7, medal8, medal9, medal10, medal11, medal12, medal13, medal14, medal15, medal16, medal17, medal18, medal19, medal20, medal21, medal22, medal23, medal24]
        let index = Int(index)
        return index < medals.count ? medals[Int(index)] : UIImageView()
    }
}
