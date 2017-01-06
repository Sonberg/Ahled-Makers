//
//  HeaderTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-04.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    // MARK : - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func updateUI(stop : Stop) {
        self.headerLabel.text = stop.name
        self.descLabel.text = stop.desc
    }
    


}
