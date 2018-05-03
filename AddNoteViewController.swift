//
//  NoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {

    // Add or Edit
    var isEdit = false
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // hide date picker
        dueDatePicker.isHidden = true
        reminderDatePicker.isHidden = true
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
            dueDatePicker.isHidden = false
        } else {
            dueDatePicker.isHidden = true
        }
    }
    
    @IBAction func hideReminderDate(_ sender: UISwitch) {
        if sender.isOn {
            reminderDatePicker.isHidden = false
        } else {
            reminderDatePicker.isHidden = true
        }
    }
    
    // dismiss view controller
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        // TODO: Create new note or save edits
        var newNote: Note?
        if !isEdit, let title = titleTextField.text, !title.isEmpty {
             newNote = Note(title: title)
            // get other fields
            if let details = detailsTextView.text {
                newNote?.details = details
            }
            if !dueDatePicker.isHidden {
                newNote?.dueDate = dueDatePicker.date
            }
            if !reminderDatePicker.isHidden {
                newNote?.reminderDate = reminderDatePicker.date
            }
            
            // pass the new note to the Notes View Controller
            if let presentingVC = presentingViewController as? UITabBarController {
                if let navVC = presentingVC.viewControllers?[0] as? UINavigationController {
                    print("\(navVC.description)")
                    if let lastVC = navVC.viewControllers.last as? NotesViewController {
                        print("\(lastVC.description)")
                        // pass the new note
                        lastVC.newNote = newNote?.title
                        dismiss(animated: true, completion: nil)
                    }
                }
                
            }
            
   
            
        }
        
    }
}
