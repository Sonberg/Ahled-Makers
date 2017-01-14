//
//  HeaderTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-04.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import CoreLocation

class HeaderTableViewCell: UITableViewCell {

    // MARK : - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var mapIcon: UILabel!
    
    func updateUI(stop : Stop) {
        self.backgroundColor = .clear
        mapIcon.font = UIFont.fontAwesome(ofSize: 20)
        mapIcon.textColor = UIColor.darkGray
        mapIcon.text = String.fontAwesomeIcon(.mapMarker)
        
        getPlacemark(forLocation: CLLocation(latitude: stop.lat, longitude: stop.long)) {
            (originPlacemark, error) in
            if let err = error {
                print(err)
            } else if originPlacemark != nil {
                self.headerLabel.text = originPlacemark?.name
            }
        }
    

    
        self.descLabel.text = stop.desc
    }
    


}
