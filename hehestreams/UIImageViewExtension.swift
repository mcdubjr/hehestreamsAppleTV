//
//  UIImageViewExtension.swift
//  hehestreams
//
//  Created by HEHE Lover on 10/12/16.
//  Copyright © 2016 warhorse. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    public func imageFromUrl(string: String) {
        
        let url = URL(string: string)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.sync() {
                self.image = UIImage(data: data)
            }
        }
        
        task.resume()
    }
}
