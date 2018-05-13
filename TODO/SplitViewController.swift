//
//  SplitViewController.swift
//  TODO
//
//  Created by Hesham on 5/7/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    // flag for collapsing the detail view controller when first lanuched
    private var collapseDetailViewController = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        // display mode
        self.preferredDisplayMode = .allVisible
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UISplitViewControllerDelegate
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
    
    // dismiss split view
    func dismissSplitView() {
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

    

