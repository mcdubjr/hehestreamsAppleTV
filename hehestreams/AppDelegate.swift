//
//  AppDelegate.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/12/16.
//  Copyright © 2016 warhorse. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    override init() {
        super.init()
        URLSessionConfiguration.classInit
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        let urlString = "https://licensing.bitmovin.com/impression"
        let url = URL(string: urlString)!
        FireMock.enabled(true)
        FireMock.register(mock: BitMovinMock.success, forURL: url, httpMethod: MockHTTPMethod.post)
        
        Timberjack.register()
        
        
        

        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    enum BitMovinMock: FireMockProtocol {
        public var bundle: Bundle { return Bundle.main }
        
        public var afterTime: TimeInterval { return 0.0 }
        
        public var parameters: [String]? { return nil }
        
        public var headers: [String : String]? { return nil }
        
        public var statusCode: Int { return 204 }
        
        public var httpVersion: String? { return "1.1" }
        
        public var name: String? { return "Fetch News" }
        
        
        func mockFile() -> String {
            return ""
        }
        
        case success
        case successEmpty
        case failedParameters
        
    }


}

