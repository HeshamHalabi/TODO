//
//  CustomPresentAnimator.swift
//  Task05.03
//
//  Created by Hesham on 3/10/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class CustomPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to),
        let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let toVCEndFrame = transitionContext.finalFrame(for: toVC)
        var toVCstartFrame = toVCEndFrame
        toVCstartFrame.origin.y -= UIScreen.main.bounds.height
        toVC.view.frame = toVCstartFrame
        
        transitionContext.containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            toVC.view.frame = toVCEndFrame
            fromVC.view.alpha = 0.5
        }) { (_) in
            fromVC.view.alpha = 1
            transitionContext.completeTransition(true)
        }
//        toVC.view.alpha = 0
//        transitionContext.containerView.addSubview(toVC.view)
//
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
//            toVC.view.alpha = 1
//        }) { (_) in
//            transitionContext.completeTransition(true)
//        }
    }
    

}
