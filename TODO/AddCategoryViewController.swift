//
//  AddCategoryViewController.swift
//  TODO
//
//  Created by Hesham on 5/12/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData
import CoreDataCloudKit

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
            let newCategory = TaskCategory(context: dataController.viewContext)
            newCategory.name = title
            
            // TODO: Prepare for cloudKit
            newCategory.prepareForCloudKit()
            newCategory.lastUpdate = Date() as NSDate
            // save context
            // TODO : replace with saveContext
            dataController.saveContext()
//            try? dataController.viewContext.save()
            
            dismiss(animated: true, completion: nil)
            
        } else {
            // TODO: Animate the empty text field
            
            // before animation
            categorTitleTextField.center.x = categorTitleTextField.center.x - 20.0
            
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 60, options: [.curveEaseInOut], animations: {
                self.categorTitleTextField.center.x = self.categorTitleTextField.center.x + 10.0
            }) { (_) in
                // TODO : return to origin
            }
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
