//
//  CloudKitManager.swift
//  TODO
//
//  Created by Hesham on 5/23/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import CloudKit
import CoreData

public class CloudKitManager {
    
    // singelton object
    public static let shared = CloudKitManager()
    // zone id
    public var zoneID: CKRecordZoneID?
    public var customeZone: CKRecordZone
    
    private init() {
        customeZone = CKRecordZone(zoneName: "note-zone")
        zoneID = customeZone.zoneID
    }
    // MARK: Create Custome Zone
    // Create a custom zone to contain our note records. We only have to do this once.
    private func createZone(completion: @escaping (Error?) -> Void) {
        let recordZone = CKRecordZone(zoneID: self.zoneID!)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone], recordZoneIDsToDelete: [])
        operation.modifyRecordZonesCompletionBlock = { _, _, error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
        operation.qualityOfService = .utility
        let container = CKContainer.default()
        let db = container.privateCloudDatabase
        db.add(operation)
    }
    
    // MARK: upload changes to iCloud
    public func uploadChangedObjects(savedIDs: [NSManagedObjectID]? , deletedIDs: [CKRecordID]?, completion: @escaping (Error?) -> Void) {
        
        var fetchedObjects = [NSManagedObject]()
        var fetchedRecords = [CKRecord]()
        
        //TODO: fetch core data objects using objectsID(savedIDs)
        if let savedIDs = savedIDs {
            for id in savedIDs {
                if let fetchedObject = DataController.shared.retrieveObject(using: id, context: DataController.shared.viewContext) {
                    
                    // appened object to array
                    fetchedObjects.append(fetchedObject)
                }
                
            } // end of loop
        }
        
        //TODO: convert those objects to CKRecord using managedObjectToRecord()
        if fetchedObjects.count > 0 {
            for object in fetchedObjects {
                if let record = (object as? CloudKitManagedObject)?.managedObjectToRecord() {
                    // appened record to array
                    fetchedRecords.append(record)
                }
            }
        }
        //TODO: create CKModifyRecordsOpeartion to upload those records
        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: fetchedRecords, recordIDsToDelete: deletedIDs)
        // block of operation
        modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, error in
            
            guard error == nil else {
                print("there is an error in modify operation")
                guard let ckerror = error as? CKError else {
                    completion(error)
                    return
                }
                if ckerror.code == .partialFailure {
                    // This is a multiple-issue error. Check the underlying array
                    // of errors to see if it contains a match for the error in question.
                    print("partial failure error!!!")
                    guard let errors = ckerror.partialErrorsByItemID else {
                        completion(error)
                        return
                    }
                    for (_, error) in errors {
                        if let currentError = error as? CKError {
                            if currentError.code == CKError.zoneNotFound {
                                self.createZone() { error in
                                    guard error == nil else {
                                        completion(error)
                                        return
                                    }
                                    // Call save after creating the zone                                  
                                    self.uploadChangedObjects(savedIDs: savedIDs, deletedIDs: deletedIDs, completion: completion)
                                    return
                                }
                                print("Zone Not Found Error")
                                return
                            }
                        }
                    }
                }
                completion(error)
                return
            }
            // The record has been saved without errors
            completion(nil)
        }
        
        let container = CKContainer.default()
        let privateDataBase = container.privateCloudDatabase
        privateDataBase.add(modifyRecordsOperation)
        // test
        print("CKModifyRecordsOperation is added !!!!")
        
    }
    
    // update local records
    public func updateLocalRecords(changedRecords: [CKRecord], deletedRecordIDs: [CKRecordID]) {
        DataController.shared.updateContext.perform {
            let changedRecordNames = changedRecords.map { $0.recordID.recordName }
            let deletedRecordNames = deletedRecordIDs.map { $0.recordName }
            // TODO: delete objects
                self.deleteObjects(for: deletedRecordNames)
            // TODO: update objects
                self.updateObjects(for: changedRecordNames, changedRecords: changedRecords)
            // TODO: save update context
            DataController.shared.saveUpdateContext()
        }
    }
    
    //MARK: update records using fetched from iCloud
    public func updateObjects(for changedRecordNames: [String], changedRecords: [CKRecord] ) {
        // TODO: fetch from core data
        for i in 0...changedRecordNames.count-1 {
            
            let recordName = changedRecordNames[i]
            let changedRecord = changedRecords[i]
            
            if let dotIndex = recordName.index(of: ".") {
                let entityName = recordName.substring(to: dotIndex)
                
                // fetch from core data
                if let object = DataController.shared.retrieveObject(from: recordName, context: DataController.shared.viewContext) as? CloudKitManagedObject {
                    
                    // check for lastUpdate
                    if (changedRecord["lastUpdate"] as! NSDate).timeIntervalSinceNow > (object.lastUpdate?.timeIntervalSinceNow)! {
                        // the changedRecord is recent
                        object.updateWithRecord(changedRecord)
                    }
                
                } else {
                    // create a new object and update it
                    let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: DataController.shared.updateContext)
                    
                    if let cloudManagedObject = newObject as? CloudKitManagedObject {
                        cloudManagedObject.updateWithRecord(changedRecord)
                    }
                }
        }
    } // end of loop
    }
    
    // MARK: delete records using fetched records from iCloud
    public func deleteObjects(for deletedRecordNames: [String] ) {
        // TODO: fetch from CoreData then delete
        for deletedRecord in deletedRecordNames {
            if let object =  DataController.shared.retrieveObject(from: deletedRecord, context: DataController.shared.viewContext) {
                DataController.shared.viewContext.delete(object)
            }
        }
    }
    
    // MARK: persist failed upload records
    public func persistUploadFailedRecords(recordNames: [String]) {
        let cacheContext = DataController.shared.cacheContext
        cacheContext.perform {
            for name in recordNames {
                let record = CachedRecord(context: cacheContext)
                record.recordName = name
                record.modificationDate = Date() as NSDate
            }
            DataController.shared.saveCacheContext()
        }
    }
    // MARK: Clear cacheRecords
    public func clearCachedRecords(recordNames: [String]) {
        let cacheContext = DataController.shared.cacheContext
        cacheContext.perform {
            for recordName in recordNames {
                if let objects = DataController.shared.retrieveObjects(from: recordName, context: cacheContext) {
                    // delete objects
                    for object in objects {
                        cacheContext.delete(object)
                    }
                }
            } // end of loop
            DataController.shared.saveCacheContext()
            
            // TODO: upload failed records
            // sample
//            let cachedRecords = CoreDataOperation.objectsForEntity(entityName: CDConstants.Entity.CachedRecords, context: cacheContext, filter: nil, sort: nil)
//            if let objects = cachedRecords, objects.count > 0 {
//                self.uploadCachedRecords()
//            }
        }
    }
    
    // MARK: Save records to iCloud
    
    // TODO: Upload Failed Records
    public func uploadFailedRecords() {
        
        let cachedObjects = DataController.shared.fetchCachedObjects()
        var recordsToSave: [CKRecord] = []
        var recordIDsToDelete: [CKRecordID] = []
        
        if cachedObjects.count > 0 {
            let recordNames = cachedObjects.map{$0.recordName!}
            let uniqueNames = Array(Set(recordNames))
            
            
            
            let context = DataController.shared.cacheContext
            
            for recordName in uniqueNames {
                let managedObject = DataController.shared.retrieveObject(from: recordName, context: context)
                if let cloudManagedObject = managedObject as? CloudKitManagedObject {
                    let record = cloudManagedObject.managedObjectToRecord()
                    recordsToSave.append(record)
                } else {
                    let zoneID = CloudKitManager.shared.customeZone.zoneID
                    let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
                    recordIDsToDelete.append(recordID)
                }
            }
        }
        // TODO: use CKModefyRecordOperation
        print("Creating CKModifyRecordOperation for uploading failed records")
        
        modifyRecordOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
    }
    
    // MARK: Modify Record Operation
    public func modifyRecordOperation(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecordID]) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        // block of operation
        modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, error in
            
            guard error == nil else {
                guard let ckerror = error as? CKError else {
//                    completion(error)
                    return
                }
                if ckerror.code == .partialFailure {
                    // This is a multiple-issue error. Check the underlying array
                    // of errors to see if it contains a match for the error in question.
                    guard let errors = ckerror.partialErrorsByItemID else {
//                        completion(error)
                        return
                    }
                    for (_, error) in errors {
                        if let currentError = error as? CKError {
                            if currentError.code == CKError.zoneNotFound {
                                self.createZone() { error in
                                    guard error == nil else {
//                                        completion(error)
                                        return
                                    }
                                    // Call save after creating the zone
                                    self.modifyRecordOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
                                    return
                                }
                                print("Zone Not Found Error")
                                return
                            }
                        }
                    }
                }
//                completion(error)
                return
            }
            // The record has been saved without errors
//            completion(nil)
        }
        
        let container = CKContainer.default()
        let privateDataBase = container.privateCloudDatabase
        privateDataBase.add(modifyRecordsOperation)
        // test
        print("CKModifyRecordsOperation is added !!!!")
    }
}
