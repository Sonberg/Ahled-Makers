//
//  InformationTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-06.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import UIImageView_Letters

class InformationTableViewCell: UITableViewCell {

    // MARK : - Outlet
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    func updateUI(post : Post) {
        thumbImage.setImageWith(String(describing: post.user.characters.first).uppercased(), color: .black, circular: false)
        nameLabel.text = post.user
        
        contentLabel.text = post.text
        contentLabel.sizeToFit()
        contentLabel.setNeedsDisplay()
        
        // MARK : - Timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateLabel.text = timeAgoSince(dateFormatter.date(from: post.created)!)
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 3.0
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowOpacity = 0.8
        contentView.backgroundColor = UIColor(colorLiteralRed: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }

}
