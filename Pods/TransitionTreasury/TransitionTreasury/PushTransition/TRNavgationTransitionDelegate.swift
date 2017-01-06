//
//  TRNavgationTransitionDelegate.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/20/15.
//  Copyright © 2016 TransitionTreasury. All rights reserved.
//

import UIKit
/// Transition(Push & Pop) Animation Delegate Object
open class TRNavgationTransitionDelegate: NSObject, UINavigationControllerDelegate {
    /// The transition animation object
    open var transition: TRViewControllerAnimatedTransitioning
    
    open var previousStatusBarStyle: TRStatusBarStyle?
    
    open var currentStatusBarStyle: TRStatusBarStyle?
    
    fileprivate var p_completion: (() -> Void)?
    
    /// Transition completion block
    var completion: (() -> Void)? {
        get {
            return self.transition.completion ?? p_completion
        }
        set {
            self.transition.completion = newValue
            if self.transition.completion == nil {
                p_completion = newValue
            }
        }
    }
    /// The edge gesture for pop
    lazy var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(TRNavgationTransitionDelegate.tr_edgePan(_:)))
        edgePanGestureRecognizer.edges = .left
        return edgePanGestureRecognizer
    }()
    /**
     Init method
     
     - parameter method:         the push method
     - parameter status:         default is .Push
     - parameter viewController: for edge gesture
     
     - returns: Transition Animation Delegate Object
     */
    public init(method: TransitionAnimationable, status: TransitionStatus = .push, gestureFor viewController: UIViewController?) {
        transition = method.transitionAnimation()
        super.init()
        if let transition = transition as? TransitionInteractiveable, transition.edgeSlidePop {
            viewController?.view.addGestureRecognizer(edgePanGestureRecognizer)
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push :
            transition.transitionStatus = .push
            return transition
        case .pop :
            transition.transitionStatus = .pop
            return transition
        case .none :
            return nil
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        guard let transition = transition as? TransitionInteractiveable else {
            return nil
        }
        
        return transition.interacting ? transition.percentTransition : nil
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        switch transition.transitionStatus {
        case .push :
            currentStatusBarStyle?.updateStatusBarStyle()
        case .pop :
            previousStatusBarStyle?.updateStatusBarStyle()
        default :
            fatalError("No this transition status here.")
        }
    }
    
    open func tr_edgePan(_ recognizer: UIPanGestureRecognizer) {
        
        let fromVC = transition.transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transition.transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        guard var transition = transition as? TransitionInteractiveable else {
            return
        }
        
        let view = fromVC!.view
        
        var percent = recognizer.translation(in: view).x / (view?.bounds.size.width)!
        
        percent = min(1.0, max(0, percent))

        switch recognizer.state {
        case .began :
            transition.interacting = true
            transition.percentTransition = UIPercentDrivenInteractiveTransition()
            transition.percentTransition?.startInteractiveTransition((transition as! TRViewControllerAnimatedTransitioning).transitionContext!)
            toVC!.navigationController!.tr_popViewController()
        case .changed :
            transition.percentTransition?.update(percent)
        default :
            transition.interacting = false
            if percent > transition.interactivePrecent {
                transition.cancelPop = false
                transition.percentTransition?.completionSpeed = 1.0 - transition.percentTransition!.percentComplete
                transition.percentTransition?.finish()
                fromVC?.view.removeGestureRecognizer(edgePanGestureRecognizer)
            } else {
                transition.cancelPop = true
                transition.percentTransition?.cancel()
            }
            transition.percentTransition = nil
        }
    }
}
