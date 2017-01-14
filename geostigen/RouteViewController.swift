//
//  DetailViewController.swift
//  geostigen
//
//  Created by Per Sonberg on 2017-01-03.
//  Copyright © 2017 Per Sonberg. All rights reserved.
//

import UIKit
import Presentr
import DynamicButton
import TransitionTreasury
import TransitionAnimation

protocol RouteViewDelegate : class {
    func setNavigationBarName(title: String)
    func getViewHeight() -> CGFloat
    func changeCloseButtonIcon(type : DynamicButtonStyle.Type)
    func didUpdateProgress(progress : CGFloat)
    func didChangeRightButtons(buttons : [UIBarButtonItem])
    func didChangeLeftButtons(buttons : [UIBarButtonItem])
}

class RouteViewController: UIViewController, RouteViewDelegate {

    // MARK: - Outlet
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var progressView: UIProgressView!
    
    //MARK: - Variables
    let screen : CGRect = UIScreen.main.bounds
    var closeButton : DynamicButton?
    var user : User = User()
    var route : Route = Route()
    
    func presenter() -> Presentr {
        let screen = UIScreen.main.bounds
        let presenter = Presentr(presentationType: PresentationType.custom(width: ModalSize.custom(size: Float(self.cardView.bounds.width)), height: ModalSize.custom(size: Float(self.cardView.bounds.height)), center: ModalCenterPosition.center))
        presenter.transitionType = .crossDissolve
        presenter.dismissTransitionType = .crossDissolve
        presenter.backgroundOpacity = 0
        presenter.dismissOnSwipe = true
        return presenter
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        updateUI()
    }
    
    
    func updateUI() {
        // MARK: - Navigation progressBar
        self.navigationBar.setBackgroundImage(UIColor.white.as1ptImage(), for: .default)
        
        // MARK: - Card View
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 3.0
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowOpacity = 0.8
        
        // MARK: - Close Button
        closeButton = DynamicButton(style: DynamicButtonStyle.close)
        closeButton!.frame = CGRect(x: 42, y: 42, width: 38, height: 38)
        closeButton!.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton!.strokeColor = .gray
        closeButton!.addTarget(self, action: #selector(RouteViewController.dismissView), for: .touchUpInside)
        view.addSubview(closeButton!)
  }
    
    func dismissView() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    // MARK: - Progress View
    func setProgress(float : CGFloat) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(float)
        }
    }
    
    // MARK : - RouteViewDelegate
    func didUpdateProgress(progress: CGFloat) {
        self.progressView.progress = Float(progress)
    }
    
    func didChangeRightButtons(buttons: [UIBarButtonItem]) {
        self.navigationBar.topItem?.rightBarButtonItems = buttons

    }
    
    func didChangeLeftButtons(buttons: [UIBarButtonItem]) {
        self.navigationBar.topItem?.leftBarButtonItems = buttons
    }
    
    func changeCloseButtonIcon(type: DynamicButtonStyle.Type) {
        self.closeButton?.setStyle(type, animated: true)
    }
    
    func getViewHeight() -> CGFloat {
        return self.view.bounds.height
    }
    
    func setNavigationBarName(title: String) {
        self.navigationBar.topItem?.title = title
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is RouteNavigationViewController {
            let nav = segue.destination as? RouteNavigationViewController
            let vc = nav?.viewControllers.first as? RouteMapViewController
            vc?.route = self.route
            vc?.user = self.user
        }
    }
    

}
