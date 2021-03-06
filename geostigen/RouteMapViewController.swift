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
import BadgeSwift
import FontAwesome_swift
import DynamicButton
import CoreLocation
import BubbleTransition
import FirebaseDatabase
import TransitionTreasury
import TransitionAnimation
import UIImageView_Letters

class RouteMapViewController: UIViewController, MKMapViewDelegate, ModalTransitionDelegate, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate  {
    
    /// Retain transition delegate.
    public var tr_presentTransition: TRViewControllerTransitionDelegate?

    
    // MARK : - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    // MARK : - Actions
    func didTouchEdit(_ sender : Any) {
        print("edit")
    }
    
    func didTouchDismiss(_ sender : Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK : - Variables
    var locationManager : CLLocationManager!
    let transition = BubbleTransition()
    var ref : FIRDatabaseReference?
    var user : User = User()
    var stops : [SpringImageView] = []
    var route : Route = Route()
    let regionRadius : Int = 10
    
    deinit {
        print("Route Map View controller hade been deinit")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.removeConstraints(self.progressView.constraints)
        mapView.delegate = self
        updateUI()
        location()
        
        self.scrollView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        initStops()
        syncFirebase()
        
        self.scrollViewTopContraint.constant = self.view.bounds.height - 170
        self.scrollView.alpha = 1
        self.scrollView.isPagingEnabled = true
    
        //self.routeViewDelegate?.changeCloseButtonIcon(type: DynamicButtonStyle.close)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        self.ref?.removeAllObservers()
    }

    
    
    //MARK : - UI
    func updateUI() {
        self.progressView.progress = 0
        self.progressView.trackTintColor = Library.sharedInstance.colors[self.route.color].withAlphaComponent(0.2)
        self.progressView.progressTintColor = Library.sharedInstance.colors[self.route.color]
        self.navigationItem.title = self.route.name
        
        let edit = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        edit.setImage(UIImage.fontAwesomeIcon(.edit, textColor:.gray, size: CGSize(width: 30, height: 30)), for: .normal)
        edit.addTarget(self, action: #selector(didTouchEditStops(_:)), for: .touchUpInside)
        
        let location = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        location.addTarget(self, action: #selector(RouteMapViewController.didTouchFindMe(_:)), for: .touchUpInside)
        location.setImage(UIImage.fontAwesomeIcon(.locationArrow, textColor: .gray, size: CGSize(width: 30, height: 30)), for: .normal)
        
        if self.user.id == self.route.createdBy && self.user.type == .admin {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: location), UIBarButtonItem(customView: edit)]
        } else {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: location)]
        }
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(RouteMapViewController.didTouchDismiss(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
    }
    
    
    // MARK : - Firebase
    func syncFirebase() {
        
        self.ref = FIRDatabase.database().reference().child("routes").child(self.route.id).child("stops")
        
        
        ref?.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            var stop = Stop(snap: snap)
            stop.number = self.route.stops.count + 1

            
            if stop.lat != Double(0) && stop.long != Double(0) {
                self.removeAnnotation(id: stop.id)
                stop = self.addAnnotation(stop: stop)
            } else {
                stop.isLocked = false
            }
            
            
            if let index = self.route.stops.index(where: { (s : Stop) -> Bool in
                if s.id == stop.id {
                    return true
                }
                
                return false
            }) {
                stop.isNew = self.route.stops[index].isNew
                stop.isLocked = self.route.stops[index].isLocked
                print(self.route.stops[index])
                self.route.stops[index] = stop
            } else {
                self.route.stops.append(stop)
            }

            
            if !self.stops.contains(where: { (spring : SpringImageView) -> Bool in
                if (spring.accessibilityHint != nil) && spring.accessibilityHint! == stop.id {
                    return true
                }
                
                return false
            }) {
                self.addStop(stop: stop)
            }
            
            
            
                self.locationManager.startUpdatingLocation()

        }
        
        ref?.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
            print("childChanged")
            var stop = Stop(snap: snap)
            for index in 0...(self.route.stops.count - 1) {
                if self.route.stops[index].id == stop.id {
                    stop.isNew = self.route.stops[index].isNew
                    stop.isLocked = self.route.stops[index].isLocked
                    self.route.stops[index] = stop
                }
            }
            
            self.removeAnnotation(id: stop.id)
            stop = self.addAnnotation(stop: stop)
        }
        ref?.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
            let stop = Stop(snap: snap)
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
        self.progressView.progress = Float(finnish)/Float(all)
        //self.routeViewDelegate?.didUpdateProgress(progress: )
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
            self.scrollViewTopContraint.constant = self.view.bounds.height - 170
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
                    sender.setImage(UIImage.fontAwesomeIcon(.times, textColor: .gray, size: CGSize(width: 30, height: 30)), for: .normal)
                    view.animation = "squeeze"
                    view.duration = 1
                    view.delay = 1
                    view.repeatCount = 999
                    view.animate()
                }
            } else {
                view.repeatCount = 0
                view.layer.removeAllAnimations()
                sender.setImage(UIImage.fontAwesomeIcon(.edit, textColor: .gray, size: CGSize(width: 30, height: 30)), for: .normal)
                
            }
        }
        self.updateProgress()
    }
    
    func userDidEnterRegionFor(index: Int) {
        print("In position")

        self.selectedStop = self.route.stops[index]
        self.route.stops[index].isLocked = false
        
        // MARK : - Track visitors
        if self.route.createdBy != self.user.id && self.route.stops[index].visitedBy.index(of: self.user.id) == nil {
            
            if !self.route.stops[index].visitedBy.contains(self.user.id) {
                self.route.stops[index].visitedBy.append(self.user.id)
            }
            
            self.route.stops[index].save(parentId: self.route.id)
        }
        
        // MARK : - Unlocking
        if self.selectedStop.isNew {
            if self.route.stops[index].name.characters.count > 0 && self.route.stops[index].isNew == true {
                self.route.stops[index].isNew = false
                self.performSegue(withIdentifier: "unlockSegue", sender: self)
            }
            
        }
        
        // MARK : - Find circle view
        for i in 0...(self.scrollView.subviews.count - 1) {
            if self.scrollView.subviews[i].accessibilityHint == self.selectedStop.id {
                let view = self.scrollView.subviews[i] as! SpringImageView
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    
                    // MARK : - Animate Unlock
                    view.setImageWith(String(index + 1), color: Library.sharedInstance.colors[self.route.color], circular: true)
                    view.animation = "pop"
                    view.animate()
                    
                }
            }
        }
    }
    
    func initStops() {
        // MARK : - Add append button
        if self.user.id == self.route.createdBy && self.user.type == .admin {
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
    }
    
    // MARK : - Handle tap
    func stopTapped(sender : SpringImageView) {
        for stop in self.route.stops {
            if stop.id == sender.accessibilityHint {
                print(sender.accessibilityHint)
                self.selectedStop = stop
                if isEditingStops {
                    self.selectedStop = stop
                    self.performSegue(withIdentifier: "createStopSegue", sender: sender)
                } else {
                    print("trying to segue")
                    if stop.isLocked == false {
                        print("not locked")
                        self.performSegue(withIdentifier: "stopSegue", sender: sender)
                    }
                }
            }
        }
        if !(sender.accessibilityHint != nil && !isEditingStops) {
            self.performSegue(withIdentifier: "createStopSegue", sender: sender)
        }
    }
    
    // MARK : - Append stop
    func addStop(stop : Stop) {
        var offset = 0
        if self.user.type == .admin && self.user.id == self.route.createdBy {
            offset = 1
        }
        
        print(offset)
        
        print(self.route.stops.count)
        var index = self.route.stops.index { (s : Stop) -> Bool in
            if s.id == stop.id {
                return true
            }
            
            return false
        }
        
        if (index != nil) {
            index = index! + 1
            let image = SpringImageView(frame: CGRect(x: 80 * index!, y: 0, width: 60, height: 60))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RouteMapViewController.stopTapped(sender:)))
            tapGesture.accessibilityHint = stop.id
            if stop.isLocked && self.user.id != self.route.createdBy && stop.visitedBy.index(of: self.user.id) == nil {
                image.setImageWith(String.fontAwesomeIcon(.lock), color: Library.sharedInstance.colors[self.route.color], circular: true, textAttributes: [ NSFontAttributeName: UIFont.fontAwesome(ofSize: 30), NSForegroundColorAttributeName: UIColor.white ])
            } else {
                let update = self.route.stops.index(where: { (new : Stop) -> Bool in
                    if new.id == stop.id {
                        return true
                    }
                    return false
                })
                self.route.stops[update!].isLocked = false
                print(String(describing: index!))
                image.setImageWith(String(describing: index!), color: Library.sharedInstance.colors[self.route.color], circular: true)
            }
            
            image.accessibilityHint = stop.id
            image.isUserInteractionEnabled = true
            image.addGestureRecognizer(tapGesture)
            
            self.scrollView.addSubview(image)
            self.stops.append(image)
            
            let width = 80 * (index! + offset)
            let leftInset : CGFloat = CGFloat(Int(self.view.bounds.width) / 2 - width / 2)
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
            self.updateProgress()
        }
    }
    
    
    // MARK : - Location
    func didTouchFindMe(_ sender : Any) {
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
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
        
        // MARK : - Have position?
        if locations.last != nil {
            
            // MARK : - Show all on map
            mapView.showAnnotations(self.mapView.annotations, animated: false)
            for annotation in self.mapView.annotations {
                
                // MARK : - Check if annotation is in position
                if annotation is MKUserLocation {} else {
                    let dis = locations.last?.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
                    if Int(dis as Double!) < self.regionRadius {
                        
                        // MARK : - Find stop connected to annotation
                        if self.route.stops.count > 0 {
                            for index : Int in 0...(self.route.stops.count - 1)  {
                                if self.route.stops[index].name == annotation.title! {
                                    // MARK : - Unlock
                                    userDidEnterRegionFor(index: index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK : - Map View
    func addAnnotation(stop : Stop) -> Stop {
        var stop = stop
        let location = CLLocationCoordinate2DMake(stop.lat, stop.long)
        let annotation = MKPointAnnotation()
        let overlay: MKCircle = MKCircle(center: location, radius: CLLocationDistance(self.regionRadius))
        
        
        annotation.coordinate = location
        annotation.title = stop.name
        annotation.accessibilityHint = stop.id
        overlay.accessibilityHint = stop.id
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            stop.isLocked = false
        }
        
        self.mapView.addAnnotation(annotation)
        self.mapView.add(overlay)
        
        if self.route.createdBy == self.user.id {
            stop.isLocked = false
        }
        
        return stop
    }
    
    func removeAnnotation(id : String) {
        for annotaion in self.mapView.annotations {
            if annotaion is MKPointAnnotation {
                if (annotaion as! MKPointAnnotation).accessibilityHint == id {
                    self.mapView.removeAnnotation(annotaion)
                }
            }
        }
        
        
        for overlay in self.mapView.overlays {
            if overlay is MKCircle {
                if (overlay as! MKCircle).accessibilityHint == id {
                    self.mapView.remove(overlay)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.strokeColor = UIColor.clear
        circleView.lineWidth = 0
        circleView.fillColor = Library.sharedInstance.colors[self.route.color]
        circleView.alpha = 0.4
        return circleView
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isEditingStops = false
        if segue.destination is StopViewController  {
            let vc = segue.destination as! StopViewController
            vc.user = self.user
            vc.route = self.route
            vc.stop = self.selectedStop
        }
        
        if segue.destination is CreateStopViewController  {
            let vc = segue.destination as! CreateStopViewController
            vc.route = self.route
            vc.stop = self.selectedStop
        }
        
        if segue.destination is UnlockedViewController {
            let controller = segue.destination as! UnlockedViewController
            controller.color = Library.sharedInstance.colors[self.route.color]
            controller.stop = self.selectedStop
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
        }
        
        self.selectedStop = Stop()
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        for annotation in self.mapView.annotations {
            if annotation is MKUserLocation {
                print(mapView.convert(annotation.coordinate, toPointTo: self.view))
                transition.startingPoint = mapView.convert(annotation.coordinate, toPointTo: self.view)
            }
        }
        transition.bubbleColor = Library.sharedInstance.colors[self.route.color]
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = mapView.convert(CLLocationCoordinate2D(latitude: self.selectedStop.lat, longitude: self.selectedStop.long), toPointTo: self.view)
        transition.bubbleColor = Library.sharedInstance.colors[self.route.color]
        return transition
    }


}
