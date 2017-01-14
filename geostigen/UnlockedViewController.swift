//
//  UnlockedViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-14.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import FontAwesome_swift

class UnlockedViewController: UIViewController {
    
    // MARK : - Outlet
    @IBOutlet weak var greetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK : - Variable
    var stop : Stop = Stop()
    var color : UIColor = .black
    
    // MARK : - Action
    @IBAction func didTapScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        unlockedIcon.font = UIFont.fontAwesome(ofSize: 24)
        unlockedIcon.textColor = UIColor.darkGray
        unlockedIcon.text = String.fontAwesomeIcon(.unlockAlt)
 */
        
        nameLabel.text = stop.name
        
        self.view.backgroundColor = self.color
        
        let new = UIColor(contrastingBlackOrWhiteColorOn: self.color, isFlat: true, alpha: 0.8)
        nameLabel.textColor = new
        //unlockedIcon.textColor = new
        greetLabel.textColor = new
    }
}
