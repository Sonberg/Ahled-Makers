//
//  Stop.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

struct Post {
    
    init() {}
    init(snap : FIRDataSnapshot) {
        if let data : NSDictionary = snap.value as? NSDictionary {
            self.id = snap.key
            
            if data["user"] != nil {
                self.user = data["user"] as! String
            }
            
            if data["text"] != nil {
                self.text = data["text"] as! String
            }
            
            if data["created"] != nil {
                self.created = data["created"] as! String
            }
        }
    }
    
    var id : String = ""
    var user : String = ""
    var text : String = ""
    var created : String = ""

    
    func save(routeId : String, stopId : String)  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("routes").child(routeId).child("stops").child(stopId).child("posts").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("routes").child(routeId).child("stops").child(stopId).child("posts").childByAutoId()
        }
        ref.setValue([
            "user" : self.user,
            "text" : self.text,
            "created" : self.created,
            ])
    }
    
    func delete(routeId : String, stopId : String) {
        if self.id.characters.count > 0 {
            FIRDatabase.database().reference().child("routes").child(routeId).child("stops").child(stopId).child("posts").child(self.id).removeValue()
        }
    }
}
