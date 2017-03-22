//
//  Article+CoreDataProperties.swift
//  snippet
//
//  Created by Dandre Ealy on 3/20/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article");
    }

    @NSManaged public var author: String?
    @NSManaged public var desc: String?
    @NSManaged public var image: NSData?
    @NSManaged public var publishedAt: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var save: Bool
    @NSManaged public var source: Source?

}
