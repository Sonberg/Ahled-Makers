//
//  Route.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import FirebaseDatabase

class Route {
    
    init() {}
    init(snap : FIRDataSnapshot) {
        if let data : NSDictionary = snap.value as? NSDictionary {
            self.id = snap.key
            
            if data["name"] != nil {
                self.name = data["name"] as! String
            }
            
            if data["desc"] != nil {
                self.desc = data["desc"] as! String
            }
            
            if data["image"] != nil {
                self.image = data["image"] as! Int
            }
            
            if data["color"] != nil {
                self.color = data["color"] as! Int
            }
            
            if data["lat"] != nil {
                self.lat = data["lat"] as! Double
            }
            
            if data["long"] != nil {
                self.long = data["long"] as! Double
            }
    
        }
    }
    
    var id : String = ""
    var name : String = ""
    var desc : String = ""
    var image : Int = 0
    var color : Int = 0
    var lat : Double = Double(0)
    var long : Double = Double(0)
    var stops : [Stop] = []
    var createdBy : String = ""
    
    func updateCenter() {
        let mapView = MKMapView()
        var annotations : [MKAnnotation] = []
        
        for stop in self.stops {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            annotations.append(annotation)
        }
        
        mapView.showAnnotations(annotations, animated: false)
        let center = mapView.centerCoordinate
        self.lat = center.latitude
        self.long = center.longitude
        
        self.save()
    }
    
    func save()  {
        var ref: FIRDatabaseReference!
        
        if self.id.characters.count > 0 {
            ref = FIRDatabase.database().reference().child("routes").child(self.id)
        } else {
            ref = FIRDatabase.database().reference().child("routes").childByAutoId()
        }
        
        let data : [String : Any] = [
            "name" : self.name,
            "desc" : self.desc,
            "image" : self.image,
            "color" : self.color,
            "lat" : self.lat,
            "long" : self.long
        ]
        
        if self.id.characters.count > 0 {
            ref.updateChildValues(data)
        } else {
            ref.setValue(data)
        }
        
        
    }
    
    func delete() {
        if self.id.characters.count > 0 {
            FIRDatabase.database().reference().child("routes").child(self.id).removeValue()
        }
    }
}
