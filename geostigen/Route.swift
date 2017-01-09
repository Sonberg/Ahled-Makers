//
//  Route.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

struct Route {
    
    init() {}
    init(snap : FIRDataSnapshot) {
        if let data : NSDictionary = snap.value as? NSDictionary {
            self.id = snap.key
            
            if data["name"] != nil {
                self.name = data["name"] as! String
            }
            
            if data["desc"] != nil {
                self.desc = data["desc"] as! String
            }
            
            if data["image"] != nil {
                self.image = data["image"] as! Int
            }
            
            if data["color"] != nil {
                self.color = data["color"] as! Int
            }
    
        }
    }
    
    var id : String = ""
    var name : String = ""
    var desc : String = ""
    var image : Int = 0
    var color : Int = 0
    var stops : [Stop] = []
    var createdBy : String = ""
    
    func save()  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("routes").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("routes").childByAutoId()
        }
        ref.setValue([
            "name" : self.name,
            "desc" : self.desc,
            "image" : self.image,
            "color" : self.color
            ])
    }
    
    func delete() {
        if self.id.characters.count > 0 {
            FIRDatabase.database().reference().child("routes").child(self.id).removeValue()
        }
    }
}
