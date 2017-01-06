//
//  TRViewControllerTransitionDelegate.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/20/15.
//  Copyright © 2016 TransitionTreasury. All rights reserved.
//

import UIKit
/// Transition(Present) Animation Delegate Object
open class TRViewControllerTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    /// The transition animation object
    open var transition: TRViewControllerAnimatedTransitioning
    
    open var previousStatusBarStyle: TRStatusBarStyle?
    /**
     Init method
     
     - parameter method: the present method option
     - parameter status: default is .Present
     
     - returns: Transition Animation Delegate Object
     */
    public init(method: TransitionAnimationable, status: TransitionStatus = .present) {
        transition = method.transitionAnimation()
        super.init()
    }
    /**
     Update transition status
     
     - parameter status: .Present or .Dismiss
     */
    open func updateStatus(_ status: TransitionStatus) {
        transition.transitionStatus = status
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionStatus = .present
        return transition
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionStatus = .dismiss
        return transition
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = transition as? TransitionInteractiveable else {
            return nil
        }
        return transition.interacting ? transition.percentTransition : nil
    }
    
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = transition as? TransitionInteractiveable else {
            return nil
        }
        return transition.interacting ? transition.percentTransition : nil
    }
    
}
