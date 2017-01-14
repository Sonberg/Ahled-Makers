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
