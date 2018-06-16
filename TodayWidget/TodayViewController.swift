//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Hesham on 6/16/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreDataCloudKit
import CoreData


class TodayViewController: UIViewController, NCWidgetProviding {
    
    // table view outlet
    @IBOutlet weak var tableView: UITableView!
    
    // data controller
    let dataController = DataController.shared
    
    // array of todays tasks
    var todayTasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // set display mode
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: 280)
        } else {
            preferredContentSize = maxSize
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: fetch Today tasks
    func fetchTodayTasks() {
        
        
    }
    
}

// TableView datasource and delegate protocols
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todayTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WidgetTableViewCell
        
        let task = todayTasks[indexPath.row]
        
        cell.task = task
        
        return cell
    }
}
