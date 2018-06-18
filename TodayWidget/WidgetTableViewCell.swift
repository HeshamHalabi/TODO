//
//  WidgetTableViewCell.swift
//  TodayWidget
//
//  Created by Hesham on 6/16/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData
import CoreDataCloudKit

class WidgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    
    var task: Task! {
        didSet {
            title.text = task.title
            completed = task.isDone
            statusButton.isEnabled = true
        }
    }
    
    var completed: Bool!
    var completedTasks = [String]() // save the task identifier
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        statusButton.isEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func taskDone(_ sender: UIButton) {
        completed = true
        statusButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        // TODO: make changes to task - isDone
        task.isDone = true
        print("task marked done")
        guard let managedContext = task.managedObjectContext else { return }
        do {
            try managedContext.save()
            print("Changes saved to context!")
        } catch let error as NSError {
            fatalError("Error during core data save in Widget: \(error.localizedDescription)")
        }
    }
    
}



