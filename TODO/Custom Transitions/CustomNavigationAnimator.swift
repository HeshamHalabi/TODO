//
//  CustomNavigationAnimator.swift
//  Task05.03
//
//  Created by Hesham on 3/10/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit

class CustomNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var pushing = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let toVCEndFrame = transitionContext.finalFrame(for: toVC)
        var toVCStartFrame = toVCEndFrame
        
        if pushing {
            toVCStartFrame.origin.y -= UIScreen.main.bounds.height
        }
        
        toVC.view.frame = toVCStartFrame
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.sendSubview(toBack: toVC.view)
        
        let snapshotView: UIView
        let snapshotViewFinalFrame: CGRect
        
        if pushing {
            snapshotView = toVC.view.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = (fromVC.view.frame).insetBy(dx: fromVC.view.frame.size.width / 2, dy: fromVC.view.frame.size.height / 2)
            snapshotViewFinalFrame = toVCEndFrame
        } else {
            snapshotView = fromVC.view.snapshotView(afterScreenUpdates: false)!
            snapshotView.frame = fromVC.view.frame
            snapshotViewFinalFrame = fromVC.view.frame.insetBy(dx: fromVC.view.frame.size.width / 2, dy: fromVC.view.frame.size.height / 2)
            fromVC.view.isHidden = true
            
        }
        
        transitionContext.containerView.addSubview(snapshotView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            snapshotView.frame = snapshotViewFinalFrame
        }) { (_) in
            let cancelled = transitionContext.transitionWasCancelled
            
            if self.pushing {
                toVC.view.frame = toVCEndFrame
            } else if cancelled {
                fromVC.view.isHidden = false
            }
            
            snapshotView.removeFromSuperview()
            transitionContext.completeTransition(!cancelled)
        }
    }
    

}
