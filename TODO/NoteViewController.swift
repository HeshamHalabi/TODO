//
//  NoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

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
    
}
