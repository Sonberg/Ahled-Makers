//
//  TableViewController.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-30.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import Firebase
import UITableViewCell_Badge

class TableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    // MARK : - Variables
    var screen = UIScreen.main.bounds
    var user : User = User()
    var detailViewController: MasterViewController? = nil
    var routes : [Route] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func didTouchClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title =  "Statistik"
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
        self.returnUserRef { (user : User) in
            self.user = user
            self.loadData()
        }
    }
    
    
    func loadData() {
        let ref = FIRDatabase.database().reference().child("routes")
        ref.queryOrderedByKey().observe(.childAdded) { (snap : FIRDataSnapshot) in
            let route = Route(snap: snap)
        
            if route.createdBy == self.user.id {
                for child in snap.childSnapshot(forPath: "stops").children.allObjects as! [FIRDataSnapshot] {
                    var stop = Stop(snap: child)
                    for childPost in child.childSnapshot(forPath: "posts").children.allObjects as! [FIRDataSnapshot] {
                        stop.posts.append(Post(snap: childPost))
                    }
                    
                    stop.visitors = SwiftyAccordionCells()
                    stop.visitors?.append(SwiftyAccordionCells.HeaderItem(value: "Besökare"))
                    for visitor in child.childSnapshot(forPath: "visitedBy").children.allObjects as! [FIRDataSnapshot] {
                        stop.visitors?.append(SwiftyAccordionCells.Item(value: visitor.value as! String))
                    }
                    
                    route.stops.append(stop)
                }
                
                self.routes.append(route)
                self.tableView.reloadData()
                self.selectDefault()
            }
        }
    }


    // MARK: - TableView
    
    func selectDefault() {
        if self.routes.count > 0 {
            let initialIndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: initialIndexPath, animated: true, scrollPosition:UITableViewScrollPosition.none)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.performSegue(withIdentifier: "showDetail", sender: initialIndexPath)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let route = self.routes[indexPath.row]
        cell.textLabel?.tintColor = .gray
        cell.textLabel?.text = route.name
        cell.badgeString = String(route.stops.count)
        cell.badgeColor = Library.sharedInstance.colors[route.color]
        if route.stops.count == 0 {
            // TODO : - Disable cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            if cell.isSelected {
                cell.textLabel?.tintColor = .white
                cell.accessoryView?.tintColor = .white
            } else {
                cell.textLabel?.tintColor = .darkGray
                cell.accessoryView?.tintColor = .darkGray

            }
        }
        
        if self.routes[indexPath.row].stops.count > 0 {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let VC = segue.destination as! MasterViewController
            let index : NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
            VC.route = self.routes[index.row]
        }
    }


}
