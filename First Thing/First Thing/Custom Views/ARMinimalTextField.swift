//
//  ARMinimalTextField.swift
//  Commit.To
//
//  Created by Alan Ross on 2018-10-23.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

// -----------------
// ENUMS AND STRUCTS
// -----------------

/// FromTextField statuses
public struct ARMinimalTextFieldContentStatus: OptionSet {
    public let rawValue: UInt
    public static let filled = ARMinimalTextFieldContentStatus(rawValue: 1 << 0)
    public static let empty = ARMinimalTextFieldContentStatus(rawValue: 1 << 1)
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}


public enum ARMinimalTextFieldErrors: Error {
    case error(message: String?)
    case warning(message: String?)
}

/// FromTextField statuses
public struct ARMinimalTextFieldFocusStatus: OptionSet {
    public let rawValue: UInt
    public static let active = ARMinimalTextFieldFocusStatus(rawValue: 1 << 0)
    public static let inactive = ARMinimalTextFieldFocusStatus(rawValue: 1 << 1)
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

/// FromTextField statuses
public struct ARMinimalTextFieldStatus: OptionSet {
    public let rawValue: UInt
    public static let error = ARMinimalTextFieldStatus(rawValue: 1 << 1)
    public static let normal = ARMinimalTextFieldStatus(rawValue: 1 << 2)
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

/// when call validation
public struct ARMinimalTextFieldValidateType: OptionSet {
    public let rawValue: UInt
    /// after text did change
    public static let onFly = ARMinimalTextFieldValidateType(rawValue: 1 << 0)
    /// after textfield resign first responder
    public static let afterEdit = ARMinimalTextFieldValidateType(rawValue: 1 << 1)
    /// whenever validate() gets called
    public static let onCommit = ARMinimalTextFieldValidateType(rawValue: 1 << 2)
    /// allways validate, when activated, when changed, when deactivated
    public static let always = ARMinimalTextFieldValidateType(rawValue: 1 << 2)
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

// --------------------
// End Struct/ENUM Defs
// --------------------

@IBDesignable
open class ARMinimalTextField: UITextField {
    
    private var isLayoutCalled = false
    
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
        borderStyle = .none
        placeholder = super.placeholder
        tintColor = super.tintColor
        super.placeholder = nil
        addTarget(self, action: #selector(self.formTextFieldDidBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(self.formTextFieldDidEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(self.formTextFieldValueChanged), for: [.editingChanged, .valueChanged])
        NSLayoutConstraint.activate(neededConstraint)
        text = super.text
    }
    
    // ----------------
    // End Initializers
    // ----------------
    

    // ---------
    // Variables
    // ---------
    
