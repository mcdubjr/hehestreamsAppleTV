//
//  UIViewControllerExtensions.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/4/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showBasicAlert(title:String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
