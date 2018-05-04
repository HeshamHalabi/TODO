//
//  Task+CoreDataProperties.swift
//  TODO
//
//  Created by Hesham on 5/4/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged public var details: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var reminderDate: NSDate?
    @NSManaged public var category: Category?

}
