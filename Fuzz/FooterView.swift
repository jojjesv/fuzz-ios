//
//  FooterView.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class FooterView: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var about: UIView!
    
    
    @IBOutlet weak var feedback: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("Footer", owner: self, options: nil)
        self.addSubview(view)
        
        about.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showAbout))
        )
        feedback.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showFeedback))
        )
    }
    
    @objc func showAbout(){
        print("Showing about")
    }
    
    @objc func showFeedback(){
        print("Showing feedback")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = self.frame
        view.frame.origin = CGPoint(x: 0, y: 0)
    }
}
