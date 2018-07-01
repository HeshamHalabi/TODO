//
//  TaskCell.swift
//  TODO
//
//  Created by Hesham on 6/29/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import Foundation
import UIKit
import CoreDataCloudKit
import Flurry_iOS_SDK

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var title: UILabel!
    
    var task: Task! {
        didSet {
            title.text = task.title
            setDone()
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        doneButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
//    }
    
    @IBAction func getTaskDone(_ sender: UIButton) {
    
        task.isDone = !task.isDone
        
        setDone()
        // save context
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
    
//    func saveContext() {
//        guard let managedContext = task.managedObjectContext else { return }
//        do {
//            try managedContext.save()
//            print("Changes saved to context!")
//        } catch let error as NSError {
//            fatalError("Error during core data save in Widget: \(error.localizedDescription)")
//        }
//    }
    
}
