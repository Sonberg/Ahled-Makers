//
//  user.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-28.
//  Copyright © 2016 persimon. All rights reserved.
//

import Firebase
import Foundation
import FirebaseAuth

struct User {
    init(snap : FIRDataSnapshot) {
        let data : NSDictionary = snap.value as! NSDictionary
        self.id = snap.key
        
        if data["uid"] != nil  {
            self.uid =  data["uid"] as! String
        }
        
        if data["type"] != nil  {
            self.type = UserType(rawValue: data["type"] as! String)
        }
        
        if data["firstName"] != nil  {
            self.firstName = data["firstName"] as! String
        }
        
        if data["lastName"] != nil  {
            self.lastName =  data["lastName"] as! String
        }
        
        if data["email"] != nil  {
            self.email = data["email"] as! String
        }
        
    }
    
    init() {}
    
    var id : String = ""
    var uid : String = ""
    var type : UserType = .user
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""

}
