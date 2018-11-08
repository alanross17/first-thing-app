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
        
        timeLabel.text = mainTimeFormat.string(from: Date())
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updateTime()
        })
        
    }
    
    func animateInMainUI(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.timeLabel.alpha = 1
        }
    }
    
    @objc func updateTime() {
        timeLabel.text = mainTimeFormat.string(from: Date())
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
