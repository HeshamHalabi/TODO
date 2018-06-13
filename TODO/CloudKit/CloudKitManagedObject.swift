//
//  CloudKitManagedObject.swift
//  TODO
//
//  Created by Hesham on 5/23/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import Foundation
import CloudKit

@objc protocol CloudKitManagedObject {
    
    var recordID: NSData? { get set }
    var recordName: String? { get set }
    var recordType: String { get }
    var lastUpdate: NSDate? { get set }
    
    // convert core data object to CKRecord 
    func managedObjectToRecord() -> CKRecord
    // update local objects using fetched record
    func updateWithRecord(_ record: CKRecord)
}

extension CloudKitManagedObject {
    
    var customZone: CKRecordZone {
        return CloudKitManager.shared.customeZone
    }
    
    // create recordName and recordID
    public func prepareForCloudKit() {
        let uuid = UUID()
        recordName = recordType + "." + uuid.uuidString
        let _recordID = CKRecordID(recordName: recordName!, zoneID: customZone.zoneID)
        recordID = NSKeyedArchiver.archivedData(withRootObject: _recordID) as NSData
    }
    
    public func cloudKitRecord() -> CKRecord {
        return CKRecord(recordType: recordType, recordID: cloudKitRecordID())
    }
    
    public func cloudKitRecordID() -> CKRecordID {
        return NSKeyedUnarchiver.unarchiveObject(with: recordID! as Data) as! CKRecordID
    }
    
    
}
