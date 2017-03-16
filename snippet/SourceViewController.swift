//
//  SourceViewController.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import CoreData

class SourceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController:NSFetchedResultsController<Source>!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        fetchedResultsController?.delegate = self
        fectchSources()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let sourceFetched = UserDefaults()

        if sourceFetched.bool(forKey: "source") {
            
        } else {
            SourceClient.sharedInstance.fetchSources { (sucess, error) in
                if sucess {
                    sourceFetched.set(true, forKey: "source")
                } else {
                    
                }
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("results \(fetchedResultsController.fetchedObjects?.count)")
    }
    
    
    func fectchSources() {
        
        let fetchRequest:NSFetchRequest<Source> = Source.fetchRequest()
        
        let sort = NSSortDescriptor(key: "image", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            self.collectionView.reloadData()
        } catch let error as NSError {
            print("Error fecthing pins \(error.localizedDescription)")
        }
    }
    
}

extension SourceViewController {
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
}
