//
//  SignupViewController.swift
//  Makers App
//
//  Created by Per Sonberg on 2016-09-27.
//  Copyright © 2016 persimon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RKDropdownAlert
import SVProgressHUD


class SignupViewController: UIViewController {
   
    
    // MARK : - Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    // MARK : - Actions
    @IBAction func didTouchCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func didTouchSignup(_ sender: AnyObject) {
        let fname = self.firstName.text!
        let lname = self.lastName.text!
        let mail = self.email.text!
        let word = self.password.text!
        
        if fname.characters.count == 0 || lname.characters.count == 0 || mail.characters.count == 0 || word.characters.count == 0  {
            RKDropdownAlert.title("Du måste fylla i alla fälten", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else {
            FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if error == nil {
                    if let user = FIRAuth.auth()?.currentUser {
                        // MARK : - Store data
                        for _ in user.providerData {
                            let blueprint : [String : Any] = [
                                "uid" : user.uid,
                                "type" : "user",
                                "firstName" : fname,
                                "lastName" : lname,
                                "email" : mail,
                                "photoURL" : ""
                                ] as [String : Any]
                            FIRDatabase.database().reference().child("users").childByAutoId().setValue(blueprint)
                            self.performSegue(withIdentifier: "loginSegue", sender: self)
                            self.showSpinner()
                        }
                    }
                    
                } else {
                    RKDropdownAlert.title("Ett fel inträffade", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
                }
            })
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.textColor = .black
        lastName.textColor = .black
        email.textColor = .black
        password.textColor = .black
    }
   


   
}

