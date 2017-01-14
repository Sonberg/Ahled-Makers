//
//  SmallCardTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-14.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class SmallCardTableViewCell: UITableViewCell {
    
    // MARK : - Outlet
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!

    func updateUI(route : Route) -> Void {
        nameLabel.text = route.name
        nameLabel.textColor = UIColor.darkGray
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 3.0
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowOpacity = 0.8
        contentView.backgroundColor = UIColor.groupTableViewBackground
        editLabel.font = UIFont.fontAwesome(ofSize: 16)
        editLabel.textColor = UIColor.lightGray
        editLabel.text = String.fontAwesomeIcon(.pencil)
    }
}
