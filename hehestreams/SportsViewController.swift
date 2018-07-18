//
//  SportsViewController.swift
//  hehestreams
//
//  Created by HEHE Lover on 9/29/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit



class SportsViewController: UITableViewController
{

    
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    var sports:[[String: Any]]!
    var dataLoaded = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.remembersLastFocusedIndexPath = true
        
        
        WebServices.sharedInstance.confirmActivation { (json) in
            
            if let isActivated = json["status"] as? Bool{
                if isActivated{
                    self.getSports()
                    self.settingsButton.isEnabled = true
                    self.reloadButton.isEnabled = true
                }
                else{
                    self.performSegue(withIdentifier: "activateSegue", sender: nil)
                }
            }
            else{
                self.performSegue(withIdentifier: "activateSegue", sender: nil)
            }
            
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment]  {
        return [self.tableView]
    }
    
    @IBAction func unwindToSports(segue: UIStoryboardSegue) {}
    
    
    
    @IBAction func reload(_ sender: Any) {
        getSports()
    }
    
    func getSports(){
        
        self.dataLoaded = false
        self.tableView.reloadData()
        
        WebServices.sharedInstance.getSports(completion: { json in
            self.sports = json
            self.dataLoaded = true
            self.tableView.reloadData()

            
            self.setNeedsFocusUpdate()
            
        }) { error in
             self.showBasicAlert(title: "Error", message: error)
        }
        

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataLoaded ? 1 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLoaded ? sports.count : 1
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (!dataLoaded) { return UITableViewCell() }
            
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        if let name = sports[indexPath.row]["name"] as? String{
            cell.textLabel?.text = name
        }

        return cell
        
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //        if let previousItem = context.previouslyFocusedView as? GameCell {
        //            UIView.animateWithDuration(0.2, animations: { () -> Void in
        //                previousItem.showImg.frame.size = self.originalCellSize
        //            })
        //        }
        //        if let nextItem = context.nextFocusedView as? GameCell {
        //            UIView.animateWithDuration(0.2, animations: { () -> Void in
        //                nextItem.showImg.frame.size = self.focusCellSize
        //            })
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gamesSeque"
        {
            if let gamesVC = segue.destination as? GameController{
                gamesVC.sportTypeJson = self.sports[self.tableView.indexPathForSelectedRow!.row]
            }
        }
        
        
//        if segue.identifier == "sportTabSegue"{
//            if let controller  = segue.destination as? SportTabBarController {
//                for vc in controller.viewControllers! {
//                    if let nav = vc as? UINavigationController {
//                        if let gamesVC = nav.viewControllers.first as? GameController{
//                            gamesVC.sportTypeJson = self.sports[self.tableView.indexPathForSelectedRow!.row]
//                        }
//                    }
//                    else if let chanVC = vc as? ChannelsController{
//                            chanVC.sportTypeJson = self.sports[self.tableView.indexPathForSelectedRow!.row]
//                    }
//
//
//                }
//            }
//        }
    }
    
    
        
}





