//
//  ActionBar.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ActionBar: UIView {
    
    
    
}


public class ActionBarButton: UIButton {
    private lazy var backgroundCircle: CALayer = {
        let layer = CALayer()
        layer.frame.size = self.frame.size
        layer.cornerRadius = layer.frame.height / 2
        layer.backgroundColor = UIColor.red.cgColor
        layer.isOpaque = false
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCircle.frame.size = self.frame.size
    }
    
    public func changeCircleLayerVisibility(visible: Bool){
        let layer = backgroundCircle
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = visible ? 0.6 : 1.0
        scale.toValue = visible ? 1.0 : 0.6
        scale.duration = 0.35
        
        layer.opacity = visible ? 1.0 : 0.0
        
        let animation = CAAnimationGroup()
        animation.animations = [scale]
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
    }
}
