//
//  TaskCategory+CoreDataProperties.swift
//  TODO
//
//  Created by Hesham on 6/16/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCategory> {
        return NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
    }

    @NSManaged public var lastUpdate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var recordID: NSData?
    @NSManaged public var recordName: String?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension TaskCategory {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
