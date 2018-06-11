//
//  NoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController {

    // data controller
    var dataController: DataController!
    
    var category: Category! 
    
    // Add or Edit
    var isEdit = false
    
    // item to edit
    var taskToEdit: Task? 
    

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var reminderDateSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // hide date picker
        dueDatePicker.isEnabled = false
        reminderDatePicker.isEnabled = false
        
        // check if editing
        
        if let task = taskToEdit {
            // isEdit
            isEdit = true
            // category
            category = task.category
            // title
            if let title = task.title {
                titleTextField.text = title
            }
            // other optional fields
            if let details = task.details {
                detailsTextView.text = details
            }
            if let dueDate = task.dueDate {
                dueDatePicker.isEnabled = true
                dueDateSwitch.isOn = true
                dueDatePicker.date = dueDate as Date
            }
            if let reminderDate = task.reminderDate {
                reminderDatePicker.isEnabled = true
                reminderDateSwitch.isOn = true
                reminderDatePicker.date = reminderDate as Date
            }
        }
        
        // TODO: Set title of the bar
        // set title
//        title = isEdit ? "Edit Task" : "Add New Task"
      
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

    // hide/show date picker
    @IBAction func hideDueDatePicker(_ sender: UISwitch) {
        if sender.isOn {
            dueDatePicker.isEnabled = true
        } else {
            dueDatePicker.isEnabled = false
        }
    }
    
    @IBAction func hideReminderDate(_ sender: UISwitch) {
        if sender.isOn {
            reminderDatePicker.isEnabled = true
        } else {
            reminderDatePicker.isEnabled = false
        }
    }
    
    // dismiss view controller
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        // TODO: Create new note or save edits
        var newTask: Task?
        if let title = titleTextField.text, !title.isEmpty {
            
            // create new or edit
            if let task = taskToEdit {
                newTask = task
                newTask?.lastUpdate = Date() as! NSDate
            } else {
                newTask = Task(context: dataController.viewContext)
                //TODO: prepare for cloudkit and generate recordName and Record ID
                newTask?.prepareForCloudKit()
                newTask?.lastUpdate = Date() as! NSDate
            }
            
            newTask?.category = category
            newTask?.title = title
            // get other fields
            if let details = detailsTextView.text {
                newTask?.details = details
            }
            if dueDatePicker.isEnabled {
                // TODO: check the effect of converting to NSDate
                newTask?.dueDate = dueDatePicker.date as NSDate
            } else {
                // to remove previous dates
                newTask?.dueDate = nil
            }
            if reminderDatePicker.isEnabled {
                newTask?.reminderDate = reminderDatePicker.date as NSDate
            } else {
                // to remove previous dates
                newTask?.reminderDate = nil
            }
            
            // TODO: Save changes in context and dismiss
            
//            try? dataController.viewContext.save()
            dataController.saveContext()
            dismiss(animated: true, completion: nil)
 
        } else {
            // TODO: animate title field
            
            titleTextField.center.x = titleTextField.center.x - 20.0
            
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 60, options: [.curveEaseInOut], animations: {
                self.titleTextField.center.x = self.titleTextField.center.x + 20
            }) { (_) in
                // 
            }
        }
        
    }
}
