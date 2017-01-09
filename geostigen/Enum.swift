//
//  Enum.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-09.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import Foundation

enum UserType {
    init(rawValue: String) {
        switch rawValue {
        case "admin":
            self = .admin
            break
            
        case "user":
            self = .user
            break
            
        default:
            self = .user
            break
        }
    }
    
    case admin
    case user
}
