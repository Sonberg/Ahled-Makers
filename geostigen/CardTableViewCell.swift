//
//  CardTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import CoreLocation

class CardTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(route : Route, location : CLLocation?) -> Void {
        thumbnailView.image = Library.sharedInstance.images[route.image]
        nameLabel.text = route.name
        descLabel.text = route.desc
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 3.0
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowOpacity = 0.8
        contentView.backgroundColor = UIColor.groupTableViewBackground
            //UIColor(colorLiteralRed: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
        if location != nil && route.lat != Double(0) {
            distanceLabel.text = String(describing: Int(Double((location?.distance(from: CLLocation(latitude: route.lat, longitude: route.long)))!))) + " m"
        } else {
            distanceLabel.textColor = .clear
        }
    }

}
