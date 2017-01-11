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
    var user : User = User()
    var stops : [SpringImageView] = []
    var route : Route = Route()
    let regionRadius : Int = 100
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = .coverHorizontalFromRight // Optional
        return presenter
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if self.user.type == .admin {
            initStops()
        }
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

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    
    
    //MARK : - UI
    func updateUI() {
        self.routeViewController?.navigationBar.topItem?.title = self.route.name
        let edit = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        edit.setImage(UIImage.fontAwesomeIcon(name: .edit, textColor: Library.sharedInstance.colors[4], size: CGSize(width: 30, height: 30)), for: .normal)
        edit.addTarget(self, action: #selector(didTouchEditStops(_:)), for: .touchUpInside)
        self.routeViewController?.navigationBar.topItem?.rightBarButtonItems = [UIBarButtonItem(customView: edit)]
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
                
                if self.route.createdBy == self.user.id {
                    stop.isLocked = false
                }
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
    
    // MARK : - Progress
    func updateProgress() {
        let all : Int = self.route.stops.count
        var finnish : Int = 0
        for stop in self.route.stops {
            if !stop.isLocked {
                finnish = finnish + 1
            }
        }
        
        print(finnish/all)
        if self.routeViewController != nil {
            print("setting progress")
            print(CGFloat(finnish)/CGFloat(all))
            self.routeViewController?.setProgress(float: CGFloat(finnish)/CGFloat(all))
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
    var selectedStop : Stop = Stop()
    var appendButton : SpringImageView?
    var isEditingStops: Bool = false
    func didTouchEditStops(_ sender : UIButton) {
        self.isEditingStops = !self.isEditingStops
        
        for i in 0...(self.stops.count - 1) {
            let view = self.stops[i]
            if self.isEditingStops {
                if (view.accessibilityHint != nil) {
                    sender.setImage(UIImage.fontAwesomeIcon(name: .times, textColor: Library.sharedInstance.colors[4], size: CGSize(width: 30, height: 30)), for: .normal)
                    view.animation = "squeeze"
                    view.duration = 1
                    view.delay = 1
                    view.repeatCount = 999
                    view.animate()
                }
            } else {
                view.repeatCount = 0
                view.layer.removeAllAnimations()
                sender.setImage(UIImage.fontAwesomeIcon(name: .edit, textColor: Library.sharedInstance.colors[4], size: CGSize(width: 30, height: 30)), for: .normal)
                
            }
        }
        self.updateProgress()
    }
    
    func userDidEnterRegionFor(index: Int) {
        print("In position")
        let stop = self.route.stops[index]
        self.route.stops[index].isLocked = false
        if self.route.createdBy != self.user.id && self.route.stops[index].visitedBy.index(of: self.user.id) == nil {
            self.route.stops[index].visitedBy.append(self.user.id)
            self.route.stops[index].save(parentId: self.route.id)
        }
        print(self.route.stops[index].visitedBy)
        for i in 0...(self.scrollView.subviews.count - 1) {
            if self.scrollView.subviews[i].accessibilityHint == stop.id {
                let view = self.scrollView.subviews[i] as! SpringImageView
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    print("setting")
                    view.setImageWith(String(index + 1), color: Library.sharedInstance.colors[4], circular: true)
                    //view.animation = "pop"
                    //view.animate()
                }
            }
        }
    }
    
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
                if isEditingStops {
                     self.selectedStop = stop
                    print("editing:" + stop.id)
                    self.performSegue(withIdentifier: "createStopSegue", sender: sender)
                } else {
                    self.performSegue(withIdentifier: "stopSegue", sender: sender)
                }
            }
        }
        if !(sender.accessibilityHint != nil && !isEditingStops) {
            self.performSegue(withIdentifier: "createStopSegue", sender: sender)
        }
    }
    
    func addStop(stop : Stop) {
        print(stop)
        var offset = 0
        if self.user.type == .admin {
            offset = 1
        } 
        
        let index = self.stops.count
        let image = SpringImageView(frame: CGRect(x: 80 * index, y: 0, width: 60, height: 60))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RouteMapViewController.stopTapped(sender:)))
        tapGesture.accessibilityHint = stop.id
         if stop.isLocked && self.user.id != self.route.createdBy && stop.visitedBy.index(of: self.user.id) == nil {
            image.setImageWith(String.fontAwesomeIcon(name: .lock), color: Library.sharedInstance.colors[self.route.color], circular: true, textAttributes: [ NSFontAttributeName: UIFont.fontAwesome(ofSize: 30), NSForegroundColorAttributeName: UIColor.white ])
         } else {
            let update = self.route.stops.index(where: { (new : Stop) -> Bool in
                if new.id == stop.id {
                    return true
                }
                return false
            })
            self.route.stops[update!].isLocked = false
            
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
        self.updateProgress()
    }
    
    
    // MARK : - Location
    func location() {
        print("location")
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            mapView.showAnnotations(self.mapView.annotations, animated: true)
            for annotation in self.mapView.annotations {
                if annotation is MKUserLocation {} else {
                    /*
                     let a = MKMapPoint(x: (locations.last?.coordinate.latitude)!, y: (locations.last?.coordinate.longitude)!)
                     let b = MKMapPoint(x: annotation.coordinate.latitude, y: annotation.coordinate.longitude)
                     let meters = MKMetersBetweenMapPoints(a, b)
                     print(meters)
                     */
                    
                    let dis = locations.last?.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
                    if Int(dis as Double!) < self.regionRadius {
                        for index : Int in 0...(self.stops.count - 1)  {
                            let stop = self.route.stops[index]
                            if stop.name == annotation.title! && stop.isLocked {
                                userDidEnterRegionFor(index: index)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isEditingStops = false
        if segue.destination is StopViewController && self.routeViewController != nil {
            let vc = segue.destination as! StopViewController
            vc.routeViewController = self.routeViewController
            vc.route = self.route
            vc.stop = self.selectedStop
            self.routeViewController?.closeButton?.setStyle(DynamicButtonStyle.arrowLeft, animated: true)
            self.routeViewController?.navigationBar.topItem?.rightBarButtonItems = []

        }
        
        if segue.destination is CreateStopViewController && self.routeViewController != nil {
            let vc = segue.destination as! CreateStopViewController
            vc.routeViewController = self.routeViewController
            vc.route = self.route
            vc.stop = self.selectedStop
            self.routeViewController?.closeButton?.setStyle(DynamicButtonStyle.arrowLeft, animated: true)
            
        }
        
        self.selectedStop = Stop()
    }


}
