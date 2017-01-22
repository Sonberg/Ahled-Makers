//
//  CreateViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-05.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Former
import Photos
import RKDropdownAlert


class CreateViewController: FormViewController {
    
    // MARK : - Variables
    var user : User = User()
    var route : Route = Route()
    var delete : UIBarButtonItem?
    var save : UIBarButtonItem?
    var close : UIBarButtonItem?
    
    // MARK : - Actions
    func didTouchSave(_ sender : Any) {
        if self.route.name.characters.count < 5 {
            RKDropdownAlert.title("Titel behövs", message: "Du måste ha en title (minst 5 tecken)", backgroundColor: UIColor.red, textColor: UIColor.white, time: 5)
        } else {
            self.route.save()
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didTouchDelete(_ sender : Any) {
        self.route.delete()
        dismiss(animated: true, completion: nil)
    }
    
    func didTouchClose(_ sender : Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didSwipe(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("Sidebar View controller hade been deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        if self.route.createdBy == "" {
            self.route.createdBy = self.user.id
        }
        
        
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.text = self.route.name
            }.configure {
                $0.placeholder = "Vad ska stigen heta?"
                $0.text = self.route.name
            }.onTextChanged { (text : String) in
            self.navigationItem.title = text
            self.route.name = text
        }
        
        let descRow = TextViewRowFormer<FormTextViewCell> {
            $0.textView.text = self.route.desc
            }.configure {
                $0.placeholder = "Beskriv stigen"
                $0.text = self.route.desc
            }.onTextChanged { (text : String) in
            self.route.desc = text
        }
        
        let colorListRow = CustomRowFormer<ColorListCell>(instantiateType: .Nib(nibName: "ColorListCell")) {
            $0.colors = Library.sharedInstance.colors
            if self.route.color > -1 {
                $0.select(item: self.route.color)
            } else {
                $0.select(item: 0)
            }
            $0.onColorSelected = { index in
                self.route.color  = index
            }
            }.configure {
                $0.rowHeight = 60
                $0.cell.backgroundColor = .clear
        }
        
        let imageListRow = CustomRowFormer<ImageListCell>(instantiateType: .Nib(nibName: "ImageListCell")) {
            //$0.images = Library.sharedInstance.images
            if self.route.image > -1 {
                $0.select(item: self.route.image)
            } else {
                $0.select(item: 0)
            }
            
            $0.onImageSelected = { index in
                self.route.image  = index
            }
            }.configure {
                $0.rowHeight = 60
                $0.cell.backgroundColor = .clear
                $0.cell.separatorInset = .zero
                $0.cell.layoutMargins = .zero
        }

        
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 30
            }
        }
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        //imageListRow
        let imageSection = SectionFormer(rowFormer: colorListRow)
            .set(headerViewFormer: createHeader("Omslagsbild & primärfärg"))
        
        
        let titleRowSection = SectionFormer(rowFormer: titleRow, descRow)
            .set(headerViewFormer: createSpaceHeader())

        
        former.append(sectionFormer: titleRowSection,  imageSection)
    }

    func updateUI() {
        self.navigationItem.title = ""
        
        // Save Button
        self.save = UIBarButtonItem(title: "Spara", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchSave(_:)))
        self.save?.tintColor = UIColor(red: 0.1, green: 0.74, blue: 0.61, alpha: 1)
        
        // Delete Button
        self.delete = UIBarButtonItem(title: "Ta bort", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchDelete(_:)))
        self.delete?.tintColor = UIColor(red: 0.91, green: 0.29, blue: 0.21, alpha: 1)
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = 30

        self.navigationItem.setRightBarButtonItems([self.save!, space, self.delete!], animated: true)
        
        
        self.close = UIBarButtonItem(title: "Avbryt", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchClose(_:)))
        self.close?.tintColor = Library.sharedInstance.colors[4]
        self.navigationItem.setLeftBarButtonItems([self.close!], animated: true)
        }
    
}


