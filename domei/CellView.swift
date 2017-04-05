//
//  CellView.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/30.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CellView: JTAppleDayCellView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var cellViewHourLabel: UILabel!
    @IBOutlet weak var cellViewMinLabel: UILabel!
    @IBOutlet weak var cellViewColonLabel: UILabel!
    @IBOutlet weak var clockImage: UIImageView!
    
    func hideTime() {
        cellViewHourLabel.isHidden = true
        cellViewMinLabel.isHidden = true
        cellViewColonLabel.isHidden = true
        clockImage.isHidden = true
    }
    
    func showTime() {
        cellViewHourLabel.isHidden = false
        cellViewMinLabel.isHidden = false
        cellViewColonLabel.isHidden = false
        clockImage.isHidden = false
    }
}
