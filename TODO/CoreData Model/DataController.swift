//
//  DataController.swift
//  TODO
//
//  Created by Hesham on 5/4/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import Foundation
import CoreData

public class DataController {
    
    // try singelton to solve accessibility poblem in CoreData generated classes
    public static let shared = DataController(modelName: "TODO")
    
    let persistentContainer: NSPersistentContainer
    
    // main context
    public lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    // cacheContext for uploading records
    public lazy var cacheContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    // updateContext for updating local records
    public lazy var updateContext: NSManagedObjectContext = {
        let _updateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _updateContext.parent = self.viewContext
        return _updateContext
    }()
    
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    public func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            // auto save context
            self.autoSaveViewController()
        }
    }
}

extension DataController {
    
    public func autoSaveViewController(interval: TimeInterval = 30) {
        print("autoSaveContext")
        guard interval > 0 else {
            print("Can not use negative numbers as time interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewController(interval: interval)
        }
    }
    
    // custom save for saving to CoreData and iCloud
    public func saveContext() {
        
        let insertedObjects = viewContext.insertedObjects
        let modifiedObjects = viewContext.updatedObjects
        let deletedRecordIDs = viewContext.deletedObjects.map { ($0 as! CloudKitManagedObject).cloudKitRecordID() }
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                NSLog("Core Data SaveContext Error: \(error.localizedDescription)")
            }
            
            let insertedObjectIDs = insertedObjects.map { $0.objectID }
            let modifiedObjectIDs = modifiedObjects.map { $0.objectID }
            
            // MARK: upload changes to iCloud
            CloudKitManager.shared.uploadChangedObjects(savedIDs: insertedObjectIDs + modifiedObjectIDs, deletedIDs: deletedRecordIDs ) {error in
                
                if let error = error {
                    print("There is an error when saving to iCloud, ModifyRecordOperation : \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func saveUpdateContext() {
        // TODO: Save updateContext
        do {
            try DataController.shared.updateContext.save()
        } catch {
            print("Error saving updateContext")
        }
        
    }
    
    public func saveCacheContext() {
        // TODO: save cachedContext
        do {
            try DataController.shared.cacheContext.save()
        } catch {
            print("Error saving cachedContext")
        }
    }
    // fetch category
    func fetchCategory(categoryName: String) -> TaskCategory? {
        
        // fetch request
        let fetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", categoryName)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // perform request
        let result = try! viewContext.fetch(fetchRequest)
        
        if result.count > 0 {
            return result[0]
        } else {
            return nil
        }
        
    }
    
    // MARK: retrieve object from core data
    func retrieveObject(from recordName: String, context: NSManagedObjectContext) -> NSManagedObject? {
        guard let dotIndex = recordName.characters.index(of: ".") else { return nil }
        let entityName = recordName.substring(to: dotIndex)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        let predicate = NSPredicate(format: "recordName == %@", recordName)
        fetchRequest.predicate = predicate
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var result = [NSManagedObject]()
        
        do {
            result = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("Error Fetching Request : \(error.localizedDescription)")
        }
        
        if (result.count) > 0 {
            
            return result[0]
        }
        
        return nil
    }
    
    // fetch many objects
    func retrieveObjects(from recordName: String, context: NSManagedObjectContext) -> [NSManagedObject]? {
        guard let dotIndex = recordName.characters.index(of: ".") else { return nil }
        let entityName = recordName.substring(to: dotIndex)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let predicate = NSPredicate(format: "recordName == %@", recordName)
        fetchRequest.predicate = predicate
        //        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var result = [NSManagedObject]()
        
        do {
            result = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("Error Fetching Request : \(error.localizedDescription)")
        }
        
        if (result.count) > 0 {
            
            return result
        }
        
        return nil
    }
    func retrieveObject(using objectID: NSManagedObjectID, context: NSManagedObjectContext) -> NSManagedObject? {
        
        // TODO: fetch object using id
        let object = context.object(with: objectID)
        
        if !object.isFault {
            return object
        }
        
        return nil
    }
    
    func fetchCachedObjects() -> [CachedRecord] {
        
        let context = DataController.shared.cacheContext
        var objects: [NSManagedObject] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedRecord")
        do {
            objects = try context.fetch(fetchRequest)
            // test
            print("Fetching Cached Records")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return objects as! [CachedRecord]
    }
    
    
}
