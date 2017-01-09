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
import CoreLocation
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Variables
    var locationManager : CLLocationManager!
    var location : CLLocation?
    var routes : [Route] = []
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
        syncFirebase()
        setupLocation()
    }
    
    // MARK : - Firebase
    func syncFirebase() {
        let ref = FIRDatabase.database().reference().child("routes")

        ref.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            self.routes.append(Route(snap: snap))
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
        print("reloafing")
    }
    
    // MARK : - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showCard(indexPath: indexPath)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Stigar i närheten"
        }
        
        return "Dina stigar"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
        cell.updateUI(route : self.routes[indexPath.row], location : self.location)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Redigera") { action, index in
            self.performSegue(withIdentifier: "createSegue", sender: indexPath)
            self.tableView.endEditing(true)
        }
        edit.backgroundColor = UIColor.lightGray
        
        
        return [edit]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    // MARK: - Navigation
    
    func showCard(indexPath : IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Route", bundle: nil)
        let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "RouteViewController") as! RouteViewController
        destinationViewController.route = self.routes[indexPath.row]
        customPresentViewController(presenter, viewController: destinationViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is UISideMenuNavigationController && sender is IndexPath {
            let nav = segue.destination as! UISideMenuNavigationController
            let vc = nav.viewControllers.first as! CreateViewController
            vc.route = self.routes[(sender as! IndexPath).row]
        }
    }
    
}


