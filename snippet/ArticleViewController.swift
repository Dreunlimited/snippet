//
//  ArticleViewController.swift
//  snippet
//
//  Created by Dandre Ealy on 3/16/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import CoreData

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController:NSFetchedResultsController<Article>!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var source:Source!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController?.delegate = self
        fectchArticles()
        tableView.delegate = self
        tableView.dataSource = self
        
        ArticleClient.sharedInstance.fetchArticles(source) { (sucess, error) in
            if sucess {
              print("sucess")
            }else {
                print(error!)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("results \(fetchedResultsController.fetchedObjects?.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func fectchArticles() {
        
        let fetchRequest:NSFetchRequest<Article> = Article.fetchRequest()
        
        let sort = NSSortDescriptor(key: "publishedAt", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "source = %@", source)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Error fecthing pins \(error.localizedDescription)")
        }
    }
    @IBAction func backTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ArticleViewController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  fetchedResultsController.fetchedObjects?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell
        
        performUIUpdatesOnMain {
            cell?.photo.image = nil
            cell?.activity.startAnimating()
        }
        
        if source.image != nil {
            performUIUpdatesOnMain {
                if let image =  UIImage(data: article.image as! Data) {
                    cell?.photo.image = image
                    print("no network call")
                    cell?.author.text = article.author
                    cell?.data.text = String(describing: article.publishedAt)
                    cell?.desc.text = article.desc
                    cell?.title.text = article.title
                    try? self.appDelegate?.persistentContainer.viewContext.save()
                    cell?.activity.stopAnimating()
                    cell?.activity.hidesWhenStopped = true
                }
                
            }
            
        } else {
            SourceClient.sharedInstance.convertStringToImage(source, completionHandler: { (image, error) in
                if error != nil {
                    alert("\(error)", "Try Agin", self)
                } else {
                    performUIUpdatesOnMain {
                        if let image =  UIImage(data: article.image as! Data) {
                            print("network call")
                            cell?.photo.image = image
                            cell?.author.text = article.author
                            cell?.data.text = String(describing: article.publishedAt)
                            cell?.desc.text = article.desc
                            cell?.title.text = article.title
                            try? self.appDelegate?.persistentContainer.viewContext.save()
                            cell?.activity.stopAnimating()
                            cell?.activity.hidesWhenStopped = true
                        }
                    }
                }
            })
        }

        
        
        return cell!
    }
}
