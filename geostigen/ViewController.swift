//
//  ViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2016-12-23.
//  Copyright © 2016 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase
import Presentr
import FirebaseAuth
import CoreLocation
import FirebaseDatabase
import DynamicButton

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    // MARK : - Actions
    @IBAction func didTouchLogout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    @IBAction func didTouchAdd(_ sender: Any) {
        self.showRoute(route: Route())
    }
    
    // MARK: - Variables
    var ref : FIRDatabaseReference?
    var user : User!
    var locationManager : CLLocationManager!
    var location : CLLocation! = nil
    var routes : [Route] = []
    var mine : [Route] = []
    
    deinit {
        print("View controller hade been deinit")
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        setupLocation()
        self.addBarButton.tintColor = .clear
        self.addBarButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        self.ref?.removeAllObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        returnUserRef { (user : User) in
            self.user = user
            
            self.syncFirebase()
            if user.type == .admin {
                self.addBarButton.tintColor = .black
                self.addBarButton.isEnabled = true
            }
        }
    }
    
    func presenter() -> Presentr {
        let screen = UIScreen.main.bounds
        let width = Float(max(round(min((screen.width), (screen.height)) * 0.75), CGFloat(240)))
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: width), height: ModalSize.full, center: ModalCenterPosition.custom(centerPoint: CGPoint(x: CGFloat(Int(screen.width) - (Int(width)/2)), y: screen.height/2))))
        presenter.transitionType = .coverHorizontalFromRight
        presenter.dismissTransitionType = TransitionType.flipHorizontal
        presenter.backgroundOpacity = 0.2
        presenter.roundCorners = false
        return presenter
    }
    
    // MARK : - Firebase
    func syncFirebase() {
        self.ref = FIRDatabase.database().reference().child("routes")

        ref?.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            let route = Route(snap: snap)
            
            if self.routes.index(where: { (r : Route) -> Bool in
                if r.id == route.id {
                    return true
                }
                return false
            }) == nil {
                if route.createdBy == self.user.id {
                    self.mine.append(route)
                }
                
                self.routes.append(route)
                self.sortByLocation()
                self.tableView.reloadData()
            }
        }
        ref?.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
            let route = Route(snap: snap)
            print(snap)
            for index in 0...(self.routes.count - 1) {
                if self.routes[index].id == route.id {
                   self.routes[index] = route
                }
            }
            if self.mine.count > 0 {
                for index in 0...(self.mine.count - 1) {
                    if self.mine[index].id == route.id {
                        self.mine[index] = route
                    }
                }
            }
            self.sortByLocation()
            self.tableView.reloadData()
        }
        ref?.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
            let route = Route(snap: snap)
            print(snap)
            for index in 0...(self.routes.count - 1) {
                if self.routes[index].id == route.id {
                    self.routes.remove(at: index)
                }
            }
            if self.mine.count > 0 {
                for index in 0...(self.mine.count - 1) {
                    if self.mine[index].id == route.id {
                        self.mine.remove(at: index)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func sortByLocation() {
        if self.location != nil {
            self.routes.sort(by: {
                Int((self.location?.distance(from: CLLocation(latitude: $0.lat, longitude: $0.long)))!) < Int((self.location?.distance(from: CLLocation(latitude: $1.lat, longitude: $1.long)))!)
            })
            
            if self.mine.count > 1 {
                self.mine.sort(by: {
                    Int((self.location?.distance(from: CLLocation(latitude: $0.lat, longitude: $0.long)))!) < Int((self.location?.distance(from: CLLocation(latitude: $1.lat, longitude: $1.long)))!)
                })
            }
            self.tableView.reloadData()
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
        self.location = locations.last
        self.tableView.reloadData()
    }
    
    // MARK : - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print(tableView.rectForRow(at: indexPath))
        
            self.performSegue(withIdentifier: "RouteMapSegue", sender: self)
        } else {
            self.showRoute(route: self.routes[indexPath.row])
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.mine.count > 0 {
            return 2
        }
        
        if self.routes.count > 0 {
            return 1
        }
        
        return 0
    }
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Stigar i närheten"
        }
        
        return "Mina stigar"
    }
 */
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.routes.count
        } else {
            return self.mine.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell : CardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
            cell.updateUI(route : self.routes[indexPath.row], location : self.location)
            return cell
        }
        let cell : SmallCardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "small", for: indexPath) as! SmallCardTableViewCell
        cell.updateUI(route : self.mine[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.user.type == .admin {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if self.user.type == .admin && indexPath.section == 0 {
            
            if self.user.id == self.routes[indexPath.row].createdBy {
                let edit = UITableViewRowAction(style: .normal, title: "Redigera") { action, index in
                    self.showRoute(route: self.routes[index.row])
                }
                edit.backgroundColor = UIColor.lightGray
                return [edit]
            } else {
                let clone = UITableViewRowAction(style: .normal, title: "Klona") { action, index in
                    print("klona")
                }
                clone.backgroundColor = Library.sharedInstance.colors[2]
                return [clone]
            }
        }
        
        return []
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.user.type == .admin && indexPath.section == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    
    // MARK: - Navigation
    func showRoute(route : Route) {
        if self.user.type == .admin {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuNavigationController") as! RouteNavigationViewController
            let vc = destinationViewController.viewControllers.first as! CreateViewController
            vc.route = route
            vc.user = self.user
            customPresentViewController(self.presenter(), viewController: destinationViewController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is RouteMapViewController {
            let indexPath = tableView.indexPathForSelectedRow
            let vc = segue.destination as! RouteMapViewController
            vc.user = self.user
            if indexPath?.section == 0 {
               vc.route = self.routes[(indexPath?.row)!]
            } else {
                vc.route = self.mine[(indexPath?.row)!]
            }
            
            self.tableView.deselectRow(at: indexPath!, animated: true)

    
        }
    }
    
}


