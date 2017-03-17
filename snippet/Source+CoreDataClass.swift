//
//  Source+CoreDataClass.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import CoreData


public class Source: NSManagedObject {

    func deleteArticle(_ context: NSManagedObjectContext, handler: (_ error: String?) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        request.predicate = NSPredicate(format: "source == %@", self)
        
        do {
            let articles = try context.fetch(request) as! [Article]
            for article in articles {
                context.delete(article)
            }
        } catch { }
        
        handler(nil)
    }

}
