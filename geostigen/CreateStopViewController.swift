//
//  CreateStopViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Former
import MapKit

class CreateStopViewController: FormViewController {
    
    // MARK : - Variable
    var user : User = User()
    var routeViewController : RouteViewController?
    var route : Route = Route()
    var stop : Stop = Stop()
    var delete : UIBarButtonItem?
    var save : UIBarButtonItem?
    
    // MARK : - Actions
    func didTouchSave(_ sender : Any) {
        self.stop.save(parentId: self.route.id)
        self.route.updateCenter()
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTouchDelete(_ sender : Any) {
        self.stop.delete(parentId: self.route.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTouchClose(_ sender : Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        
        let MapRow = CustomRowFormer<MapCell>(instantiateType: .Nib(nibName: "MapCell")) {
            print(self.stop.lat)
            $0.location = CLLocationCoordinate2D(latitude: self.stop.lat, longitude: self.stop.long)
            
            
            $0.onLocationSelected = { location in
                self.stop.lat = location.latitude
                self.stop.long = location.longitude
            }
            }.configure {
                $0.rowHeight = 300
                $0.cell.backgroundColor = .clear
                $0.cell.location = CLLocationCoordinate2D(latitude: self.stop.lat, longitude: self.stop.long)
        }
        
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>().configure {
                $0.text = self.stop.name
                $0.placeholder = "Namn"
            }.onTextChanged { (text : String) in
                self.navigationItem.title = text
                self.stop.name = text
        }
        
        let descRow = TextViewRowFormer<FormTextViewCell>().configure {
                $0.text = self.stop.desc
                $0.placeholder = "Beskrivning"
            }.onTextChanged { (text : String) in
                self.stop.desc = text
        }
        
        
        
        let createHeader: ((String, Int) -> ViewFormer) = { text, height in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = CGFloat(height)
                    if text.characters.count > 0 {
                        $0.text = text
                    }
            }
        }
        
        
        let mapRowSection = SectionFormer(rowFormer: MapRow)
            .set(headerViewFormer: createHeader("", 0))
        
        let titleRowSection = SectionFormer(rowFormer: titleRow, descRow)
            .set(headerViewFormer: createHeader("", 10))
        
        
        former.append(sectionFormer: mapRowSection, titleRowSection)
    }
    
    func updateUI() {
        self.navigationItem.title = ""
        
        // Save Button
        self.save = UIBarButtonItem(title: "Spara", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchSave(_:)))
        self.save?.tintColor = UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 1)
        
        // Delete Button
        self.delete = UIBarButtonItem(title: "Ta bort", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchDelete(_:)))
        self.delete?.tintColor = UIColor(red: 0.91, green: 0.29, blue: 0.21, alpha: 1)
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = 30

        
        self.routeViewController?.navigationBar.topItem?.rightBarButtonItems = [self.save!, space, self.delete!]
        
    }

}
