//
//  Library.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Foundation

class Library {
    class var sharedInstance: Library {
        struct Static {
            static let instance = Library()
        }
        return Static.instance
    }
    
    let images : [UIImage] = [#imageLiteral(resourceName: "01dsd.jpg"),#imageLiteral(resourceName: "01f.jpg"),#imageLiteral(resourceName: "02fss.jpg"),#imageLiteral(resourceName: "02sd.jpg"),#imageLiteral(resourceName: "4wfw.jpg"),#imageLiteral(resourceName: "89u.jpg"),#imageLiteral(resourceName: "as.jpg"),#imageLiteral(resourceName: "asa.jpg"),#imageLiteral(resourceName: "be.jpg"),#imageLiteral(resourceName: "dsd.jpg"),#imageLiteral(resourceName: "fd.jpg"),#imageLiteral(resourceName: "gwg.jpg"),#imageLiteral(resourceName: "gwgw.jpg"),#imageLiteral(resourceName: "jjio.jpg"),#imageLiteral(resourceName: "kj.jpg"),#imageLiteral(resourceName: "klö.jpg"),#imageLiteral(resourceName: "opi.jpg"),#imageLiteral(resourceName: "opti.jpg"),#imageLiteral(resourceName: "po.jpg"),#imageLiteral(resourceName: "sasda.jpg"),#imageLiteral(resourceName: "sds.jpg"),#imageLiteral(resourceName: "tregr.jpg"),#imageLiteral(resourceName: "vwv.jpg")]
    
    let colors = [
        UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 1),
        UIColor(red: 0.12, green: 0.81, blue: 0.43, alpha: 1),
        UIColor(red: 0.17, green: 0.59, blue: 0.87, alpha: 1),
        UIColor(red: 0.61, green: 0.34, blue: 0.72, alpha: 1),
        UIColor(red: 0.2, green: 0.29, blue: 0.37, alpha: 1),
        UIColor(red: 0.95, green: 0.77, blue: 0, alpha: 1),
        UIColor(red: 0.91, green: 0.49, blue: 0.02, alpha: 1),
        UIColor(red: 0.91, green: 0.29, blue: 0.21, alpha: 1),
        UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1),
        UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1),
        UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    ]
}
