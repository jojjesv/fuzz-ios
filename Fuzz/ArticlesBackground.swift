//
//  ArticlesBackground.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-22.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class ArticlesBackground: UIView {
    
    private var layers: [CAShapeLayer]!
    private var gradientColors: [CGColor] = [UIColor.white.cgColor, UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0).cgColor]
    
    private var _offset: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLayers()
    }
    
    private func setupLayers(){
        let images = [ #imageLiteral(resourceName: "Candy"), #imageLiteral(resourceName: "CandyCane"), #imageLiteral(resourceName: "CandySmall") ]
        
        func create(image: UIImage, x: CGFloat, y: CGFloat, rotationDeg: CGFloat) -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.contents = image.cgImage
            layer.frame = CGRect(x: 0, y: 0, width: CGFloat((image.size.width)), height: CGFloat((image.size.height)))
            layer.position = CGPoint(x: x, y: y)
            //layer.transform = CATransform3DMakeRotation(rotationDeg.toRad(), 0, 0, 1)
            
            self.layer.addSublayer(layer)
            
            return layer
        }
        
        self.layers = [
            create(image: images[0], x: 0, y: 0, rotationDeg: 15),
            create(image: images[1], x: 80, y: 80, rotationDeg: -5)
        ]
    }
    
    //  Offsets background layers.
    public func offset(by: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for l in self.layers {
            l.position.y += by
            if l.position.y < -l.frame.height {
                //  At top
                l.position.y = self.frame.height
            } else if l.position.y > self.frame.height {
                // At bottom
                l.position.y = -l.frame.height
            }
        }
        
        CATransaction.commit()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        var locations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: locations)
        
        let center = rect.center()
        context?.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: center, endRadius: rect.width / 2, options: .drawsBeforeStartLocation)
    }

}
