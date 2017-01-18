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
import DynamicButton
import CoreLocation

class CreateStopViewController: FormViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    // MARK : - Variable
    var locationManager : CLLocationManager!
    var user : User = User()
    var route : Route = Route()
    var stop : Stop = Stop()
    var delete : UIBarButtonItem?
    var save : UIBarButtonItem?
    
    var MapRow : CustomRowFormer<MapCell>?
    
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
    
    fileprivate lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            let cell = $0
            $0.iconView.image = UIImage()
            
            if self.stop.url.characters.count > 0 {
                self.stop.getImage { (image : UIImage) in
                    cell.iconView.image = image
                }
            }
            }.configure {
                $0.text = "Välj bild från biblioteket"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                self?.presentImagePicker()
        }
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.setupLocation()
        tableView.frame.origin = CGPoint(x: 0, y: 64)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.MapRow = CustomRowFormer<MapCell>(instantiateType: .Nib(nibName: "MapCell")) {
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
        
        
        let mapRowSection = SectionFormer(rowFormer: MapRow!)
            .set(headerViewFormer: createHeader("", 0))
        
        let imageRowSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("", 6))
        
        let titleRowSection = SectionFormer(rowFormer: titleRow, descRow)
            .set(headerViewFormer: createHeader("", 12))
        
        
        former.append(sectionFormer: mapRowSection, imageRowSection, titleRowSection)
    }
    
    
    // MARK : - UI
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

        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(CreateStopViewController.didTouchClose(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
        
        if self.stop.id.characters.count > 0 {
            self.navigationItem.rightBarButtonItems = [self.save!, space, self.delete!]
        } else {
            self.navigationItem.rightBarButtonItems = [self.save!]
        }
        
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            self.imageRow.cell.iconView.image = pickedImage
            self.stop.image = pickedImage
            imageRow.cellUpdate {
                self.stop.image = pickedImage
                $0.iconView.image = pickedImage
            }
        }
    }
    
    // MARK : - Location
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations.last! as CLLocation
        
        if self.stop.lat != 0 {
            location = CLLocation(latitude: self.stop.lat, longitude: self.stop.long)
        }
            
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.MapRow?.cell.mapView.setRegion(region, animated: true)
    }
    

}

