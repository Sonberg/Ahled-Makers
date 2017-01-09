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

struct Stop {
    
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
            
            if data["lat"] != nil {
                self.lat = data["lat"] as! Double
            }
            
            if data["long"] != nil {
                self.long = data["long"] as! Double
            }
            
        }
    }
    
    var id : String = ""
    var name : String = ""
    var desc : String = ""
    var lat : Double = Double(0)
    var long : Double = Double(0)
    var posts : [Post] = []
    var visitedBy : [String] = []
    
    var isLocked : Bool = true
    var image : UIImage?
    var color : String = ""
    var number : Int = 0
    
    func save(parentId : String)  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("routes").child(parentId).child("stops").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("routes").child(parentId).child("stops").childByAutoId()
        }
        
        let data : [String : Any] = [
            "name" : self.name,
            "desc" : self.desc,
            "lat" : self.lat,
            "long" : self.long
        ]
        
        if self.id.characters.count > 0 {
            ref.updateChildValues(data)
        } else {
            ref.setValue(data)
        }
        
    }
    
    func delete(parentId : String) {
        if self.id.characters.count > 0 {
            FIRDatabase.database().reference().child("routes").child(parentId).child("stops").child(self.id).removeValue()
        }
    }
}
