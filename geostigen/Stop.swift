//
//  Stop.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Foundation
import FirebaseStorage
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
            
            if data["url"] != nil {
                self.url = data["url"] as! String
            }
            
            if data["visitedBy"] != nil {
                self.visitedBy = data["visitedBy"] as! [String]
                print(self.visitedBy)
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
    
    var isNew : Bool = false
    var isLocked : Bool = true
    var image : UIImage? = nil
    var color : String = ""
    var number : Int = 0
    var url : String = ""
    
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func getImage( completion: @escaping (UIImage) -> Void)  {
        if self.url != "" {
            FIRStorage.storage().reference(forURL: self.url).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                if (data != nil) {
                    completion(UIImage(data: data!)!)
                }
            })
        }
    }

    
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
            "url" : self.url,
            "lat" : self.lat,
            "long" : self.long,
            "visitedBy" : self.visitedBy
        ]
        
        if self.id.characters.count > 0 {
            ref.updateChildValues(data)
        } else {
            ref.setValue(data)
        }
        
        if self.image != nil {
            print("Saving image...")
            let data : Data = UIImageJPEGRepresentation(self.image!, 0.8)!
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            let storage = FIRStorage.storage().reference().child("images").child("posts").child(parentId).child(randomString(length: 6)).put(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    ref.child("url").setValue(downloadURL)
                }
            }
        }
        
    }
    
    func delete(parentId : String) {
        if self.id.characters.count > 0 {
            FIRDatabase.database().reference().child("routes").child(parentId).child("stops").child(self.id).removeValue()
        }
    }
}

