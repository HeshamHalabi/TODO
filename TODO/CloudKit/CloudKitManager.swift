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
    
    // subscribtion
    public static let subscriptionID = "cloudkit-note-changes"
    private let subscriptionSavedKey = "ckSubscriptionSaved"
    
    // server token
    private let serverChangeTokenKey = "ckServerChangeToken"
    
    private init() {
        customeZone = CKRecordZone(zoneName: "NoteZone")
        zoneID = customeZone.zoneID
    }
    // MARK: Create Custome Zone
    // Create a custom zone to contain our note records. We only have to do this once.
    private func createZone(completion: @escaping (Error?) -> Void) {
        let recordZone = CKRecordZone(zoneID: self.zoneID!)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone], recordZoneIDsToDelete: [])
        operation.modifyRecordZonesCompletionBlock = {[unowned self]  _, _, error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
//        operation.qualityOfService = .utility
        let container = CKContainer.default()
        let db = container.privateCloudDatabase
        db.add(operation)
    }
    
    // MARK: Create Subscribtion
    func creatSubscribtion() {
        // if saved before no need to save again
        let alreadySaved = UserDefaults.standard.bool(forKey: subscriptionSavedKey)
        guard !alreadySaved else {
            return
        }
        
        let subscription = CKRecordZoneSubscription(zoneID: CloudKitManager.shared.customeZone.zoneID, subscriptionID: CloudKitManager.subscriptionID)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let subscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        subscriptionOperation.modifySubscriptionsCompletionBlock = { [unowned self] (_, _, error) in
            if let error = error {
                NSLog("CloudKit ModifySubscriptions Error: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(true, forKey: self.subscriptionSavedKey)
                print("Subscription Created!")
            }
        }
        
        let container = CKContainer.default()
        let privateDataBase = container.privateCloudDatabase
        privateDataBase.add(subscriptionOperation)
    }
    
    // MARK: upload changes to iCloud
    public func uploadChangedObjects(savedIDs: [NSManagedObjectID]? , deletedIDs: [CKRecordID]?, completion: @escaping (Error?) -> Void) {
        
        
        var fetchedObjects = [NSManagedObject]()
        var fetchedRecords = [CKRecord]()
        
        var recordsName: [String] = []
        var deletedRecordsNames: [String] = []
        
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
                if let managedObject = object as? CloudKitManagedObject {
                    let recordName = managedObject.recordName
                    recordsName.append(recordName!)
                    
                    let record = managedObject .managedObjectToRecord()
                        // appened record to array
                        fetchedRecords.append(record)
                }
                
            }
        }
        
        // TODO: Get deleted records names
        if let deletedIds = deletedIDs {
            for recordId in deletedIds {
                let recordName = recordId.recordName
                deletedRecordsNames.append(recordName)
            }
        }
        
        // TODO: check reachability, if not persist fetchedObjects for upload failed.
        if Reachability.isConnectedToNetwork() {
            if isICloudContainerAvailable() {
                // TODO: getUploadFailed and add them to modifyRecordsOperation
                let (savedRecords, deletedRecordsIds) = getUploadFailedRecords()
                
                //TODO: create CKModifyRecordsOpeartion to upload those records
                modifyRecordOperation(recordsToSave: fetchedRecords + savedRecords, recordIDsToDelete: deletedIDs! + deletedRecordsIds)
            } else {
                print("Sign in to iCloud")
                persistUploadFailedRecords(recordNames: recordsName, deletedNames: deletedRecordsNames)
            }
        } else {
            // No connection, persist failed records
            persistUploadFailedRecords(recordNames: recordsName, deletedNames: deletedRecordsNames)
        }
        
        
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
            DataController.shared.saveContext()
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
    public func persistUploadFailedRecords(recordNames: [String], deletedNames: [String]) {
        
        print("Persist Failed Invoked!!!!!!")
        // TODO: Clear cached records with the same names then write the new ones
        // to prevent duplication of records
//        clearCachedRecords(recordNames: recordNames)
//        clearCachedRecords(recordNames: deletedNames)
        
        
        let cacheContext = DataController.shared.cacheContext
        cacheContext.perform {
            for name in recordNames {
                let record = CachedRecord(context: cacheContext)
                record.recordName = name
                record.modificationDate = Date() as NSDate
                record.isDelete = false
                
                // insert cached record
                cacheContext.insert(record)
                
                // test
                print("Inserted Cached Record : \(record.recordName!)")
            }
            
            for name in deletedNames {
                let record = CachedRecord(context: cacheContext)
                record.recordName = name
                record.modificationDate = Date() as NSDate
                record.isDelete = true
                
                // insert cached record
                cacheContext.insert(record)
                
                // test
                print("Inserted Cached Record : \(record.recordName!)")
            }
            
            
            DataController.shared.saveCacheContext()
        }
    }
    // MARK: Clear cacheRecords
    public func clearCachedRecords(recordNames: [String]) {
        
        print("Clear Cached Records Invoked!!!!!")
        
        // test - fetch all cached records
        let cacheContext = DataController.shared.cacheContext
        let fetchedObjects = DataController.shared.fetchCachedObjects()
        
        cacheContext.perform {
            for item in fetchedObjects {
                
                // test
                print("Fetched Record : \(item.recordName!)")
                
                if let recordName = item.recordName {
                    // compare recordName
                    if recordNames.contains(recordName) {
                        // delete the cached record
                        cacheContext.delete(item)
                        print("Delete CachedRecord : \(recordName)")
                    }
                }
            }
        } // end of cache perform operation
        
        DataController.shared.saveCacheContext()
        
        
//        cacheContext.perform {
//            for recordName in recordNames {
//                if let objects = DataController.shared.retrieveObjects(from: recordName, context: cacheContext) {
//                    // delete objects
//                    for object in objects {
//                        cacheContext.delete(object)
//                        print("Delete CachedRecord : \(recordName)")
//                    }
//                }
//            } // end of loop
//            DataController.shared.saveCacheContext()
//
//             //TODO: upload failed records
//             //sample
//            let cachedRecords = CoreDataOperation.objectsForEntity(entityName: CDConstants.Entity.CachedRecords, context: cacheContext, filter: nil, sort: nil)
//            if let objects = cachedRecords, objects.count > 0 {
//                self.uploadCachedRecords()
//            }
//        }
    }
    
    // MARK: Save records to iCloud
    
    // TODO: Upload Failed Records
    public func getUploadFailedRecords() -> ([CKRecord], [CKRecordID]) {
        
        let cachedObjects = DataController.shared.fetchCachedObjects()
        var recordsToSave: [CKRecord] = []
        var recordIDsToDelete: [CKRecordID] = []
        
        
        if cachedObjects.count > 0 {
            let recordNames = cachedObjects.map{$0.recordName!}
            let uniqueNames = Array(Set(recordNames))
            
            
            var deletedRecordsNames: [String] = []
            var insertedRecordsNames: [String] = []
            
            let context = DataController.shared.viewContext
//
//            for recordName in uniqueNames {
//                let managedObject = DataController.shared.retrieveObject(from: recordName, context: context)
//                if let cloudManagedObject = managedObject as? CloudKitManagedObject {
//                    let record = cloudManagedObject.managedObjectToRecord()
//                    recordsToSave.append(record)
//                } else {
//                    let zoneID = CloudKitManager.shared.customeZone.zoneID
//                    let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
//                    recordIDsToDelete.append(recordID)
//                }
//            }
            
            for record in cachedObjects {
                if record.isDelete {
                    deletedRecordsNames.append(record.recordName!)
                } else {
                    insertedRecordsNames.append(record.recordName!)
                }
            }
            
            // TODO: Get unique names then convert to records
            let uniqueDeletedNames = Array(Set(deletedRecordsNames))
            let uniqueInsertedNames = Array(Set(insertedRecordsNames))
            
            // convert deleted names to record ids
            for name in uniqueDeletedNames {
                let zoneID = CloudKitManager.shared.customeZone.zoneID
                let recordID = CKRecordID(recordName: name, zoneID: zoneID)
                recordIDsToDelete.append(recordID)
            }
            // Convert insertedNames to CKRecords
            for name in uniqueInsertedNames {
                let managedObject = DataController.shared.retrieveObject(from: name, context: context)
                if let cloudManagedObject = managedObject as? CloudKitManagedObject {
                    let record = cloudManagedObject.managedObjectToRecord()
                    recordsToSave.append(record)
                }
            }
            
        }
        
        // return
        return (recordsToSave, recordIDsToDelete)
    }
    
    // MARK: Modify Record Operation
    public func modifyRecordOperation(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecordID]) {
        
        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        // block of operation
        modifyRecordsOperation.modifyRecordsCompletionBlock = { [unowned self] savedRecords, deletedRecords, error in
            
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
                                        print("Could not create custome zone")
                                        return
                                    }
                                    // create subscribtion the first time zone created
                                    self.creatSubscribtion()
                                    // Call save after creating the zone
                                    self.modifyRecordOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
                                    return
                                }
                                print("Zone Not Found Error")
                                return
                            }
                        }
                    }
                } // end of partial failure error
