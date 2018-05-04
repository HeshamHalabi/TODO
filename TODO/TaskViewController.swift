//
//  NotesViewController.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UITableViewController {

    // data controller
    var dataController: DataController!
    
    // category
    var category: Category!
    
//    // new note added
//    var newNote: Task? {
//        didSet {
//            // TODO: Add note to array and dave to context
//            tasks.append(newNote!)
//            // reload table view
//            tableView.reloadData()
//        }
//    }
    // test of array for filling table
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // MARK: fetch tasks from core data
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            tasks = result
        }
        // reload table view
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text  = tasks[indexPath.row].title
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // TODO: delete from core data
            let taskToDelete = tasks[indexPath.row]
            dataController.viewContext.delete(taskToDelete)
            try? dataController.viewContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
   

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewNote" {
            if let vc = segue.destination as? AddTaskViewController {
                vc.isEdit = false
                vc.category = category
                vc.dataController = dataController
            }
        } else if segue.identifier == "ShowNote" {
            if let vc = segue.destination as? ShowTaskViewController {
                if let selectedIndex = tableView.indexPathForSelectedRow {
                    vc.task = tasks[selectedIndex.row]
                }
            }
        }
        
    }
    

    
}
