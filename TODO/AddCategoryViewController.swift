//
//  AddCategoryViewController.swift
//  TODO
//
//  Created by Hesham on 5/12/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryViewController: UIViewController {

    // data controller
    var dataController: DataController!
    
    
    @IBOutlet weak var categorTitleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        // TODO: Save category to Core Data
        if let title = categorTitleTextField.text, title.count > 0 {
            // create Category object and save
            let newCategory = Category(context: dataController.viewContext)
            newCategory.name = title
            
            // save context
            try? dataController.viewContext.save()
            
            dismiss(animated: true, completion: nil)
        }
        
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
