//
//  PopAnimatior.swift
//  Commit.To
//
//  Created by Alan Ross on 2018-10-27.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

class PopAnimatior: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.75
    var presenting = true
    var originFrame = CGRect.zero
    
    var intermediateColor: UIColor = .lightGray
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toVC: RootViewController = transitionContext.viewController(forKey: .to) as! RootViewController
        let fromVC: FTLoginSignUpViewController = transitionContext.viewController(forKey: .from) as! FTLoginSignUpViewController
        
        let endFrame = toVC.circleView.frame
        
        let originCenter = CGPoint(x: originFrame.origin.x + (originFrame.width/2),
                                   y: originFrame.origin.y + (originFrame.height/2))
        let circlePath = UIBezierPath(arcCenter: originCenter,
                                      radius: originFrame.height/2,
                                      startAngle: 0,
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.CustomColor.SUNSET_ORANGE.cgColor
        shapeLayer.lineWidth = 0
        
        containerView.layer.addSublayer(shapeLayer)

        containerView.addSubview(toVC.view)

        toVC.view.isHidden = true
        
        // CABasicAnimations used for graphics and shapes
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        
        let finalCenter = CGPoint(x: endFrame.origin.x + (endFrame.width/2),
                                  y: endFrame.origin.y + (endFrame.height/2))
        
        animation.toValue = UIBezierPath(arcCenter: finalCenter,
                                         radius: endFrame.height/2,
                                         startAngle: 0,
                                         endAngle: CGFloat(Double.pi * 2),
                                         clockwise: true).cgPath
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fillMode = .forwards
        shapeLayer.add(animation, forKey: nil)
        
        // UIView Animations used for basic view properties
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                fromVC.titleLabel.alpha = 0
            })
            
            // TODO: Move these animations to a method in AR Sign Up View!
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/4, animations: {
                fromVC.signupFormView.nameField.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/4, relativeDuration: 1/4, animations: {
                fromVC.signupFormView.emailField.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/4, relativeDuration: 1/4, animations: {
                fromVC.signupFormView.passwordField.alpha = 0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 3/4, relativeDuration: 1/4, animations: {
                fromVC.signupFormView.confirmButton.alpha = 0
                fromVC.signupFormView.switchModeButton.alpha = 0
            })
            
        }) { _ in
            toVC.view.isHidden = false
            
            toVC.circleView.isHidden = false
            toVC.view.layer.isHidden = false
            
            toVC.animateInMainUI(duration: 0.2)
            
            transitionContext.completeTransition(true)
            
        }

    }

}
