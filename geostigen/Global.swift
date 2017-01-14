//
//  Global.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import Foundation
import BadgeSwift
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


extension UIProgressView {
    
    @IBInspectable var barHeight : CGFloat {
        get {
            return transform.d * 2.0
        }
        set {
            // 2.0 Refers to the default height of 2
            let heightScale = newValue / 2.0
            let c = center
            transform = CGAffineTransform(scaleX: 1.0, y: heightScale)
            center = c
        }
    }
}

extension UITableViewCell {
    // Get string from coordinate
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
        
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
    
    func positionBadge(_ badge: UIView) {
        badge.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        // Center the badge vertically in its container
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1, constant: 0)
        )
        
        // Center the badge horizontally in its container
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1, constant: 0)
        )
        
        view.addConstraints(constraints)
    }
}

extension UILabel {
    convenience init(badgeText: String, color: UIColor = UIColor.red, fontSize: CGFloat = UIFont.smallSystemFontSize) {
        self.init()
        text = " \(badgeText) "
        textColor = UIColor.white
        backgroundColor = color
        
        font = UIFont.systemFont(ofSize: fontSize)
        layer.cornerRadius = fontSize * CGFloat(0.6)
        clipsToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0))
    }
}


