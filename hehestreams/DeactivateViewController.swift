//
//  DeactivateViewController.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/4/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit

class DeactivateViewController: UIViewController
{
    let defaults:UserDefaults = UserDefaults.standard
   
    @IBAction func confirm(_ sender: Any) {
        
        
        WebServices.sharedInstance.deactivate { json in
            
            self.performSegue(withIdentifier: "unwindToSportsSegue", sender: self)
        }
        
    
        
    }
    
    
}



