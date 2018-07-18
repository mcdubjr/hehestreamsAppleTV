//
//  ActivateViewController.swift
//  hehestreams
//
//  Created by HEHE Lover on 9/29/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit

class ActivateViewController: UIViewController
{
    
    let defaults:UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var activationCode: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        WebServices.sharedInstance.getActivationCode { (json) in
            if  let key = json["key"] as? String {
                self.activationCode.text = key
            }
        }
        
    }

    
    @IBAction func confirm(_ sender: Any) {
        
        WebServices.sharedInstance.getApiKey(activationCode: self.activationCode.text!) { json in
            if let apikey = json["api_key"] as? String {
                self.defaults.set(apikey, forKey: "hehe_key")
                self.performSegue(withIdentifier: "unwindToSportsSegue", sender: self)
                
            }
            
        }
        
        
        
    }
    
    
}


