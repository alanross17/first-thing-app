//
//  RootViewController.swift
//  First Thing
//
//  Created by Alan Ross on 2018-10-31.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var timer = Timer()
    
    open var mainTimeFormat: DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .short
        return df
    }
    
    private lazy var swipeUpView: FTSlideInListView = {
        let view = FTSlideInListView()
        view.backgroundColor = UIColor.CustomColor.DOGWOOD_ROSE
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let panRecognier = InstantPanGestureRecognizer()
    
    private var animator = UIViewPropertyAnimator()
    
    private var isOpen = false
    private var animationProgress: CGFloat = 0
    
    private var closedTransform = CGAffineTransform.identity
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set background gradient
        let gradLayer: CAGradientLayer = CAGradientLayer()
        gradLayer.colors = [UIColor.CustomColor.DEEP_VIOLET.cgColor, UIColor.CustomColor.PURPLE_HTML.cgColor]
        gradLayer.locations = [0.0, 1.0]
        view.backgroundColor = .clear
        gradLayer.frame = view.frame
        view.layer.insertSublayer(gradLayer, at: 0)
        
        // make circle
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.clipsToBounds = true
        circleView.backgroundColor = UIColor.CustomColor.SUNSET_ORANGE
        
        // design and handle time label
        timeLabel.textColor = .white
        timeLabel.alpha = 0
        
        // set up clock to update
        timeLabel.text = mainTimeFormat.string(from: Date())
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateTime()
        })
        
        // add swipe up view
        view.addSubview(swipeUpView)
        view.bringSubviewToFront(swipeUpView)
        swipeUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        swipeUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        swipeUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 80).isActive = true
        swipeUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        
        closedTransform = CGAffineTransform(translationX: 0, y: view.bounds.height * 1.0)
        swipeUpView.transform = closedTransform
        
        panRecognier.addTarget(self, action: #selector(panned))
        //swipeUpView.addGestureRecognizer(panRecognier)
        view.addGestureRecognizer(panRecognier)
        
    }
    
    
    func animateInMainUI(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.timeLabel.alpha = 1
        }
    }
    
    // MARK: end UI lifecycle
    // ----------------
    
    
    // MARK: Clock handling
    @objc func updateTime() {
        timeLabel.text = mainTimeFormat.string(from: Date())
    }
    
    
    // MARK: Gesture handling and animation
    @objc private func panned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startAnimationIfNeeded()
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        case .changed:
            var fraction = -recognizer.translation(in: swipeUpView).y / closedTransform.ty
            if isOpen { fraction *= -1 }
            if animator.isReversed { fraction *= -1 }
            animator.fractionComplete = fraction + animationProgress
        // todo: rubberbanding
        case .ended, .cancelled:
            let yVelocity = recognizer.velocity(in: swipeUpView).y
            let shouldClose = yVelocity > 0 // todo: should use projection instead
            if yVelocity == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            if isOpen {
                if !shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if shouldClose && animator.isReversed { animator.isReversed.toggle() }
            } else {
                if shouldClose && !animator.isReversed { animator.isReversed.toggle() }
                if !shouldClose && animator.isReversed { animator.isReversed.toggle() }
            }
            let fractionRemaining = 1 - animator.fractionComplete
            let distanceRemaining = fractionRemaining * closedTransform.ty
            if distanceRemaining == 0 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            let relativeVelocity = min(abs(yVelocity) / distanceRemaining, 30)
            let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: relativeVelocity, dy: relativeVelocity))
            let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
            let durationFactor = CGFloat(preferredDuration / animator.duration)
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        default: break
        }
    }
    
    
    
    private func startAnimationIfNeeded() {
        if animator.isRunning { return }
        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            self.swipeUpView.transform = self.isOpen ? self.closedTransform : .identity
        }
        animator.addCompletion { position in
            if position == .end { self.isOpen.toggle() }
        }
        animator.startAnimation()
    }

}


class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
}
