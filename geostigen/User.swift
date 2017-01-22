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
import RKDropdownAlert

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
        
        if data["url"] != nil  {
            self.url = data["url"] as! String
        }
        
    }
    
    init() {}
    
    var id : String = ""
    var uid : String = ""
    var url : String = ""
    var type : UserType = .user
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    
    var image : UIImage? = nil
    
    
    func getImage( completion: @escaping (UIImage) -> Void)  {
        if self.url != "" {
            FIRStorage.storage().reference(forURL: self.url).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                if (data != nil) {
                    completion(UIImage(data: data!)!)
                }
            })
        }
    }
    
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
    
    func save()  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("users").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("users").childByAutoId()
        }
        
        let data : [String : Any] = [
            "uid" : self.uid,
            "url" : self.url,
            "type" : String(describing: self.type),
            "firstName" : self.firstName,
            "lastName" : self.lastName,
            "email" : self.email
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
            let storage = FIRStorage.storage().reference().child("users").child(self.id).child(randomString(length: 6)).put(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    ref.child("url").setValue(downloadURL)
                }
            }
        }
        RKDropdownAlert.title("Sparat!", backgroundColor: UIColor.flatGreen, textColor: UIColor.init(contrastingBlackOrWhiteColorOn: UIColor.flatGreen, isFlat: true), time: 5)
        
    }

}
