//
//  Global.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Foundation
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
