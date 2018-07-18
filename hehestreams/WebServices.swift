//
//  WebServices.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/26/16.
//  Copyright © 2016 warhorse. All rights reserved.
//

import Foundation
import Alamofire

class WebServices {
    
    let baseURL = "http://hehestreams.xyz/api/v1/"
    
    let sessionManager: SessionManager!
    let defaults:UserDefaults = UserDefaults.standard
    
    
    class HeHeHeadersAdapter: RequestAdapter {
        
        let defaults:UserDefaults = UserDefaults.standard
        
        func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            var urlRequest = urlRequest
            
            urlRequest.setValue("AppleTV", forHTTPHeaderField: "X-App")
            urlRequest.setValue("1.0.4", forHTTPHeaderField: "X-App-Version")
            urlRequest.setValue("1.2.22", forHTTPHeaderField: "X-Device-Version")
            urlRequest.setValue(defaults.string(forKey: "UUID"), forHTTPHeaderField: "X-Id")
            
            if let hehe_key = defaults.string(forKey: "hehe_key"){
                urlRequest.setValue(hehe_key, forHTTPHeaderField: "ApiKey")
            }
            
            return urlRequest
        }
    }
    
    init() {
//        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//        defaultHeaders["X-App"] = "Plex"
//        defaultHeaders["X-App-Version"] = "1.0.4"
//        defaultHeaders["X-Device-Version"] = "1.2.22"
//        defaultHeaders["X-Id"] = defaults.string(forKey: "UUID")
//
        let configuration = Timberjack.defaultSessionConfiguration()
        //let configuration = URLSessionConfiguration.default
        //configuration.httpAdditionalHeaders = defaultHeaders
        configuration.urlCache = nil
        
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        sessionManager.adapter = HeHeHeadersAdapter()
        
    }
    
    
    
    static let sharedInstance : WebServices = {
        let instance = WebServices()
        return instance
    }()
    
    func getId() ->String{
        let uuid = defaults.string(forKey: "UUID")
        if (uuid == nil){
            let newuuid = UUID().uuidString
            defaults.set(newuuid, forKey: "UUID")
            return newuuid
        }
        else{
            return uuid!
        }
        
    }
    
    func getHeHeKey() ->String?{
        if let s = defaults.string(forKey: "hehe_key"){
            return s
        }
        return nil
    }
    
    
   
    func getGames(sportType: String, endpoint: String, date: Date, completion: @escaping (_ json: [[String: Any]]) -> Void, failed: @escaping (_ message: String) -> Void) {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date as Date)
        
        let url = "\(baseURL)\(sportType.lowercased())/games?date=\(components.year!)-\(components.month!)-\(components.day!)"
        
        sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
            
            if let json = response.result.value {
                if let jsonArray = json as? [[String: Any]] {
                    completion(jsonArray)
                }
                else if let jsonDict = json as? [String: Any] {
                    let error = jsonDict["error"] as! String
                    failed(error)
                    
                }
                else{
                    failed("unknown error")
                }
            }
        }
    }
    
    
    func getStreams(sportType: String, gameId: String, completion: @escaping (_ json: [[String: Any]]) -> Void, failed: @escaping (_ message: String) -> Void) {

        let streamURL = "\(baseURL)\(sportType.lowercased())/games/\(gameId)/streams"
        
        
        sessionManager.request(streamURL, method: HTTPMethod.get).responseJSON { response in
            
            if let json = response.result.value {
                if let jsonArray = json as? [String: Any] {
                    
                    if let jsonError = jsonArray["error"] as? String {
                        failed(jsonError)
                    }
                    else{
                        
                        if let jsonArrayStream = jsonArray["streams"] as? [[String: Any]]{
                            completion(jsonArrayStream)
                        }
                    }
                }
                else if let jsonDict = json as? [String: Any] {
                    let error = jsonDict["error"] as! String
                    failed(error)                    
                }
                else{
                    failed("unknown error")
                }
            }
            
        }
    }
    
    func getChannelStreams(sportType: String, channelId: String, completion: @escaping (_ json: [[String: Any]]) -> Void, failed: @escaping (_ message: String) -> Void) {
        
        let streamURL = "\(baseURL)\(sportType.lowercased())/channels/\(channelId)"
        
        
        sessionManager.request(streamURL, method: HTTPMethod.get).responseJSON { response in
            
            if let json = response.result.value {
                if let jsonArray = json as? [String: Any] {
                    completion(jsonArray["streams"] as! [[String: Any]])
                }
                else if let jsonDict = json as? [String: Any] {
                    let error = jsonDict["error"] as! String
                    failed(error)
                }
                else{
                    failed("unknown error")
                }
            }
            
        }
    }
    
    
    func getStreamURL(sportType: String, gameId: String, streamId: String, completion: @escaping (_ json: [String: Any]) -> Void, failed: @escaping (_ message: String) -> Void){
        
        let streamURL =  "\(baseURL)\(sportType.lowercased())/games/\(gameId)/streams/\(streamId)"
        
        sessionManager.request(streamURL, method: HTTPMethod.get).responseJSON { response in
        
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    completion(json)
                }
                else if let jsonDict = json as? [String: Any] {
                    let error = jsonDict["error"] as! String
                    failed(error)
                }
                else{
                    failed("unknown error")
                }
            }
        }
    }
    
    func confirmActivation(completion: @escaping (_ json: [String: Any]) -> Void ) {
        
        let url = "\(baseURL)devices/check"
        sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String: Any] {
                    
                    completion(json)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func getApiKey(activationCode:String, completion: @escaping (_ json: [String: Any]) -> Void ) {
        
        let url = "\(baseURL)devices/activate?code=\(activationCode)"
        sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
            if let json = response.result.value as? [String: Any]{
                
                completion(json)
            }
            
        }
    }
    
    func getActivationCode(completion: @escaping (_ json: [String: Any]) -> Void ) {
        
        let url = "\(baseURL)devices/ping?uuid=" + getId()
        sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
            if let json = response.result.value as? [String: Any] {
                
                completion(json)
            }
            
        }
    }
    
    func deactivate(completion: @escaping (_ json: [String: Any]) -> Void ) {
        
        if (getHeHeKey() != nil) {
            
            let url = "\(baseURL)devices/deactivate"
            sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
                if let json = response.result.value as? [String: Any] {
                    self.defaults.set(nil, forKey: "hehe_key")
                    self.defaults.set(nil, forKey: "UUID")
                    completion(json)               
                }
                
            }
            
            
        }
    }
    
    func getSports(completion: @escaping (_ json: [[String: Any]]) -> Void, failed: @escaping (_ message: String) -> Void) {
        
        if (getHeHeKey() != nil) {
            
            let url = "\(baseURL)users/services/"
            sessionManager.request(url, method: HTTPMethod.get).responseJSON { response in
                
                if let json = response.result.value {
                    if let jsonArray = json as? [[String: Any]] {
                        completion(jsonArray)
                    }
                    else if let jsonDict = json as? [String: Any] {
                        if let error = jsonDict["error"] as? String{
                            failed(error)
                        }
                    }
                    else{
                        //completion(nil)
                        failed("unknown error")
                    }
                }
                
            }
            
            
        }
    }
    
    
    
    
}
