//
//  ShowNoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/3/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreDataCloudKit

class ShowTaskViewController: UIViewController {

    var task: Task?
    
    var dataController: DataController?
    
    // outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var reminderDateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation item buttom,  displayModeButtonItem
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        // right button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTask))
        
        // test reciving a note
        if let task = task {
            print("Successfully receiving a note: \(task.title)")
        }
        // filling the view with task data
        titleLabel?.text = task?.title
        if let details = task?.details {
            descriptionTextView?.text = details
            // height constraint
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120.0).isActive = true
        } /* else {
            descriptionTextView.isHidden = true
        } */
        if let dueDate = task?.dueDate {
            dueDateLabel?.text = "\(dueDate)"
        }
        if let reminderDate = task?.reminderDate {
            reminderDateLabel?.text = "\(reminderDate)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc
    func editTask() {
        // test
        print("editTask tapped")
        performSegue(withIdentifier: "EditTask", sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditTask" {
            if let vc = segue.destination as? AddTaskViewController {
                vc.taskToEdit = task
                vc.dataController = dataController
                print("task passed for editing")
            }
        }
    }
   

}
