//
//  Message+CoreDataProperties.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 04/06/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var isSender: Bool
    @NSManaged public var friend: Friend?

}
