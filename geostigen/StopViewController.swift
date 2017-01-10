//
//  StopViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Presentr
import Firebase
import DynamicButton
import FirebaseDatabase
import MXParallaxHeader


class StopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Variables
    let inputTextField: UITextField = UITextField()
    var routeViewController : RouteViewController?
    var user : User = User()
    var route : Route = Route()
    var stop : Stop = Stop()
    var posts : [Post] = []
    
    
    // MARK : - Actions
    @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        
        let headerView : UIImageView = UIImageView()
        headerView.image = #imageLiteral(resourceName: "earyikg21d4-maja-petric")
        headerView.contentMode = .scaleAspectFill
        
        
        tableView.parallaxHeader.view = headerView;
        tableView.parallaxHeader.height = 200;
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.minimumHeight = 0;
        
        syncFirebase()
    }

    func presenter() -> Presentr {
        let presenter = Presentr(presentationType: PresentationType.custom(width: ModalSize.custom(size: Float(self.view.bounds.width)), height: ModalSize.custom(size: 300.0), center: ModalCenterPosition.bottomCenter))
        presenter.transitionType = TransitionType.coverVertical
        presenter.backgroundOpacity = 0
        return presenter
    }
    
    // MARK : - Firebase
    func syncFirebase() {
        let ref = FIRDatabase.database().reference().child("routes").child(route.id).child("stops").child(stop.id).child("posts")
        
        ref.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            self.posts.insert(Post(snap: snap), at: 0)
            self.tableView.reloadData()
        }
        ref.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
            let post = Post(snap: snap)
            print(snap)
            for index in 0...(self.posts.count - 1) {
                if self.posts[index].id == post.id {
                    self.posts[index] = post
                }
            }
            self.tableView.reloadData()
        }
        ref.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
            let post = Post(snap: snap)
            print(snap)
            for index in 0...(self.posts.count - 1) {
                if self.posts[index].id == post.id {
                    self.posts.remove(at: index)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK : - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as? HeaderTableViewCell
            cell?.updateUI(stop : stop)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as? InformationTableViewCell
            cell?.updateUI(post : posts[indexPath.row - 1])
            return cell!
        }
    }
    
    
    // MARK : - Chat field
    var bottomConstraint: NSLayoutConstraint?
    
    func setup() {
        self.inputTextField.delegate = self
        self.inputTextField.placeholder = "Bidra med information (minst 10 tecken)"
        setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(StopViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StopViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StopViewController.dismissKeyboard))
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        self.bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        view.addGestureRecognizer(tap)
        
        setupInputComponents()
    }
    
    func keyboardWillShow(_ notification: NSNotification){
        let screen = UIScreen.main.bounds
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize?.height)! + self.messageInputContainerView.frame.size.height, right: 0)
         bottomConstraint?.constant = ((keyboardSize?.height)! * -1) + ((screen.height - (self.routeViewController?.view.bounds.height)! + 60)/2)
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification){
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    fileprivate func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        sendButton.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    
    
    let sendButton: DynamicButton = {
        let button = DynamicButton(style: DynamicButtonStyle.caretRight)
        button.strokeColor = #colorLiteral(red: 0.1418670714, green: 0.6769689322, blue: 0.5964415669, alpha: 1)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // MARK : - Keyboard
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func sendMessage() -> Void {
        if (self.inputTextField.text?.characters.count)! > 9 {
            var post = Post()
            post.user = "Per Sonberg"
            post.text = self.inputTextField.text!
            post.created = String(describing: Date())
            post.save(routeId: self.route.id, stopId: self.stop.id)
            self.inputTextField.text = ""
            self.tableView.reloadData()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage()
        return true
    }
}


extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options:   NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
