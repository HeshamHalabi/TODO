//
//  ReminderCell.swift
//  TODO
//
//  Created by Hesham on 6/29/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import Foundation
import UIKit
import CoreDataCloudKit
import Flurry_iOS_SDK

class ReminderCell: UITableViewCell {
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var title: UILabel!
    
    var task: Task! {
        didSet {
            title.text = task.title
            setDone()
        }
    }
    
    
    @IBAction func getTaskDone(_ sender: UIButton) {
        
        task.isDone = !task.isDone
        
        setDone()
        DataController.shared.saveContext()
    }
    
    func setDone() {
        
        doneButton.backgroundColor = UIColor.cyan
        
        if task.isDone {
            doneButton.setTitle("✓", for: .normal)
            // done task - add analytics
            Flurry.logEvent("Done-Task")
        } else {
            doneButton.setTitle("", for: .normal)
        }
        
        
    }
}
