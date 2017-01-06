//
//  AppendTableViewCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-04.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Presentr

class AppendTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var appendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.backgroundColor = Library.sharedInstance.colors[5].withAlphaComponent(0.2)
        appendButton.backgroundColor = Library.sharedInstance.colors[5]
    }
    
    func updateUI() -> Void {
        //contentView.backgroundColor = UIColor(colorLiteralRed: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }
    
    
    func presenter() -> Presentr {
        let presenter = Presentr(presentationType: PresentationType.custom(width: ModalSize.custom(size: Float(self.contentView.bounds.width)), height: ModalSize.custom(size: 300.0), center: ModalCenterPosition.bottomCenter))
        presenter.transitionType = TransitionType.coverVertical
        presenter.backgroundOpacity = 0
        return presenter
    }
}
