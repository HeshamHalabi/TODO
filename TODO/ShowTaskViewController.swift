//
//  ShowNoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/3/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class ShowTaskViewController: UIViewController {

    var task: Task?
    
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
        
        // test reciving a note
        if let task = task {
            print("Successfully receiving a note: \(task.title)")
        }
        // filling the view with task data
        titleLabel?.text = task?.title
        if let details = task?.details {
            descriptionTextView.text = details
        }
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
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
