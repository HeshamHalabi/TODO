//
//  NotesViewController.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import CoreData
import CoreDataCloudKit

class TaskViewController: UITableViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    // data controller
    var dataController: DataController!
    
    // category
    var category: Category!
    
    // MARK: fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        // fetch request
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "category == %@", category)
        fetchRequest.predicate = predicate
        // sort descriptors
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // fetch request batch size
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(category.name)-tasks")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
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

        // custom transitions
        navigationController?.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // fetch using fetchedResultsController
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

   
    @IBAction func returnToCategory(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
        // try to dismiss SplitVC
        if let splitVC = splitViewController as? SplitViewController{
            splitVC.dismissSplitView()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let task = fetchedResultsController.object(at: indexPath)
        // Configure the cell
        cell.textLabel?.text  = task.title
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
            let taskToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(taskToDelete)
            try? dataController.viewContext.save()
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
                
                // transition
                vc.transitioningDelegate = self
            }
        } else if segue.identifier == "ShowNote" {
            if let navController = segue.destination as? UINavigationController, let vc = navController.viewControllers.last as? ShowTaskViewController {
                if let selectedIndex = tableView.indexPathForSelectedRow {
                    vc.task = fetchedResultsController.object(at: selectedIndex)
                    // passing dataController
                    vc.dataController = dataController
                    
                    
                }
            }
        }
        
    }
    
    // MARK: Custom Transitions
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentAnimator()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissAnimator()
    }
    // Navigation Controller
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let  customNavigationAnimator = CustomNavigationAnimator()
        
        if operation == .push {
            customNavigationAnimator.pushing = true
        }
        
        return customNavigationAnimator
    }
    
    // MARK: deinit
    deinit {
        fetchedResultsController.delegate = nil
    }
    
}

// MARK: Extension for fetchedResultsControllerDelegate
extension TaskViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                fatalError("New index path is nil")
            }
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath,
                let indexPath = indexPath else {
                    fatalError("Index path or new index path is nil?")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
