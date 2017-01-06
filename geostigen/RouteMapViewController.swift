//
//  RouteMapViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-04.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

/*
 TODO:
 1. Strech header with number + color
 2. Heading + desc under
 3. Card with content by users
 4. card button to add more content
 5. open/completed badge
 */

import UIKit
import MapKit
import Spring
import Presentr
import FontAwesome_swift
import DynamicButton
import CoreLocation
import FirebaseDatabase
import TransitionTreasury
import TransitionAnimation
import UIImageView_Letters

class RouteMapViewController: UIViewController, MKMapViewDelegate, ModalTransitionDelegate, CLLocationManagerDelegate  {
    
    // MARK : - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopContraint: NSLayoutConstraint!
    
    
    // MARK : - Actions
    func didTouchEdit(_ sender : Any) {
        print("edit")
    }
    
    
    // MARK : - Variables
    var tr_presentTransition : TRViewControllerTransitionDelegate?
    var routeViewController : RouteViewController?
    var locationManager : CLLocationManager!
    var stops : [SpringImageView] = []
    var route : Route = Route()
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = .coverHorizontalFromRight // Optional
        return presenter
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        initStops()
        updateUI()
        syncFirebase()
        location()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.scrollViewTopContraint.constant = self.view.bounds.height - 80
        })
        
        if self.routeViewController != nil {
            self.routeViewController?.closeButton?.setStyle(DynamicButtonStyle.close, animated: true)
        }
        

        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

    }

    
    
    //MARK : - UI
    func updateUI() {
        self.routeViewController?.navigationBar.topItem?.title = self.route.name
        let edit = UIBarButtonItem(title: "Redigera", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchEdit(_:)))
        edit.tintColor = Library.sharedInstance.colors[4]
        
        self.routeViewController?.navigationBar.topItem?.rightBarButtonItems = [edit]
    }
    
    
    // MARK : - Firebase
    func syncFirebase() {
        let ref = FIRDatabase.database().reference().child("routes").child(self.route.id).child("stops")
        ref.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            var stop = Stop(snap: snap)
            stop.number = self.route.stops.count + 1
            
            if stop.lat != Double(0) && stop.long != Double(0) {
                let location = CLLocationCoordinate2DMake(stop.lat, stop.long)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = location;
                annotation.title = stop.name;
                
                if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                    stop.isLocked = false
                }
                
                self.mapView.addAnnotation(annotation)
            } else {
                stop.isLocked = false
            }
            
            self.route.stops.append(stop)
            self.addStop(stop: stop)
        }
        ref.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
            let stop = Stop(snap: snap)
            for index in 0...(self.route.stops.count - 1) {
                if self.route.stops[index].id == stop.id {
                    self.route.stops[index] = stop
                }
            }
        }
        ref.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
            let stop = Stop(snap: snap)
            print(snap)
            for index in 0...(self.route.stops.count - 1) {
                if self.route.stops[index].id == stop.id {
                    self.route.stops.remove(at: index)
                }
            }
        }
    }
    
    // MARK : - Screen orientation
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        for stop in self.stops {
            stop.alpha = 0
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let width = 80 * self.stops.count
        self.scrollView.contentInset.left = CGFloat(Int(self.view.bounds.width) / 2 - width / 2)
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.scrollViewTopContraint.constant = self.view.bounds.height - 80
            for stop in self.stops {
                stop.alpha = 1
            }
        })
    }
    
    // MARK: - Stops
    var selectedStop : Stop?
    var appendButton : SpringImageView?
    
    func initStops() {
        self.appendButton = SpringImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RouteMapViewController.stopTapped(sender:)))
        
        self.appendButton?.autohide = true
        self.appendButton?.animation = "slideUp"
        self.appendButton?.setImageWith("+", color: Library.sharedInstance.colors[self.route.color].withAlphaComponent(0.6), circular: true)
        self.appendButton?.isUserInteractionEnabled = true
        self.appendButton?.addGestureRecognizer(tapGesture)
        self.scrollView.addSubview(self.appendButton!)
        self.stops.insert(self.appendButton!, at: 0)
        
        let width = 80
        let leftInset : CGFloat = CGFloat(Int(self.view.bounds.width) / 2 - width / 2)
        print(self.view.bounds.width)
        print(leftInset)
        if self.route.stops.count == 0 {
            UIView.animate(withDuration: 0.1, delay: 0.1 * Double(0), animations: {
                self.scrollView.contentInset.left = leftInset
            }, completion: { (finnish : Bool) in
                //image.animate()
            })
        }
    }
    
    
    func stopTapped(sender : SpringImageView) {
        for stop in self.route.stops {
            if stop.id == sender.accessibilityHint {
                self.selectedStop = stop
                self.performSegue(withIdentifier: "stopSegue", sender: sender)
            }
        }
        if !(sender.accessibilityHint != nil) {
            self.selectedStop = Stop()
            self.performSegue(withIdentifier: "createStopSegue", sender: sender)
        }
    }
    
    func addStop(stop : Stop) {
        print(stop)
        let offset = 1
        let index = self.stops.count
        let image = SpringImageView(frame: CGRect(x: 80 * index, y: 0, width: 60, height: 60))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RouteMapViewController.stopTapped(sender:)))
        tapGesture.accessibilityHint = stop.id
        
         if stop.isLocked {
            image.setImageWith(String.fontAwesomeIcon(name: .lock), color: Library.sharedInstance.colors[self.route.color], circular: true, textAttributes: [ NSFontAttributeName: UIFont.fontAwesome(ofSize: 30), NSForegroundColorAttributeName: UIColor.white ])
         } else {
            image.setImageWith(String(index + 1), color: Library.sharedInstance.colors[self.route.color], circular: true)
        }
        
        //self.route.stops[index].image = image.image
        
        /*
         image.autohide = true
         image.animation = "slideUp"
         */
        
        image.accessibilityHint = stop.id
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGesture)
        self.scrollView.addSubview(image)
        self.stops.append(image)
        
        let width = 80 * (index + offset)
        let leftInset : CGFloat = CGFloat(Int(self.view.bounds.width) / 2 - width / 2)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
    }
    
    
    // MARK : - Location
    func location() {
        locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        checkMapPositionPremission()
    }
    
    func checkMapPositionPremission() -> Void {
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            let title = "Saknar tillåtelse"
            let body = "Du har tidigare nekat applikationen tillgång till din position. För att kunna använda tjänsten måste du tillåta detta i applikationens inställningar"
            
            let controller = Presentr.alertViewController(title: title, body: body)
            let okAction = AlertAction(title: "Ok", style: .cancel) {
                self.dismiss(animated: true, completion: nil)
            }
            
            
            controller.addAction(okAction)
            
            presenter.presentationType = .alert
            customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is StopViewController && self.routeViewController != nil {
            let vc = segue.destination as! StopViewController
            vc.routeViewController = self.routeViewController
            vc.route = self.route
            vc.stop = self.selectedStop!
            self.routeViewController?.closeButton?.setStyle(DynamicButtonStyle.arrowLeft, animated: true)
            self.routeViewController?.navigationBar.topItem?.rightBarButtonItems = []

        }
        
        if segue.destination is CreateStopViewController && self.routeViewController != nil {
            let vc = segue.destination as! CreateStopViewController
            vc.routeViewController = self.routeViewController
            vc.route = self.route
            vc.stop = self.selectedStop!
            self.routeViewController?.closeButton?.setStyle(DynamicButtonStyle.arrowLeft, animated: true)
            
        }
        
        self.selectedStop = nil
    }


}
