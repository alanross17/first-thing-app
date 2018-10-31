//
//  ARSignUpFormView.swift
//  First Thing
//
//  Created by Alan Ross on 2018-10-19.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

protocol ARSignUpFromViewDelegate: class {
    func didRequestAuth()
}

class ARSignUpFormView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    weak var delegate: ARSignUpFromViewDelegate?
    
    @IBOutlet weak var nameField: ARMinimalTextField!
    @IBOutlet weak var passwordField: ARMinimalTextField!
    @IBOutlet weak var emailField: ARMinimalTextField!
    @IBOutlet weak var confirmButton: ARLoadingButton!
    @IBOutlet weak var switchModeButton: UIButton!
    
    override init(frame: CGRect) { // For using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // For using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // init stuff here...
        Bundle.main.loadNibNamed("ARSignUpFormView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        nameField.placeholder = "Full Name"
        emailField.placeholder = "Email Address"
        passwordField.placeholder = "Password"
        
        nameField.leftIconImage = UIImage(named: "user_icon")!
        emailField.leftIconImage = UIImage(named: "mail_icon")!
        passwordField.leftIconImage = UIImage(named: "pass_icon")!
        
        confirmButton.layer.cornerRadius = 5
        confirmButton.clipsToBounds = true
        
        isSignUpMode = true
    }
    
    open var isSignUpMode : Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.nameField.isHidden = !self.isSignUpMode
                self.nameField.alpha = self.isSignUpMode ? 1 : 0
            }
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        delegate?.didRequestAuth()
        confirmButton.status = .showingIndicator
    }
    
    @IBAction func switchModePressed(_ sender: Any) {
        isSignUpMode = !isSignUpMode
        
        self.endEditing(true)
        
        if isSignUpMode {
            switchModeButton.setTitle("Already have an account? Login!", for: .normal)
            confirmButton.setTitle("Sign Up", for: .normal)
        } else {
            switchModeButton.setTitle("New here? Welcome! Create an account!", for: .normal)
            confirmButton.setTitle("Login", for: .normal)
        }
    }
    
}
