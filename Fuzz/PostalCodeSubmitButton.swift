//
//  PostalCodeSubmitButton.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-23.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class PostalCodeSubmitButton: UIButton {
    private var hasGradient = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasGradient {
            setupGradient()
            hasGradient = true
        }
    }
    
    /// Sets up a gradient background.
    private func setupGradient(){
        let gradient = CAGradientLayer()
        gradient.frame = self.frame
        gradient.frame.origin = CGPoint()
        gradient.colors = [ UIColor(named: "Red")?.cgColor, UIColor(named: "Primary")?.cgColor ]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath().withOneSmallerRadius(rect: gradient.frame).cgPath
        
        gradient.mask = maskLayer
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIBezierPath {
    public func withOneSmallerRadius(rect: CGRect, corner: UIRectCorner = .topLeft) -> Self {
        return withOneSmallerRadius(frameSize: rect.size, corner: corner)
    }
    
    public func withOneSmallerRadius(frameSize: CGSize, corner: UIRectCorner = .topLeft, remainingCornerRadius: CGFloat = -1) -> Self {
        let cornerRadius = remainingCornerRadius < 0 ? frameSize.height / 2 : remainingCornerRadius
        let smallRadius: CGFloat = 3
        
        let radii: [CGFloat] = [
            corner == .topLeft ? smallRadius : cornerRadius,
            corner == .topRight ? smallRadius : cornerRadius,
            corner == .bottomRight ? smallRadius : cornerRadius,
            corner == .bottomLeft ? smallRadius : cornerRadius
        ]
        
        //  Top-left
        self.addArc(withCenter: CGPoint(x: radii[0], y: radii[0]), radius: radii[0], startAngle: CGFloat(Float.pi), endAngle: CGFloat(Float.pi * 1.5), clockwise: true)
        
        //  Top-right
        self.addArc(withCenter: CGPoint(x: frameSize.width - radii[1], y: radii[1]), radius: radii[1], startAngle: CGFloat(Float.pi * 1.5), endAngle: 0, clockwise: true)
        
        //  Bottom-right
        self.addArc(withCenter: CGPoint(x: frameSize.width - radii[2], y: frameSize.height - radii[2]), radius: radii[2], startAngle: 0, endAngle: CGFloat(Float.pi * 0.5), clockwise: true)
        
        //  Bottom-left
        self.addArc(withCenter: CGPoint(x: radii[3], y: frameSize.height - radii[3]), radius: radii[3], startAngle: CGFloat(Float.pi * 0.5), endAngle: CGFloat(Float.pi), clockwise: true)
        
        self.close()
        
        return self
    }
}
