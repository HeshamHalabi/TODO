//
//  DataController.swift
//  TODO
//
//  Created by Hesham on 5/4/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil ) {
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
    
    func autoSaveViewController(interval: TimeInterval = 30) {
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
}
