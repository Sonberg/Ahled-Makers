//
//  LoginViewController.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-16.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
   
    
    // MARK : - Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK : - Actions
    @IBAction func didTouchLogin(_ sender: AnyObject) {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.check()
        email.textColor = .black
        password.textColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.check()
    }
    
    func check() {
        if (FIRAuth.auth()?.currentUser) != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    func login() -> Void {
        FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user : FIRUser?, error : Error?) in
            if error == nil {
                if (FIRAuth.auth()?.currentUser) != nil {
                    self.email.text = ""
                    self.password.text = ""
                    
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            } else {
                print(error)
                print("Got error")
            }
        })
    }
    
}
