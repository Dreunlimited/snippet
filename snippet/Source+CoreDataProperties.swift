//
//  Source+CoreDataProperties.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import CoreData


extension Source {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Source> {
        return NSFetchRequest<Source>(entityName: "Source");
    }

    @NSManaged public var category: String?
    @NSManaged public var desc: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var logoURL: String?
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var artical: NSSet?

}

// MARK: Generated accessors for artical
extension Source {

    @objc(addArticalObject:)
    @NSManaged public func addToArtical(_ value: Article)

    @objc(removeArticalObject:)
    @NSManaged public func removeFromArtical(_ value: Article)

    @objc(addArtical:)
    @NSManaged public func addToArtical(_ values: NSSet)

    @objc(removeArtical:)
    @NSManaged public func removeFromArtical(_ values: NSSet)

}
