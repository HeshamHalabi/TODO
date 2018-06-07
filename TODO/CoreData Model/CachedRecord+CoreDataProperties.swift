//
//  CachedRecord+CoreDataProperties.swift
//  TODO
//
//  Created by Hesham on 5/24/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
//

import Foundation
import CoreData


extension CachedRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedRecord> {
        return NSFetchRequest<CachedRecord>(entityName: "CachedRecord")
    }

    @NSManaged public var recordName: String?
    @NSManaged public var modificationDate: NSDate?

}
