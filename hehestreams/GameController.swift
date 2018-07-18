//
//  GameCollectionController.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/26/16.
//  Copyright © 2016 warhorse. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Nuke


class GameController: UITableViewController{
    
    var dataLoaded = false
    var date = Date()
    var gamesJson:  [[String: Any]] = []
    var sportTypeJson: [String: Any]!
    var endpoint: String!
    
    let baseLogoURL = "http://hehestreams.com"
    
    var streamJson: [String: Any]!
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    var focusView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 440
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGames()
    }
    
    
    @IBAction func reload(_ sender: Any) {
        getGames()
    }
    
    @IBAction func nextDay(){
        
        let calendar = Calendar.current
        date = calendar.date(byAdding: .day, value: 1, to: date)!
        getGames()
        
    }
    
    @IBAction func previousDay(){
        let calendar = Calendar.current
        date = calendar.date(byAdding: .day, value: -1, to: date)!
        getGames()
        
    }
    
    func getGames(){
        
        self.dataLoaded = false
        self.tableView.reloadData()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: date)
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MMM dd"
        let monthDay = formatter2.string(from: date)
        
        self.dayOfWeekLabel.text = dayOfWeek + "\n"
        self.dateLabel.text = monthDay
        
        let sportType = sportTypeJson["name"] as! String
        
        WebServices.sharedInstance.getGames(sportType: sportType, endpoint: sportTypeJson["endpoint"] as! String, date: self.date, completion:
            { json in
                
                self.gamesJson = json.filter { $0["kind"] as! String == "game"}
                
                self.gamesJson = self.gamesJson.sorted {
                    
                    if let strTimeString = $0["start_in_gmt"]  as? String, let strTimeString2 = $1["start_in_gmt"]  as? String{
                        let strTime1 = self.parseDate(strTimeString)
                        let strTime2 = self.parseDate(strTimeString2)
                        return strTime1!.compare(strTime2!) == .orderedAscending
                    }
                    return true
                }
                
                self.dataLoaded = true
                self.tableView.reloadData()
                
                self.setNeedsFocusUpdate()
                
        }, failed: { error in
            self.showBasicAlert(title: "Error", message: error)
        })
    }
    
    
    func parseDate(_ strTime: String)->Date?{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let startTime = formatter.date(from: strTime) // Returns "Jul 27, 2015, 12:29 PM" PST
        
        let formatter2 = DateFormatter()
        formatter2.timeZone = NSTimeZone.local
        formatter2.dateFormat = "h:mm a"
        formatter2.amSymbol = "AM"
        formatter2.pmSymbol = "PM"
        
        return startTime
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]  {
        
        get {
            
            if (focusView != nil){ return [focusView] }
            return [self.tableView]
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.dataLoaded){
            return self.gamesJson.count
        }
        
        return 0
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.dataLoaded){
            return 1
        }
        return 0
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.streamJson = self.streamJson
        
    }
    
    func showStreams(_ gameId : String, _ steamsJSON : [[String: Any]]){
        
        let alert = UIAlertController(title: "Select Stream", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for stream in steamsJSON {
            
            let id = stream["id"] as! String
            let title = stream["title"] as! String
            
            if title.lowercased().contains("mobile"){
                continue
            }
            
            let sportType = sportTypeJson["name"] as! String
            
            let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                WebServices.sharedInstance.getStreamURL(sportType: sportType, gameId: gameId, streamId: id, completion: { json in
                    //self.streamURL = json["stream"] as! String
                    self.streamJson = json
                    self.performSegue(withIdentifier: "playStreamIdentifier", sender: self)
                }, failed: { error in
                    self.showBasicAlert(title: "Error", message: error)
                })
                
                
            })
            
            alert.addAction(action)
        }
        
        let action = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var gameJSON = self.gamesJson[indexPath.row] as [String: Any]
        
        let gameId = gameJSON["uuid"] as! String
        let sportType = sportTypeJson["name"] as! String
        
        WebServices.sharedInstance.getStreams(sportType: sportType, gameId: gameId, completion: { json in
            
            self.showStreams(gameId, json)
            
        }) { error in
            
            self.showBasicAlert(title: "Error", message: error)
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var gameJSON = self.gamesJson[indexPath.row] as [String: Any]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell",
                                                 for: indexPath) as! GameCell
        
    
        
        if let strTime = gameJSON["start_in_gmt"] as? String{  //2016-10-11T21:00:00.000-04:00
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let startTime = formatter.date(from: strTime) // Returns "Jul 27, 2015, 12:29 PM" PST
            
            
            let formatter2 = DateFormatter()
            formatter2.timeZone = NSTimeZone.local
            formatter2.dateFormat = "h:mm a"
            formatter2.amSymbol = "AM"
            formatter2.pmSymbol = "PM"
            
            let dateString = formatter2.string(from: startTime!)
            
            if startTime! > Date.init() {
                cell.status.text = "Not Ready"
            }
            
            
            cell.timeLabel.text = dateString
        }
        
        //        let calendar = Calendar.current
        //       let tz = NSTimeZone.local
        //        if tz.isDaylightSavingTime(for: date) {
        //            startTime = calendar.date(byAdding: .hour, value: -1, to: startTime!)
        //        }
        
        cell.homeTeam.text = ""
        cell.homeTeamCity.text = ""
        cell.awayTeam.text = ""
        cell.awayTeamCity.text = ""
        
        
        if let homeTeam = gameJSON["home_team"] as? [String: Any]{
            
            
            if let homeLogoUrl = homeTeam["logo"] as? String {
                if let url = URL(string: baseLogoURL + homeLogoUrl.replacingOccurrences(of: ".svg", with: ".png")){
                    Nuke.loadImage(with: url, into: cell.homeImage)
                }
            }
            
            if let homeName = homeTeam["name"] as? String {
                cell.homeTeam.text = homeName.uppercased()
            }
            
            if let homeTeamCity = homeTeam["location"]  as? String {
                cell.homeTeamCity.text = homeTeamCity.uppercased()
            }
            
        }
        
        let awayTeam = gameJSON["away_team"] as! [String: Any]
        
        
        if let awayLogoUrl = awayTeam["logo"] as? String {
            if let url = URL(string: baseLogoURL + awayLogoUrl.replacingOccurrences(of: ".svg", with: ".png")){
                Nuke.loadImage(with: url, into: cell.awayImage)
            }
            
            if let awayName = awayTeam["name"] as? String {
                cell.awayTeam.text = awayName.uppercased()
            }
            
            if let awayTeamCity = awayTeam["location"]  as? String {
                cell.awayTeamCity.text = awayTeamCity.uppercased()
            }
            
        }
        
        
        cell.status.text = ""
        
        
        
        
        
        return cell
        
    }
    
    
    
    //    func generateImage (homeImageName: String, awayImageName: String, completion: @escaping (_ comboImage: UIImage) -> Void){
    //
    //        let cache = Cache<UIImage>(name: "logos")
    //
    //        cache.fetch(key: homeImageName + awayImageName).onSuccess { comboImage in
    //            completion(comboImage)
    //            }
    //            .onFailure { error in
    //
    //
    //                guard let homeImage = UIImage(named: "nba/\(homeImageName)"), let awayImage = UIImage(named: "nba/\(awayImageName)") else {
    //                    return
    //                }
    //
    //                let size = CGSize(width: 770, height: 400)
    //                UIGraphicsBeginImageContext(size)
    //
    //                let rectHome = AVMakeRect(aspectRatio: homeImage.size, insideRect: CGRect(x:0,y:0,width:240,height: 240))
    //                let rectAway = AVMakeRect(aspectRatio: awayImage.size, insideRect: CGRect(x:0,y:0,width:240,height: 240))
    //
    //
    //                let areaSize = CGRect(x: 0, y: 0, width: rectHome.size.width, height: rectHome.height)
    //                homeImage.draw(in: areaSize)
    //
    //                let areaSize2 = CGRect(x: size.width-rectAway.width, y: 0, width: rectAway.size.width, height: rectAway.size.height)
    //                awayImage.draw(in: areaSize2)
    //
    //                let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    //                UIGraphicsEndImageContext()
    //
    //                cache.set(value: newImage, key: homeImageName + awayImageName)
    //
    //                completion(newImage)
    //
    //        }
    //    }
    //
    
    
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
    
}


class GameCell: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var awayImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var homeTeam: UILabel!
    @IBOutlet weak var awayTeam: UILabel!
    @IBOutlet weak var homeTeamCity: UILabel!
    @IBOutlet weak var awayTeamCity: UILabel!
}


