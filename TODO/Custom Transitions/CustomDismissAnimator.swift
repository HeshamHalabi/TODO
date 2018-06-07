//
//  CustomDismissAnimator.swift
//  Task05.03
//
//  Created by Hesham on 3/10/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class CustomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                return
        }
        
        var fromVCEndFrame = fromVC.view.frame
        fromVCEndFrame.origin.y -= UIScreen.main.bounds.height
        
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.sendSubview(toBack: toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = fromVCEndFrame
        
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    

}
