//
//  Alert.swift
//  snippet
//
//  Created by Dandre Ealy on 3/15/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import Foundation
import UIKit

func alert(_ message:String, _ title:String, _ view:UIViewController ) {
    let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: title, style: .cancel, handler: nil)
    alertController.addAction(action)
    
    view.present(alertController, animated: true)
}
