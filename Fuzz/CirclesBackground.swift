//
//  CirclesBackground.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CirclesBackground: UIView {
    private var hasLayers = false
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupLayers(){
        guard !hasLayers else {
            return
        }
        
        hasLayers = true
        
        func animation(from: [CGFloat], to: [CGFloat], duration: CGFloat) -> CABasicAnimation {
            let anim = CABasicAnimation(keyPath: "position")
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            anim.fromValue = from
            anim.toValue = to
            anim.duration = CFTimeInterval(duration)
            anim.repeatCount = .infinity
            anim.autoreverses = true
            
            return anim
        }
        
        let circle1 = CALayer()
        
        let circle1Size: CGFloat = 450.0
        circle1.backgroundColor = UIColor(named: "LightRed")?.cgColor
        circle1.frame = CGRect(x: 0.0, y: 0.0, width: circle1Size, height: circle1Size)
        circle1.cornerRadius = circle1Size / 2.0
        
        let circle2 = CALayer()
        let circle2Size: CGFloat = 180.0
        circle2.backgroundColor = UIColor(named: "LightestBlue")?.cgColor
        circle2.frame = CGRect(x: self.frame.width - circle2Size, y: self.frame.height - circle2Size, width: circle2Size, height: circle2Size)
        circle2.cornerRadius = circle2Size / 2.0
        
        let key = "position"
        circle1.add(animation(from: [circle1.frame.origin.x + 0.0, circle1.frame.origin.y + 0.0], to: [circle1.frame.origin.x + 100.0, circle1.frame.origin.y + 250.0], duration: 45), forKey: key)
        circle2.add(animation(from: [circle2.frame.origin.x, circle2.frame.origin.y], to: [circle2.frame.origin.x - 100.0, circle2.frame.origin.y - 250.0], duration: 60), forKey: key)
        
        self.layer.insertSublayer(circle1, at: 0)
        self.layer.insertSublayer(circle2, at: 1)
    }
    
    public override func layoutSubviews() {
        self.setupLayers()
    }
}

class CustomTimingFunction: CAMediaTimingFunction {
    
}
