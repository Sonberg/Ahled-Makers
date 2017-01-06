//
//  TRTabBarTransitionDelegate.swift
//  TransitionTreasury
//
//  Created by DianQK on 16/1/19.
//  Copyright © 2016年 TransitionTreasury. All rights reserved.
//

import UIKit

open class TRTabBarTransitionDelegate: NSObject, UITabBarControllerDelegate {
    
    open var transitionAnimation: UIViewControllerAnimatedTransitioning
    
    weak var tr_delegate: TRTabBarControllerDelegate?
    
    public init(method: TransitionAnimationable) {
        transitionAnimation = method.transitionAnimation()
        super.init()
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return tr_delegate?.tr_tabBarController(tabBarController, shouldSelectViewController: viewController) ?? true
    }

    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tr_delegate?.tr_tabBarController(tabBarController, didSelectViewController: viewController)
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        tr_delegate?.tr_tabBarController(tabBarController, willBeginCustomizingViewControllers: viewControllers)
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        tr_delegate?.tr_tabBarController(tabBarController, willEndCustomizingViewControllers: viewControllers, changed: changed)
    }

    open func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        tr_delegate?.tr_tabBarController(tabBarController, didEndCustomizingViewControllers: viewControllers, changed: true)
    }
    
    open func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return tr_delegate?.tr_tabBarControllerSupportedInterfaceOrientations(tabBarController) ?? UIApplication.shared.supportedInterfaceOrientations(for: nil)
    }

    open func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return tr_delegate?.tr_tabBarControllerPreferredInterfaceOrientationForPresentation(tabBarController) ?? UIInterfaceOrientation.unknown
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transitionAnimation = transitionAnimation as? TabBarTransitionInteractiveable else {
            return nil
        }
        return transitionAnimation.interacting ? transitionAnimation.percentTransition : nil
    }
    
    open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionAnimation
    }
}
