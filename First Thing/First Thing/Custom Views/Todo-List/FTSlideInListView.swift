//
//  FTSlideInListView.swift
//  First Thing
//
//  Created by Alan Ross on 2018-11-01.
//  Copyright © 2018 Alan Ross. All rights reserved.
//

import UIKit

class FTSlideInListView: UIView {

    @IBOutlet var contentView: UIView!
    
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
        Bundle.main.loadNibNamed("FTSlideInListView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        // set background gradient
        let gradLayer: CAGradientLayer = CAGradientLayer()
        gradLayer.colors = [UIColor.CustomColor.DOGWOOD_ROSE.cgColor, UIColor.CustomColor.PLUMP_PURPLE.cgColor]
        gradLayer.locations = [0.0, 1.0]
        contentView.backgroundColor = .clear
        gradLayer.frame = contentView.frame
        contentView.layer.insertSublayer(gradLayer, at: 0)
    }

}
