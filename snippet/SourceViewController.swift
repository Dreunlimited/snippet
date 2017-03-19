//
//  SourceViewController.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD


class SourceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var fetchedResultsController:NSFetchedResultsController<Source>!

    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var searchResults = [AnyObject]()
    var insearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.dismiss()
        fetchedResultsController?.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.navigationBar.isHidden = true 
        fectchSources()
        print("results \(fetchedResultsController.fetchedObjects?.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fectchSources()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func fectchSources() {
        
        let fetchRequest:NSFetchRequest<Source> = Source.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            self.collectionView.reloadData()
        } catch let error as NSError {
            print("Error fecthing sources \(error.localizedDescription)")
        }
    }
    
}

extension SourceViewController: NSFetchedResultsControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let source = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sourceCell", for: indexPath) as? SourceCollectionViewCell
        
        performUIUpdatesOnMain {
            cell?.image.image = nil
            cell?.activity.startAnimating()
        }
        
        if source.image != nil {
            performUIUpdatesOnMain {
                if let image =  UIImage(data: source.image as! Data) {
                    cell?.image.image = image
                    print("no network call")
                    cell?.sourceName.text = source.name
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
                        if let image =  UIImage(data: source.image as! Data) {
                            print("network call")
                            cell?.image.image = image
                            cell?.sourceName.text = source.name
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleVC = storyboard?.instantiateViewController(withIdentifier: "article") as! ArticleViewController
        let source = fetchedResultsController.object(at: indexPath)
        articleVC.source = source
        articleVC.navigationItem.title = "Hello"
        self.present(articleVC, animated: true, completion: nil)
    }
    
    
}
