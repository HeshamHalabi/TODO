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
import SwiftDate


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
        
        // data source and delegate
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // fetch due today tasks
        try? fetchTodayTasks()
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
        
        do {
            try fetchTodayTasks()
        } catch {
            completionHandler(NCUpdateResult.failed)
            return
        }
        
        if todayTasks.count == 0 {
            // no tasks to show
            completionHandler(NCUpdateResult.noData)
            return
        }
        
        tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: fetch Today tasks
    func fetchTodayTasks() throws {
        
        let now = Date()
        let startOfDay = now.startOfDay as NSDate
        let endOfDay = now.endOfDay as NSDate
        let todayPredicate =  NSPredicate(format: "dueDate >= %@ AND dueDate <= %@ ", startOfDay, endOfDay)
        
        let notDonePredicate = NSPredicate(format: "%K == NO", #keyPath(Task.isDone))
        
//        let notDonePredicate = NSPredicate(format: "%K == false", #keyPath(Task.isDone))
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [notDonePredicate, todayPredicate])
        // perfrm fetch
        do {
            todayTasks = try dataController.viewContext.fetch(fetchRequest)
            print("number of tasks fetched: \(todayTasks.count)")
        } catch let error as NSError {
            fatalError("Couldnt read from core data in Today Extension")
            throw error
        }
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
        
        print("Cell returned for the table view")
        return cell
    }
}
