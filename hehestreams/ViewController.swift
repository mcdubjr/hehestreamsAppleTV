//
//  ViewController.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/12/16.
//  Copyright © 2016 warhorse. All rights reserved.
//

import UIKit
import AVKit
import BitmovinPlayer
class ViewController: UIViewController {
    
    
    var streamURL = ""
    var drm_data = ""
    var streamJson: [String: Any]!
    
    
    var player: BitmovinPlayer?
    
    deinit {
        player?.destroy()
    }
    
    var token: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.view.backgroundColor = .black
    
        
        let urlString = massageStreamURL(self.streamJson["stream"] as! String)
        
        guard let fairplayStreamUrl = URL(string: urlString),
            let certificateUrl = URL(string: "https://prod-lic2fairplay.sd-ngp.net/licensing"),
            let licenseUrl = URL(string: "https://prod-lic2fairplay.sd-ngp.net/licensing") else {
                print("Please specify the needed resources marked with TODO in ViewController.swift file.")
                return
        }
        
        if let drmDataUrlString: String = self.streamJson["drm_data"] as? String{
            
            if let drmDataUrl = URL(string: drmDataUrlString){
                
                let task = URLSession.shared.dataTask(with: drmDataUrl) {(data, response, error) in
                    do {
                        if data != nil {
                            let responseJSON = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                            
                            self.token = responseJSON["token"] as! String
                            
                            print("Token: " + self.token)
                            DispatchQueue.main.async {
                                self.createPlayerConfiguration(fairplayStreamUrl: fairplayStreamUrl, licenseUrl: licenseUrl, certificateUrl: certificateUrl)
                                self.player?.play()
                            }
                        }
                    } catch {
                    }
                }
                
                task.resume()
            }
        }
        else{
            DispatchQueue.main.async {
                self.createPlayerConfiguration(fairplayStreamUrl: fairplayStreamUrl, licenseUrl: licenseUrl, certificateUrl: certificateUrl)
                self.player?.play()
            }
            
        }
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        player?.unload()
    }
    
    func massageStreamURL(_ url: String) -> String{
        
        var newString = url
        
        if newString.hasSuffix("ceddash.mp4.mpd") {
            newString = newString.replacingOccurrences(of: "ceddash.mp4.mpd", with: "machls.mp4.m3u8")
        }
        else if newString.hasSuffix("ceddash.mpd") {
            newString = newString.replacingOccurrences(of: "ceddash.mpd", with: "machls.m3u8")
        }
        else if newString.hasSuffix("pc.mpd"){
            newString = newString.replacingOccurrences(of: "pc.mpd", with: "machls.m3u8")
        }
        
        return newString
    }
    
    func hackBase64(t: Data) -> String {
        var e: String
        
        let typeOfData = "\(type(of: t))"
        
        if typeOfData == "String" {
            e = String(data: t, encoding: .utf8)!
        } else if typeOfData.contains("Array") {
            e = String(bytes: [UInt8](t), encoding: .utf8)!
        } else {
            if !(typeOfData == ("Array<UInt8>")) {
                return ""
            }
            
            e = String(data: t, encoding: .utf8)!
        }
        
        return e.toBase64()
    }
    
    func base64DecodeUint8Array(input: String) -> [UInt8] {
        var raw = input.fromBase64()
        let array: [UInt8] = Array(raw!.utf8)
        
        return array
    }
    
    func ab2str(buf: Data) -> String {
        return String(bytes: [UInt8](buf), encoding: .utf8)!.toBase64()
    }
    
    private func createPlayerConfiguration(fairplayStreamUrl: URL, licenseUrl: URL, certificateUrl: URL) {
        // Create player configuration
        let config = PlayerConfiguration()
        
        do {
            try config.setSourceItem(url: fairplayStreamUrl)
            
            // create drm configuration
            let fpsConfig = FairplayConfiguration(license: licenseUrl, certificateURL: certificateUrl)
            
            //////////
            
            var contentID: String = "3EE5F545C5E30F4208FFB29662FEE8B2"
            
            fpsConfig.prepareContentId = { (string: String) -> String in
                let result = string.replacingOccurrences(of: "skd://", with: "")
                
                print("Prepare content id: \(result)")
                
                contentID = result
                
                return result
            }
            
            fpsConfig.prepareCertificate = { (data: Data) -> Data in
                return Data(base64Encoded: data)!
            }
            
            fpsConfig.prepareLicense = { (data: Data) -> Data in
                print("Prepare license...")
                print(data)
                print("...")
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                let bodyJSON = responseJSON?["body"] as! [String: Any]
                var resp = bodyJSON["response"] as! String
                return Data(base64Encoded: resp)!
            }
            
            fpsConfig.prepareMessage = { (data: Data, string: String) -> Data in
                print("prep msg")
                var result: [String: Any] = [:]
                result["content_id"] = contentID
                result["device_id"] = "1"
                result["challenge"] = data.base64EncodedString()
                result["client"] = "NeuLion"
                result["cro"] = "Bearer " + self.token
                
                return try! JSONSerialization.data(withJSONObject: result)
            }
            
            //////////
            
            var headers: [String: String] = [:]
            
            headers["Authorization"] = "Bearer " + token
            headers["CustomData"] = "Bearer " + token
            
            fpsConfig.certificateRequestHeaders = headers
            fpsConfig.licenseRequestHeaders = headers
            
            /**
             * Following callbacks are available to make custom modifications:
             * fpsConfig.prepareCertificate
             * fpsConfig.prepareLicense
             * fpsConfig.prepareContentId
             * fpsConfig.prepareMessage
             *
             * Custom request headers can be set using:
             * fpsConfig.certificateRequestHeaders
             * fpsConfig.licenseRequestHeaders
             *
             * See header documentation for more details!
             */
            
            config.sourceItem?.add(drmConfiguration: fpsConfig)
            
            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)
            
            
        
            
            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
            
            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds
            
            
            view.addSubview(playerView)
            view.bringSubview(toFront: playerView)
            
            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }
    
    

}


extension ViewController: PlayerListener {
    
    func onPlay(_ event: PlayEvent) {
        print("onPlay \(event.time)")
    }
    
    func onPaused(_ event: PausedEvent) {
        print("onPaused \(event.time)")
    }
    
    func onTimeChanged(_ event: TimeChangedEvent) {
        print("onTimeChanged \(event.currentTime)")
    }
    
    func onDurationChanged(_ event: DurationChangedEvent) {
        print("onDurationChanged \(event.duration)")
    }
    
    func onError(_ event: ErrorEvent) {
        print("onError \(event.message)")
    }
    
    func onEvent(_ event: PlayerEvent) {
        print("evented")
    }
    
}


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}


