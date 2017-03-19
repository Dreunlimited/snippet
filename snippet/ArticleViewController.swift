//
//  ArticleViewController.swift
//  snippet
//
//  Created by Dandre Ealy on 3/16/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import ReachabilitySwift
import SVProgressHUD



class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController:NSFetchedResultsController<Article>!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var source:Source!
    let reachability = Reachability()!
    

    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ArticleViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refreshControl)
        fetchedResultsController?.delegate = self
        fectchArticles()
        tableView.delegate = self
        tableView.dataSource = self
        let userDefault = UserDefaults()
        if reachability.currentReachabilityStatus == .notReachable {
            SVProgressHUD.showError(withStatus: "Network failure")
        } else {
            if userDefault.bool(forKey: "articleFetched") {
                
            } else {
                ArticleClient.sharedInstance.fetchArticles(source) { (sucess, error) in
                    if sucess {
                        userDefault.set(true, forKey: "articleFetched")
                    }else {
                        print(error!)
                    }
                }
            }
           
            
        }
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fectchArticles()
        print("results \(fetchedResultsController.fetchedObjects?.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableViewAutomaticDimension
        
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
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        performUIUpdatesOnMain {
            self.source.deleteArticle((self.fetchedResultsController.managedObjectContext)) { _ in }
        }
        
        ArticleClient.sharedInstance.fetchArticles(source) { (sucess, error) in
            if sucess {
                print("sucess")
                self.fectchArticles()
            }else {
                print(error!)
            }
        }
        
        refreshControl.endRefreshing()
    }
}

extension ArticleViewController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell
        
        performUIUpdatesOnMain {
            cell?.photo.image = nil
            cell?.activity.startAnimating()
        }
        
        if article.image != nil {
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
            ArticleClient.sharedInstance.convertStringToImage(article, completionHandler: { (image, error) in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = fetchedResultsController.object(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: article.url!) {
            if url.scheme == nil {
                let newUrlString = "http://\(url)"
                let newURL = URL(string: newUrlString)
                let vc = SFSafariViewController(url: newURL!, entersReaderIfAvailable: true)
                present(vc, animated: true, completion: nil)
            } else {
                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                present(vc, animated: true, completion: nil)
                
            }
        }

    }
}
