//
//  Task+CoreDataProperties.swift
//  TODO
//
//  Created by Hesham on 6/16/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var details: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var lastUpdate: NSDate?
    @NSManaged public var recordID: NSData?
    @NSManaged public var recordName: String?
    @NSManaged public var reminderDate: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var isDone: Bool
    @NSManaged public var taskCategory: TaskCategory?

}
