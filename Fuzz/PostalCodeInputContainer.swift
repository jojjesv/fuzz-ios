//
//  PostalCodeInputContainer.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-23.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class PostalCodeInputContainer: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupLayer()
    }
    
    /// Sets up the layer.
    private func setupLayer(){
        let shape = CAShapeLayer()
        shape.path = UIBezierPath().withOneSmallerRadius(rect: layer.frame).cgPath
        shape.fillColor = UIColor.white.cgColor
        shape.lineWidth = 2
        shape.strokeColor = UIColor(named: "Secondary")?.cgColor
        
        self.layer.insertSublayer(shape, at: 0)
    }

}

public class PostalCodeInput: MaxLengthTextField {
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset: CGFloat = 24
        return CGRect(x: bounds.minX + inset, y: bounds.minY, width: bounds.width - inset, height: bounds.height)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
