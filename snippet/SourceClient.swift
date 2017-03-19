//
//  SourceClient.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SourceClient: NSObject {
    lazy var session = URLSession.shared
    static let sharedInstance = SourceClient()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override init() {
        super.init()
    }
    
    func fetchSources(completionHandler:@escaping (_ success: Bool, _ error: String?)->Void) {
        
        let methodparameters = [
            Constants.SourcesParameterValues.language:Constants.SourcesParameterValues.language
        ]
        
        let request = URLRequest(url: sourcesURLFromParameters(methodparameters as [String : AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandler(false, "Error getting source data")
            } else {
                if let results = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject] {
                    
                    if let sources = results?["sources"] as? [[String:AnyObject]] {
                       
                        
                        for source in sources {
                            print("source \(source)")
                            let id = source["id"] as! String
                            let name = source["name"]  as! String
                            let description = source["description"]  as! String
                            let url = source["url"]  as! String
                            let category = source["category"]  as! String
                            let urlToLogos = source["urlsToLogos"] as! [String:AnyObject]
                            let urlToLogo = urlToLogos["small"]  as! String
                            
                            let managedContext = self.appDelegate?.persistentContainer.viewContext
                            let sourceObject = Source(entity: Source.entity(), insertInto: managedContext)
                            
                            sourceObject.id = id
                            sourceObject.name = name
                            sourceObject.desc = description
                            sourceObject.url = url
                            sourceObject.category = category
                            sourceObject.logoURL = urlToLogo
                            
                            
                            
                            do {
                                try managedContext?.save()
                            } catch let error as NSError {
                                print("Could not save \(error.userInfo)")
                            }
                        }
                        completionHandler(true, nil)
                    }
                }
            }
           
        }
        task.resume()
    }
    
    func convertStringToImage(_ image: Source, completionHandler: @escaping(_ image: UIImage?, _ error: NSError?)-> Void)  {
        
        let request = URLRequest(url: URL(string: image.logoURL!)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completionHandler(nil, error as NSError?)
                
            } else {
                
                performUIUpdatesOnMain {
                    let imageData = UIImage(data: data!)
                    image.image = data as NSData?
                    
                    do {
                        
                        try image.managedObjectContext?.save()
                        
                    } catch let error as NSError {
                        print("Error saving image data: \(error.localizedFailureReason)")
                        completionHandler(nil, error)
                    }
                    
                    completionHandler(imageData, nil)
                    
                }
                
            }
        }
        task.resume()
    }
}
extension SourceClient{
    public func sourcesURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Sources.apiScheme
        components.host = Constants.Sources.apiHost
        components.path = Constants.Sources.apiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
