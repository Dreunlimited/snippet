//
//  ViewController.swift
//  snippet
//
//  Created by Dandre Ealy on 3/18/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var discover: UIButton!
    let reachability = Reachability()!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func discoverTouched(_ sender: Any) {
        if reachability.currentReachabilityStatus == .notReachable {
            SVProgressHUD.showError(withStatus: "Network failure")
        } else {
            SVProgressHUD.show(withStatus: "Fetching Sources")
            let userDefault = UserDefaults()
            discover.isEnabled = false
            if userDefault.bool(forKey: "sourcesFetched") {
                self.nextView()
            } else {
                SourceClient.sharedInstance.fetchSources { (sucess, error) in
                    if sucess {
                        userDefault.set(true, forKey: "sourcesFetched")
                        self.nextView()
                        
                    } else {
                        
                    }
                }
                
            }
        }
        
    }
    
    func nextView() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "source") as! SourceViewController, animated: true)
    }
    
}
