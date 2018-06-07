//
//  Category+CoreDataClass.swift
//  TODO
//
//  Created by Hesham on 5/23/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Category)
public class Category: NSManagedObject, CloudKitManagedObject {
    
    
    
    
    
    var recordType: String {
        return "Category"
    }
    
    func managedObjectToRecord() -> CKRecord {
        
        guard let name = name, let lastUpdate = lastUpdate else {
            fatalError("Required properties for recordData?t")
        }
        
        let categoryRecord = cloudKitRecord()
        categoryRecord["name"] = name as CKRecordValue
        categoryRecord["lastUpdate"] = lastUpdate as CKRecordValue
        
        return categoryRecord
    }
    
    func updateWithRecord(_ record: CKRecord) {
        
        name = record["name"] as? String
        lastUpdate = record["lastUpdate"] as? NSDate
        recordName = record.recordID.recordName
        recordID = NSKeyedArchiver.archivedData(withRootObject: record.recordID) as NSData
    }

}
