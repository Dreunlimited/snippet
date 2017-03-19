//
//  ArticleClient.swift
//  snippet
//
//  Created by Dandre Ealy on 3/16/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ArticleClient: NSObject {
    lazy var session = URLSession.shared
    static let sharedInstance = ArticleClient()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override init() {
        super.init()
    }
    
    func fetchArticles(_ source: Source,completionHandler:@escaping (_ success: Bool, _ error: String?)->Void) {
        
        let methodparameters = [
            ArticleConstants.ArticleParameterKeys.apiKey:ArticleConstants.ArticleParameterValues.apiKey,
            ArticleConstants.ArticleParameterKeys.source:source.id
        ]
        
        let request = URLRequest(url: articlesURLFromParameters(methodparameters as [String : AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completionHandler(false, "Error getting source data")
            } else {
                if let results = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject] {
                    
                    if let articles = results?["articles"] as? [[String:AnyObject]] {
                        
                        
                        for article in articles {
                            let author = article["author"] as? String
                            let title = article["title"]  as? String
                            let description = article["description"]  as? String
                            let url = article["url"]  as? String
                            var urlToImage = article["urlToImage"]  as? String
                            if urlToImage == nil {
                                urlToImage = "https://newsapi.org/images/newsapi-logo.png"
                            }
                            let publishedAt = article["publishedAt"]  as? String
                            
                            let managedContext = self.appDelegate?.persistentContainer.viewContext
                            let articleObject = Article(entity: Article.entity(), insertInto: managedContext)
                            
                            articleObject.author = author
                            articleObject.title = title
                            articleObject.desc = description
                            articleObject.url = url
                            articleObject.urlToImage = urlToImage
                            articleObject.publishedAt = publishedAt 
                            articleObject.source = source
                            
                            completionHandler(true, nil)
                            
                            do {
                                try managedContext?.save()
                            } catch let error as NSError {
                                print("Could not save \(error.userInfo)")
                            }
                        }
                        
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func convertStringToImage(_ image: Article, completionHandler: @escaping(_ image: UIImage?, _ error: NSError?)-> Void)  {
        
        let request = URLRequest(url: URL(string: image.urlToImage!)!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completionHandler(nil, error as NSError?)
                
            } else {
                
                performUIUpdatesOnMain {
                    
                    let imageData = UIImage(data: data!) ?? UIImage(named: "placehoder.png")
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

extension ArticleClient{
    public func articlesURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = ArticleConstants.Articles.APIScheme
        components.host = ArticleConstants.Articles.APIHost
        components.path = ArticleConstants.Articles.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
