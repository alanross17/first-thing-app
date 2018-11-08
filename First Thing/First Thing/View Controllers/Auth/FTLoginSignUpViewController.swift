//
//  FTLoginSignUpViewController.swift
//  First Thing
//
//  Created by Alan Ross on 2018-10-19.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

class FTLoginSignUpViewController: UIViewController, ARSignUpFromViewDelegate {
    
    @IBOutlet weak var signupFormView: ARSignUpFormView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let transition = PopAnimatior()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        signupFormView.isSignUpMode = true
        signupFormView.delegate = self
        
        signupFormView.confirmButton.custBackgroundColour = UIColor.CustomColor.SUNSET_ORANGE
        
        
        // set background gradient
        let gradLayer: CAGradientLayer = CAGradientLayer()
        gradLayer.colors = [UIColor.CustomColor.DEEP_VIOLET.cgColor, UIColor.CustomColor.PURPLE_HTML.cgColor]
        gradLayer.locations = [0.0, 1.0]
        view.backgroundColor = .clear
        gradLayer.frame = view.frame
        view.layer.insertSublayer(gradLayer, at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signupFormView.confirmButton.isHidden = false
    }
    
    var timesPressed = 0
    
    func didRequestAuth() {
        if signupFormView.confirmButton.status == .showingIndicator {
            presentMainApp()
        }
    }
    
    func presentMainApp () {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destView: RootViewController = mainStoryboard.instantiateInitialViewController() as! RootViewController
        destView.transitioningDelegate = self
        present(destView, animated: true, completion: nil)
    }
}

extension FTLoginSignUpViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        transition.originFrame = signupFormView.confirmButton.getBackgroundViewFrameRelavtiveTo(view: view)
        transition.intermediateColor = signupFormView.confirmButton.backgroundColor!

        transition.presenting = true
        signupFormView.confirmButton.isHidden = true
        
        return transition
    }
}
