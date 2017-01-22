//
//  MasterViewController.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-30.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import MapKit
import FontAwesome_swift
import DynamicButton
import MXParallaxHeader

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Variables
    let screen = UIScreen.main.bounds
    var route : Route = Route()
    var previouslySelectedHeaderIndex: Int?
    var selectedHeaderIndex: Int?
    var selectedItemIndex: Int?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = 36
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 140
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let headerView = MKMapView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 350))
        for stop in self.route.stops {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.long)
            headerView.addAnnotation(annotation)
        }
        
        headerView.isUserInteractionEnabled = false
        headerView.showAnnotations(headerView.annotations, animated: false)
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.height = 300
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.view = headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let stop = self.route.stops[indexPath.section]
        
        if indexPath.row == 0 {
            if stop.url.characters.count > 0 {
                return 180
            } else {
                return 0
            }
        } else if indexPath.row > 2 {
            if let item = stop.visitors?.items[indexPath.row - 3] {
                if item is SwiftyAccordionCells.HeaderItem {
                    return 44
                } else if (item.isHidden) {
                    return 0
                }
            }
            
        }
        
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.route.stops.count
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.route.stops[section].visitors == nil {
            return 3
        }
        
        return 3 + self.route.stops[section].visitors!.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stop = self.route.stops[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! ImageTableViewCell
            cell.backgroundColor = Library.sharedInstance.colors[self.route.color]
            
            if stop.url.characters.count > 0 {
                stop.getImage(completion: { (image : UIImage) in
                    cell.headerImage.image = image
                })
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "name", for: indexPath)
            cell.textLabel?.text = stop.name
            return cell
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messages", for: indexPath)
            cell.badgeColor = Library.sharedInstance.colors[self.route.color]
            cell.badgeString = String(stop.posts.count)
            return cell
        }
        
        
        // MARK : - Display visitors
        if let item = stop.visitors?.items[indexPath.row - 3] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let value = item.value
            cell.textLabel?.text = value
            
            if item as? SwiftyAccordionCells.HeaderItem != nil {
                
                cell.accessoryType = .none
                cell.badgeColor = Library.sharedInstance.colors[self.route.color]
                if stop.visitedBy.count > 0 {
                    cell.badgeFont = UIFont.fontAwesome(ofSize: cell.badgeFont.pointSize)
                    cell.badgeString = String(stop.visitedBy.count) + " - " + String.fontAwesomeIcon(.chevronDown)
                    
                } else {
                    cell.badgeString = String(stop.visitedBy.count)
                }
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row > 2 {
            let stop = self.route.stops[indexPath.section]
            if stop.visitedBy.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = self.route.stops[indexPath.section]
        var cell = UITableViewCell()
        
        if tableView.cellForRow(at: indexPath) != nil {
            cell = tableView.cellForRow(at: indexPath)!
            cell.badgeColor = Library.sharedInstance.colors[self.route.color]
        }
        
        if indexPath.row > 2 {
            let item = stop.visitors?.items[indexPath.row - 3]
            if item is SwiftyAccordionCells.HeaderItem {
                if self.selectedHeaderIndex == nil {
                    self.selectedHeaderIndex = (indexPath as NSIndexPath).row - 3
                } else {
                    self.previouslySelectedHeaderIndex = self.selectedHeaderIndex
                    self.selectedHeaderIndex = (indexPath as NSIndexPath).row - 3
                }
                
                if let previouslySelectedHeaderIndex = self.previouslySelectedHeaderIndex {
                    print("collaps")
                    stop.visitors?.collapse(previouslySelectedHeaderIndex)
                    cell.badgeFont = UIFont.fontAwesome(ofSize: cell.badgeFont.pointSize)
                    cell.badgeString = String(stop.visitedBy.count) + " - " + String.fontAwesomeIcon(.chevronDown)
                }
                
                if self.previouslySelectedHeaderIndex != self.selectedHeaderIndex {
                    print("expand")
                    stop.visitors?.expand(self.selectedHeaderIndex!)
                    cell.badgeFont = UIFont.fontAwesome(ofSize: cell.badgeFont.pointSize)
                    cell.badgeString = String(stop.visitedBy.count) + " - " + String.fontAwesomeIcon(.chevronUp)
                } else {
                    self.selectedHeaderIndex = nil
                    self.previouslySelectedHeaderIndex = nil
                }
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
