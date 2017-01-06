//
//  MapCell.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UITableViewCell, MKMapViewDelegate {
    
    // MARK : - Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Action
    @IBAction func didTapOnMap(_ sender: Any) {
        mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                mapView.removeAnnotation($0)
            }
        }
        
        let location = (sender as AnyObject).location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        self.addAnnotation(coordinate: coordinate)
        onLocationSelected!(coordinate)
    }
    
    
    // MARK : - Variables
    var location : CLLocationCoordinate2D = CLLocationCoordinate2D()
    var onLocationSelected: ((CLLocationCoordinate2D) -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    
    private func configure() {
        selectionStyle = .none
        mapView.delegate = self
        if !location.latitude.isNaN {
            addAnnotation(coordinate: location)
        }
    }
    
    func addAnnotation(coordinate : CLLocationCoordinate2D) -> Void {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
}
