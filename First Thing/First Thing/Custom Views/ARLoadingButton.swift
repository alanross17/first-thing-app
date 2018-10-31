//
//  ARLoadingButton.swift
//  Commit.To
//
//  Created by Alan Ross on 2018-10-25.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

// -----------------
// ENUMS AND STRUCTS
// -----------------

public struct ARLoadingButtonLoadingStatus: OptionSet {
    public let rawValue: UInt
    public static let normal = ARLoadingButtonLoadingStatus(rawValue: 1 << 0)
    public static let showingIndicator = ARLoadingButtonLoadingStatus(rawValue: 1 << 1)
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

// ---------------------
// END ENUMS AND STRUCTS
// ---------------------

@IBDesignable
open class ARLoadingButton: UIButton {

    // ------------
    // Initializers
    // ------------
    
    #if !TARGET_INTERFACE_BUILDER
    override public init(frame: CGRect) { // For using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) { // For using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    #endif
    
    private func commonInit() {
        backgroundColor = .lightGray
        
    }
    
    // ----------------
    // End Initializers
    // ----------------
    
    
    // ---------
    // Variables
    // ---------
    
    /// current status of control (can be normal, or loading)
    open var status: ARLoadingButtonLoadingStatus = .normal {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// current color of control base on it's status
    @IBInspectable open var custBackgroundColour: UIColor = .clear {
        didSet {
            if oldValue != custBackgroundColour {
                setNeedsDisplay()
            }
        }
    }
    
    /// animation duration for changing states
    open var animationDuration: Double = 0.3
    
    /// radius of corners in normal state
    @IBInspectable open var cornerRadius: CGFloat = 5 {
        didSet {
            if oldValue != cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    /// current width of the button
    private var buttonBGWidth: CGFloat {
        let normalWidth = frame.width
        let indicatorWidth = frame.height
        
        switch status {
        case .normal:
            return normalWidth
        case .showingIndicator:
            return indicatorWidth
        default:
            return normalWidth
        }
    }
    
    private var internalCornerRadius: CGFloat {
        let loadingRadius = frame.height / 2
        
        switch status {
        case .showingIndicator:
            return loadingRadius
        default:
            return cornerRadius
        }
    }
    
    private var backgroundXPosition: CGFloat {
        let indicatorPosition = (frame.width / 2) - (frame.height / 2)
        
        switch status {
        case .showingIndicator:
            return indicatorPosition
        default:
            return 0
        }
    }
    
    private var titleAlpha: CGFloat {
        switch status {
        case .showingIndicator:
            return 0
        default:
            return 1
        }
    }
    
    
    // -----------------
    // LAZY LOADINGS
    // -----------------
    
    open lazy var customBackgroundView: UIView = {
       let bgView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        bgView.layer.cornerRadius = internalCornerRadius
        bgView.backgroundColor = custBackgroundColour
        bgView.isUserInteractionEnabled = false
        
        return bgView
    }()
    
    
    // --------------------
    // METHOD OVERRIDES
    // --------------------
    override open var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            //custBackgroundColour = backgroundColor!
            super.backgroundColor = .clear
            setNeedsDisplay()
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
    
        addSubview(customBackgroundView)
        sendSubviewToBack(customBackgroundView)
        
        animateBackgroundToCircle()
    }
    
    // -------------
    // METHODS
    // -------------
    
    private func animateBackgroundToCircle() {
        
        layoutIfNeeded()
        UIView.animate(withDuration: animationDuration) {
            self.customBackgroundView.layer.cornerRadius = self.internalCornerRadius
            self.customBackgroundView.frame = CGRect(x: self.backgroundXPosition, y: 0, width: self.buttonBGWidth, height: self.frame.height)
            self.titleLabel?.alpha = self.titleAlpha
            self.layoutIfNeeded()
        }
    }
    
    /// Get the position of button loading circle relative to passed view
    public func getBackgroundViewFrameRelavtiveTo(view: UIView) -> CGRect {
        let newFrame = convert(customBackgroundView.frame, to: view)
        return newFrame
    }
}
