//
//  StopViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Firebase
import DynamicButton
import FirebaseDatabase
import MXParallaxHeader


class StopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK : - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK : - Variables
    var ref : FIRDatabaseReference?
    weak var routeViewDelegate : RouteViewDelegate?
    let inputTextField: UITextField = UITextField()
    var user : User = User()
    var route : Route = Route()
    var stop : Stop = Stop()
    var posts : [Post] = []
    let headerHeight : CGFloat = 400
    
    
    // MARK : - Actions
    @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func didTouchDismiss(_ sender : Any) {
        print("touch")
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapHeader(_ sender : Any)  {
        if self.tableView.parallaxHeader.height == self.headerHeight {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.parallaxHeader.height = ((self.tableView.parallaxHeader.view as! UIImageView).image?.size.height)!
            })
        
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.parallaxHeader.height = self.headerHeight;
            })
        }
    }
    
    deinit {
        print("Stop View controller hade been deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHeader()
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.parallaxHeader.height = 0;
        
        
        
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(StopViewController.didTouchDismiss(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
        updateUI()
        syncFirebase()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref?.removeAllObservers()
    }
    
    func setupHeader() {
        let headerView : UIImageView = UIImageView()
        headerView.contentMode = .scaleAspectFill
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StopViewController.didTapHeader(_:))))
        
        self.stop.getImage { (image : UIImage) in
            headerView.image = image
            self.tableView.parallaxHeader.view = headerView;
            self.tableView.parallaxHeader.mode = .fill
            self.tableView.parallaxHeader.minimumHeight = 0;
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.parallaxHeader.height = self.headerHeight;
            })
            
        }
    }

    
    // MARK : - Firebase
    func syncFirebase() {
        self.ref = FIRDatabase.database().reference().child("routes").child(route.id).child("stops").child(stop.id).child("posts")
        self.posts = []
        
        ref?.queryOrderedByKey().observe(FIRDataEventType.childAdded) { (snap : FIRDataSnapshot) in
            self.posts.insert(Post(snap: snap), at: 0)
            self.tableView.reloadData()
        }
        ref?.queryOrderedByKey().observe(FIRDataEventType.childChanged) { (snap : FIRDataSnapshot) in
            let post = Post(snap: snap)
            for index in 0...(self.posts.count - 1) {
                if self.posts[index].id == post.id {
                    self.posts[index] = post
                }
            }
            self.tableView.reloadData()
        }
        ref?.queryOrderedByKey().observe(FIRDataEventType.childRemoved) { (snap : FIRDataSnapshot) in
            let post = Post(snap: snap)
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
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
        return 1 + self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as? HeaderTableViewCell
            cell?.updateUI(stop : stop)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as? InformationTableViewCell
            cell?.updateUI(route: route, post : posts[indexPath.row - 1])
            return cell!
        }
    }
    
    // MARK : - UI
    func updateUI() {
        self.navigationItem.title = self.stop.name

        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(RouteMapViewController.didTouchDismiss(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
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
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
         bottomConstraint?.constant = ((keyboardSize?.height)! * -1)
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: NSNotification){
        bottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
        self.tableView.reloadData()
        self.tableView.contentInset = UIEdgeInsets(top: self.headerHeight + 64, left: 0, bottom: 50, right: 0)
        self.setupHeader()
    }
    
    
    fileprivate func setupInputComponents() {
        let topBorderView = UIView()
        let sendButton = self.sendButton()
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
    
    
    func sendButton() -> DynamicButton {
        let button = DynamicButton(style: DynamicButtonStyle.caretRight)
        button.strokeColor = Library.sharedInstance.colors[self.route.color]
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }
    
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
            post.user = self.user.firstName + " " + self.user.lastName
            post.text = self.inputTextField.text!
            post.created = String(describing: Date())
            post.save(routeId: self.route.id, stopId: self.stop.id)
            self.inputTextField.text = ""
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
