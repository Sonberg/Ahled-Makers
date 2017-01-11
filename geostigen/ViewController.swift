//
//  ViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2016-12-23.
//  Copyright © 2016 Per Sonberg. All rights reserved.
//

import UIKit
import Presentr
import SideMenu
import Firebase
import FirebaseAuth
import CoreLocation
import FirebaseDatabase

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
    
    // MARK: - Variables
    var user : User!
    var locationManager : CLLocationManager!
    var location : CLLocation! = nil
    var routes : [Route] = []
    var mine : [Route] = []
    let images : [UIImage] = [#imageLiteral(resourceName: "earyikg21d4-maja-petric"), #imageLiteral(resourceName: "xn_crzwxgdm-andreas-p"), #imageLiteral(resourceName: "rbthqzjd_vu-thaddaeus-lim"), #imageLiteral(resourceName: "jktv__bqmaa-brooke-lark"), #imageLiteral(resourceName: "u_nsisvpeak-christian-joudrey")]
    
    let presenter: Presentr = {
        let screen = UIScreen.main.bounds
        let presenter = Presentr(presentationType: PresentationType.custom(width: ModalSize.full, height: ModalSize.full, center: ModalCenterPosition.center))
        presenter.transitionType = .coverHorizontalFromRight
        presenter.backgroundOpacity = 0.1
        return presenter
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupLocation()
        self.addBarButton.tintColor = .clear
        self.addBarButton.isEnabled = false
        
        returnUserRef { (user : User) in
            self.user = user
            
            self.syncFirebase()
            if user.type == .admin {
                self.addBarButton.tintColor = .black
                self.addBarButton.isEnabled = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    // MARK : - Firebase
    func syncFirebase() {
        let ref = FIRDatabase.database().reference().child("routes")

        ref.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            let route = Route(snap: snap)
            if route.createdBy == self.user.id {
                self.mine.append(route)
            }
            self.routes.append(route)
            self.sortByLocation()
            self.tableView.reloadData()
        }
        ref.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
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
        ref.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
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
        tableView.deselectRow(at: indexPath, animated: true)
        showCard(indexPath: indexPath)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Stigar i närheten"
        }
        
        return "Mina stigar"
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.routes.count
        } else {
            return self.mine.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
        if indexPath.section == 0 {
            cell.updateUI(route : self.routes[indexPath.row], location : self.location)
        } else {
            cell.updateUI(route : self.mine[indexPath.row], location : self.location)
        }

        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.user.type == .admin {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if self.user.type == .admin {
            let edit = UITableViewRowAction(style: .normal, title: "Redigera") { action, index in
                self.performSegue(withIdentifier: "createSegue", sender: indexPath)
                self.tableView.endEditing(true)
            }
            edit.backgroundColor = UIColor.lightGray
            return [edit]
        }
        
        return []
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.user.type == .admin {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    // MARK: - Navigation
    
    func showCard(indexPath : IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Route", bundle: nil)
        let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController
        
        if indexPath.section == 0 {
            destinationViewController.route = self.routes[indexPath.row]
        } else {
            destinationViewController.route = self.mine[indexPath.row]
        }
        
        destinationViewController.user = self.user
        
        customPresentViewController(presenter, viewController: destinationViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is UISideMenuNavigationController && sender is IndexPath && user.type == .admin {
            let nav = segue.destination as! UISideMenuNavigationController
            let vc = nav.viewControllers.first as! CreateViewController
            vc.user = self.user
            
            if (sender as! IndexPath).section == 0 {
                vc.route = self.routes[(sender as! IndexPath).row]
            } else {
                vc.route = self.routes[(sender as! IndexPath).row]
            }
        }
    }
    
}


