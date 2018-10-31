//
//  PopAnimatior.swift
//  Commit.To
//
//  Created by Alan Ross on 2018-10-27.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

class PopAnimatior: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    
    var intermediateColor: UIColor = .lightGray
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toVC: ViewController = transitionContext.viewController(forKey: .to) as! ViewController
        
        let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)!

        let finalFrame = transitionContext.finalFrame(for: toVC)

        snapshot.frame = originFrame
        snapshot.layer.cornerRadius = originFrame.height / 2
        snapshot.clipsToBounds = true

        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        toVC.view.isHidden = true
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                //snapshot.layer.cornerRadius = containerView.frame.width / 2
                let newOrigin = CGPoint(x: 0, y: self.originFrame.midY - (containerView.frame.width / 2))
                snapshot.frame = CGRect(x: newOrigin.x, y: newOrigin.y, width: containerView.frame.width, height: containerView.frame.width)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 2/3, animations: {
                snapshot.frame = finalFrame
                snapshot.layer.cornerRadius = 0
            })
            
        }) { _ in
            toVC.view.isHidden = false
            //toVC.fadeInView()
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
            
        }

//        UIView.animate(withDuration: duration, animations: {
//            snapshot.frame = finalFrame
//            snapshot.layer.cornerRadius = 0
//        }, completion: { _ in
//            toVC.view.isHidden = false
//            snapshot.removeFromSuperview()
//            transitionContext.completeTransition(true)
//        })

    }

}
