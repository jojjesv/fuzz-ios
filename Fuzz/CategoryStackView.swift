//
//  CategoryStackView.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CategoryStackView: UIStackView {
    private var _backgroundColor: UIColor?
    
    //  https://stackoverflow.com/questions/34868344/how-to-change-the-background-color-of-uistackview
    
    override public var backgroundColor: UIColor? {
        set {
            _backgroundColor = newValue
            setNeedsLayout()
        }
        get {
            return _backgroundColor
        }
    }
    
    private lazy var backgroundLayer = {
        () -> CAShapeLayer in
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.path = UIBezierPath(rect: self.bounds).cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
    }
}