    /// current status of control (can be normal, warning, error)
    open var status: ARMinimalTextFieldStatus = .normal {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// current focus status of textfield (can be active, inactive)
    open var focusStatus: ARMinimalTextFieldFocusStatus = .inactive {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// current content status of textfield (can be empty, filled)
    open var contentStatus: ARMinimalTextFieldContentStatus = .empty {
        didSet {
            guard contentStatus != oldValue else {
                return
            }
            layoutIfNeeded()
            setNeedsDisplay()
        }
    }
    
    /// validation time type
    open var validationType: ARMinimalTextFieldValidateType = .afterEdit
    
    /// animation duration for changing states
    open var animationDuration: Double = 0.3
    
    /// constraints that will be activated upon initilization
    private var neededConstraint = [NSLayoutConstraint]()
    
    /// editing text height
    private var lineHeight: CGFloat {
        return font?.pointSize ?? 0
    }
    
//    /// placeholder text height
//    private var placeholderHeight: CGFloat {
//        return placeholderFont?.pointSize ?? lineHeight
//    }
    
    /// current color of control base on it's status
    private var lineColor: UIColor {
        switch (status, contentStatus, focusStatus) {
        case (.normal, _, .inactive):
            return inactiveLineColor
        case (.normal, _, .active):
            return activeLineColor
        case ((.error,_,_)):
            return errorLineColor
        default:
            return inactivePlaceholderTextColor
        }
    }
    /// current width of control line base on it's status
    private var lineWidth: CGFloat {
        switch (status, contentStatus, focusStatus) {
        case (.normal, _, .inactive):
            return inactiveLineWidth
        case (.normal, _, .active):
            return activeLineWidth
        case ((.error,_,_)):
            return errorLineWidth
        default:
            return inactiveLineWidth
        }
    }

    
    
    // --------------
    // IBInspectables
    // --------------
    //==================
    // MARK: Active State
    //==================
    /// line width when textfield is focused
    @IBInspectable open var activeLineWidth: CGFloat = 1 {
        didSet {
            if oldValue != activeLineWidth {
                setNeedsDisplay()
            }
        }
    }
    /// placeholder color when textfield is focused
    @IBInspectable open var activePlaceholderTextColor: UIColor = .lightGray {
        didSet {
            if oldValue != activePlaceholderTextColor {
                setNeedsDisplay()
            }
        }
    }
    /// line color when textfield is focused
    @IBInspectable open var activeLineColor: UIColor = .darkText {
        didSet {
            if oldValue != activeLineColor {
                setNeedsDisplay()
            }
        }
    }
    
    //====================
    // MARK: Inactive Status
    //====================
    /// line width when textfield is not focused
    @IBInspectable open var inactiveLineWidth: CGFloat = 1 {
        didSet {
            if oldValue != inactiveLineWidth {
                setNeedsDisplay()
            }
        }
    }
    /// placeholder color when textfield is not focused
    @IBInspectable open var inactivePlaceholderTextColor: UIColor = .darkText {
        didSet {
            if oldValue != inactivePlaceholderTextColor {
                setNeedsDisplay()
            }
        }
    }
    /// line color when textfield is not focused
    @IBInspectable open var inactiveLineColor: UIColor = .lightGray {
        didSet {
            if oldValue != inactiveLineColor {
                setNeedsDisplay()
            }
        }
    }
    
    
    //==================
    // MARK: Error Status
    //==================
    /// line width when textfield have error
    @IBInspectable open var errorLineWidth: CGFloat = 1 {
        didSet {
            if oldValue != errorLineWidth {
                setNeedsDisplay()
            }
        }
    }
    /// placeholder color when textfield have error
    @IBInspectable open var errorPlaceholderColor: UIColor = UIColor.red {
        didSet {
            if oldValue != errorPlaceholderColor {
                setNeedsDisplay()
            }
        }
    }
    /// error label color when textfield have warning
    @IBInspectable open var errorTextColor: UIColor = UIColor.yellow {
        didSet {
            if oldValue != errorTextColor {
                setNeedsDisplay()
            }
        }
    }
    /// line color when textfield have error
    @IBInspectable open var errorLineColor: UIColor = UIColor.red {
        didSet {
            if oldValue != errorLineColor {
//                errorLabel.textColor = errorLineColor
                setNeedsDisplay()
            }
        }
    }
    
    
    // icon image
    @IBInspectable open var leftIconImage: UIImage = UIImage() {
        didSet {
            if oldValue != leftIconImage {
                setNeedsDisplay()
            }
        }
    }
    

    // -----------------
    // LAZY LOADINGS
    // -----------------
    
    /// set height of control
    private lazy var heightConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self,
                                  attribute: .height,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: 0)
    }()
    
    /// layer which line will be drawn on
    open lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer(layer: self.layer)
        layer.lineCap = CAShapeLayerLineCap.round
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = lineWidth
        return layer
    }()
    
    open lazy var leftIconView: UIView = {
        let iconView = UIImageView(frame: CGRect(x: /*10*/0, y: 7, width: 25, height: 25))
        iconView.image = leftIconImage.withRenderingMode(.alwaysTemplate)
        let iconContainerView: UIView = UIView(frame:CGRect(x: /*20*/0, y: 0, width: frame.height, height: frame.height))
        iconContainerView.addSubview(iconView)
        leftViewMode = .always
        return iconContainerView
    }()
    
    
    // --------------------
    // METHOD OVERRIDES
    // --------------------
    override open var text: String? {
        get {
            return super.text
        }
        set {
            super.text = newValue
            decideContentStatus(fromText: text)
            setNeedsDisplay()
        }
    }
    