//                completion(error)
                return
            } // end of first guard statement
            
            // The record has been saved without errors
//            completion(nil)
            
            // TODO: check if modifiedCKRecords failed before (CachedContext) then clear them
            var recordNames: [String] = []
            
            if let savedRecords = savedRecords {
                
                for record in savedRecords {
//                    let cloudKitObject = record as? CloudKitManagedObject
//                    if let recordName = cloudKitObject?.recordName {
//                        // appened record name
//                        print("RecordName: \(recordName)")
//                        recordNames.append(recordName)
//                    }
                    
                    let recordName = record.recordID.recordName
                    recordNames.append(recordName)
                } // end of for
                
                if let deletedRecords = deletedRecords {
                    for record in deletedRecords {
                        let recordName = record.recordName
                        print("deleted record name: \(recordName)")
                        recordNames.append(recordName)
                    }
                }
                
                // TODO: Clear Cached objects
                self.clearCachedRecords(recordNames:  recordNames)
            }
            
            
        } // end of CKModifyRecordOperationBlock
        
        let container = CKContainer.default()
        let privateDataBase = container.privateCloudDatabase
        privateDataBase.add(modifyRecordsOperation)
        // test
        print("CKModifyRecordsOperation is added !!!!")
    }
    
    public func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            print("iCloud Available")
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: fetchCloudChanges
    public func fetchCloudChanges() {
        
        var changeToken: CKServerChangeToken? = nil
        let changeTokenData = UserDefaults.standard.data(forKey: serverChangeTokenKey)
        if changeTokenData != nil {
            changeToken = NSKeyedUnarchiver.unarchiveObject(with: changeTokenData!) as! CKServerChangeToken?
        }
        
        let options = CKFetchRecordZoneChangesOptions()
        options.previousServerChangeToken = changeToken
        let optionsMap = [zoneID!: options]
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID!], optionsByRecordZoneID: optionsMap)
        operation.fetchAllChanges = true
        
        // insertion and updated records
        operation.recordChangedBlock = {[unowned self]  record in
            CloudKitManager.shared.updateLocalRecords(changedRecords: [record], deletedRecordIDs: [])
        }
        
        // deleted records
        operation.recordWithIDWasDeletedBlock = {
            [unowned self] (recordID, someString) in
            
            // delete records/object
            CloudKitManager.shared.updateLocalRecords(changedRecords: [], deletedRecordIDs: [recordID])
            
        }
            
        
        operation.recordZoneChangeTokensUpdatedBlock = {[unowned self]  zoneID, changeToken, data in
            guard let changeToken = changeToken else {
                return
            }
            
            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: self.serverChangeTokenKey)
        }
        operation.recordZoneFetchCompletionBlock = {[unowned self]  zoneID, changeToken, data, more, error in
            guard error == nil else {
                return
            }
            guard let changeToken = changeToken else {
                return
            }
            
            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: self.serverChangeTokenKey)
        }
        operation.fetchRecordZoneChangesCompletionBlock = { [unowned self] error in
            guard error == nil else {
                return
            }
        }
        operation.qualityOfService = .utility
        
        let container = CKContainer.default()
        let db = container.privateCloudDatabase
        db.add(operation)
    }
}
