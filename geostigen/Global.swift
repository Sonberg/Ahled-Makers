//
//  Global.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseAuth
import SVProgressHUD

extension UIApplication {
    
    var screenShot: UIImage?  {
        
        let layer = keyWindow!.layer
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
}

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


extension UIViewController {
    
    // MARK : - User from Firebase
    func returnUserRef(completion: @escaping (User) -> Void) -> Void {
        var isRetured : Bool = false
        if let user = FIRAuth.auth()?.currentUser {
            let ref = FIRDatabase.database().reference().child("users")
            ref.queryOrderedByKey().observe(.childAdded, with: { (snap : FIRDataSnapshot) in
                let data : NSDictionary = snap.value as! NSDictionary
                if data["uid"] as? String == user.uid {
                    if !isRetured {
                        isRetured = true
                        completion(User(snap: snap))
                    }
                }
            })
        }
    }
    
    func showSpinner() -> Void {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor(white: 1, alpha: 0.4))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setRingRadius(CGFloat(28))
        SVProgressHUD.setCornerRadius(CGFloat(50))
        SVProgressHUD.show()
    }
    
    func hideSpinner() -> Void {
        SVProgressHUD.dismiss()
    }
}