    override open var placeholder: String? {
        get {
            return super.placeholder
        }
        set {
            super.placeholder = newValue
            attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor: lineColor])
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if lineLayer.superlayer == nil {
            layer.addSublayer(lineLayer)
        }
        
        leftView = leftIconView
        
        aniamteLineColor()
        animateIconColor()
        animatePlaceHolderColor()
        lineLayer.lineWidth = lineWidth
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.path = createLinePath().cgPath
//        changeSementics()
        isLayoutCalled = true
    }
    
    override open func becomeFirstResponder() -> Bool {
        focusStatus = .active
        return super.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        focusStatus = .inactive
        return super.resignFirstResponder()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    // -------------
    // METHODS
    // -------------
    
    /// decide if text is empty or not
    private func decideContentStatus(fromText text: String?) {
        if (text ?? "").isEmpty {
            contentStatus = .empty
        } else {
            contentStatus = .filled
        }
    }

    
    /// animate linecolor
    private func aniamteLineColor() {
        let animation = CABasicAnimation(keyPath: "strokeColor")
        animation.duration = animationDuration
        animation.isRemovedOnCompletion = true
        lineLayer.add(animation, forKey: "strokeColorChange")
        lineLayer.strokeColor = lineColor.cgColor
    }
    
    /// animate icon colour
    private func animateIconColor() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationDelegate(self)
        
        leftIconView.tintColor = lineColor
        
        UIView.commitAnimations()
    }
    
    private func animatePlaceHolderColor() {
        UIView.animate(withDuration: animationDuration) {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: self.lineColor])
        }
    }
    
    /// create line bezier path
    private func createLinePath() -> UIBezierPath {
        let path = UIBezierPath()
        let heightLine = self.frame.height//(font?.pointSize ?? 0) + 8
        //let placeholderLine = textHeightForFont(font: placeholderFont) + 4
        let padding = heightLine// + placeholderLine * 0.8
        path.move(to: CGPoint(x: 0, y: padding))
        path.addLine(to: CGPoint(x: bounds.maxX, y: padding))
        //path.lineCapStyle = .square
        path.close()
        return path
    }
    
    public func validate() throws {
        do {
            try (delegate as? ARMinimalTextFieldDelegate)?
                .textFieldValidate(minimalTextField: self)
            status = .normal
        } catch ARMinimalTextFieldErrors.error(let message) {
            status = .error
//            errorLabel.text = message
            throw ARMinimalTextFieldErrors.warning(message: message)
        } catch {
            throw error
        }
        if isFirstResponder {
            focusStatus = .active
        } else {
            focusStatus = .inactive
        }
    }

}

// ---------
// Selectors
// ---------

@objc extension ARMinimalTextField {
    
    /// textfield become first responder
    private func formTextFieldDidBeginEditing() {
        layoutIfNeeded()
        if validationType.contains(.always) {
            try? validate()
        } else {
            focusStatus = .active
        }
    }
    
    /// textfield resigned first responder
    private func formTextFieldDidEndEditing() {
        layoutIfNeeded()
        if validationType.contains(.afterEdit) ||
            validationType.contains(.onFly) ||
            validationType.contains(.always) {
            try? validate()
        } else {
            focusStatus = .inactive
        }
    }
    
    /// textfield value changed
    private func formTextFieldValueChanged() {
        (delegate as? ARMinimalTextFieldDelegate)?
            .textFieldTextChanged(minimalTextField: self)
        decideContentStatus(fromText: text)
        guard let text = text, !text.isEmpty else {
            if validationType.contains(.onFly) ||
                validationType.contains(.always) {
                try? validate()
            }
            return
        }
        if validationType.contains(.onFly) ||
            validationType.contains(.always) {
            try? validate()
        }
    }
}

public protocol ARMinimalTextFieldDelegate : UITextFieldDelegate {
    /// validate textfield and set status
    func textFieldValidate(minimalTextField: ARMinimalTextField) throws
    /// called when textfield value changed
    func textFieldTextChanged(minimalTextField: ARMinimalTextField)
}

public extension ARMinimalTextFieldDelegate {
    func textFieldValidate(minimalTextField: ARMinimalTextField) throws { }
    func textFieldTextChanged(minimalTextField: ARMinimalTextField) { }
}
