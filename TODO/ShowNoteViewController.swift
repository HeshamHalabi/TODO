//
//  ShowNoteViewController.swift
//  TODO
//
//  Created by Hesham on 5/3/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class ShowNoteViewController: UIViewController {

    var note: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // test reciving a note
        if let note = note {
            print("Successfully receiving a note: \(note)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
