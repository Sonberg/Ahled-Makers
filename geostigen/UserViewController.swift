//
//  UserViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-21.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Former
import Firebase
import DynamicButton
import FirebaseAuth
import RKDropdownAlert

class UserViewController: FormViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK : - Variables
    var user : User = User()
    var delete : UIBarButtonItem?
    var save : UIBarButtonItem?
    
    // MARK : - Actions
    func didTouchLogout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    func didTouchSave(_ sender : Any) {
        if self.user.firstName.characters.count == 0 || self.user.lastName.characters.count == 0 {
            RKDropdownAlert.title("Namn behövs", message: "Du måste ange ditt namn", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else {
            self.user.save()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func didTouchClose(_ sender : Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.updateUI()
    }
    
    // MARK : - UI
    func updateUI() {
        self.navigationItem.title = self.user.firstName + " " + self.user.lastName
        
        // Save Button
        self.save = UIBarButtonItem(title: "Spara", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchSave(_:)))
        self.save?.tintColor = UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 1)
        
        // Delete Button
        self.delete = UIBarButtonItem(title: "Logga ut", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchLogout(_:)))
        self.delete?.tintColor = UIColor(red: 0.91, green: 0.29, blue: 0.21, alpha: 1)
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = 30
        
        
        let closeButton  = DynamicButton(style: DynamicButtonStyle.arrowLeft)
        closeButton.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.strokeColor = .gray
        closeButton.addTarget(self, action: #selector(UserViewController.didTouchClose(_:)), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: closeButton), animated: true)
        self.navigationItem.rightBarButtonItems = [self.save!, space, self.delete!]
        
    }
    
    
    func configure()  {
        
        let TypeRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.enabled = false
                
                if self.user.type == .user {
                    row.text = "Student"
                } else {
                    row.text = "Administratör"
                }
            }.onSelected { row in
                self.former.deselect(animated: true)
        }
        
        
        let firstRow = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.text = self.user.firstName
            $0.placeholder = "Förnamn"
            }.onTextChanged { (text : String) in
                self.user.firstName = text
                self.navigationItem.title = self.user.firstName + " " + self.user.lastName
        }
        
        let lastRow = TextFieldRowFormer<FormTextFieldCell>().configure {
            $0.text = self.user.lastName
            $0.placeholder = "Efternamn"
            }.onTextChanged { (text : String) in
                self.user.lastName = text
                self.navigationItem.title = self.user.firstName + " " + self.user.lastName
        }
        
        
        let createHeader: ((String, Int) -> ViewFormer) = { text, height in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = CGFloat(height)
                    if text.characters.count > 0 {
                        $0.text = text
                    }
            }
        }
        
        let imageSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Profilbild", 36))
        
        let infoSection = SectionFormer(rowFormer: TypeRow, firstRow, lastRow)
            .set(headerViewFormer: createHeader("", 12))
        
        
        former.append(sectionFormer: imageSection, infoSection)
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            let cell = $0
            $0.iconView.image = UIImage()
            
            if self.user.url.characters.count > 0 {
                self.user.getImage { (image : UIImage) in
                    cell.iconView.image = image
                }
            }
            }.configure {
                $0.text = "Välj profilbild ifrån galleriet"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.former.deselect(animated: true)
                self?.presentImagePicker()
        }
    }()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            self.imageRow.cell.iconView.image = pickedImage
            self.user.image = pickedImage
            imageRow.cellUpdate {
                self.user.image = pickedImage
                $0.iconView.image = pickedImage
            }
        }
    }


}
