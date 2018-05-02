//
//  Note.swift
//  TODO
//
//  Created by Hesham on 5/2/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//
import Foundation

class Note {
    
    var id: Int
    var title: String
    var details: String?
    var dueDate: Date?
    var reminderDate: Date?
    
    private static var numberOfObjects = 0
    
    private static func newObjectId() -> Int {
        Note.numberOfObjects += 1
        return numberOfObjects
    }
    
    init(title: String) {
        // initialize note
        self.id = Note.newObjectId()
       self.title = title
    }
}
