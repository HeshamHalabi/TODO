//
//  Task+CoreDataClass.swift
//  TODO
//
//  Created by Hesham on 6/16/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Task)
public class Task: NSManagedObject, CloudKitManagedObject {

    var recordType: String {
        return "Task"
    }
    
    func managedObjectToRecord() -> CKRecord {
        
        guard let title = title, let category = taskCategory, let lastUpdate = lastUpdate else {
            fatalError("Required properties for record not set")
        }
        
        let taskRecord = cloudKitRecord()
        taskRecord["title"] = title as CKRecordValue
        // details
        taskRecord["details"] = details as CKRecordValue?
        // dueDate
        taskRecord["dueDate"] = dueDate as CKRecordValue?
        // reminderDate
        taskRecord["reminderDate"] = reminderDate as CKRecordValue?
        // isDone
        taskRecord["isDone"] = isDone as CKRecordValue?
        // last update
        taskRecord["lastUpdate"] = lastUpdate as CKRecordValue
        
        let categoryID = category.cloudKitRecordID()
        // reference
        let categoryReference = CKReference(recordID: categoryID, action: .deleteSelf)
        taskRecord["categoryReference"] = categoryReference
        
        return taskRecord
    }
    
    func updateWithRecord(_ record: CKRecord) {
        
        title = record["title"] as? String
        details = record["details"] as? String
        dueDate = record["dueDate"] as? NSDate
        isDone = record["isDone"] as! Bool
        reminderDate = record["reminderDate"] as? NSDate
        lastUpdate = record["lastUpdate"] as? NSDate
        
        if let categoryReference = record["categoryReference"] as? CKReference {
            
            let categoryName = categoryReference.recordID.recordName
            // TODO: Check if the category exists or not
            if let _category = DataController.shared.fetchCategory(categoryName: categoryName) {
                
                taskCategory = _category
            } else {
                
                // create new category
                
                if let _newCategory = NSEntityDescription.insertNewObject(forEntityName: "TaskCategory", into: DataController.shared.updateContext) as? TaskCategory {
                    _newCategory.recordName = categoryName
                    taskCategory = _newCategory
                }
                
            }
            
        }
        
        recordName = record.recordID.recordName
        recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData
    }
}
