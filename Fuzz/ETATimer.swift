//
//  ETATimer.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-17.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class ETATimer: UIView, ETADelegate {
    public var label: UILabel?
    private var displayLink: CADisplayLink?
    private var percentage: CGFloat = 0.0
    private var etaSeconds: Double?
    private var oldElapsedSeconds: Double = -1
    private var displayLinkStartTimestamp: CFTimeInterval?
    public var reachedZero: (() -> Void)!
    private var _finished = false
    public var finished: Bool {
        get {
            return _finished
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func etaChanged(etaMins: Int, deliverer: String) {
        self.etaSeconds = Double(etaMins * 60)
        self.start()
    }
    
    public func start(){
        //  A display link is synchronized with screen refresh
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.add(to: .main, forMode: .defaultRunLoopMode)
    }
    
    @objc func update(){
        let timestamp = (displayLink?.timestamp)!
        if displayLinkStartTimestamp == nil {
            displayLinkStartTimestamp = timestamp
        }
        let elapsedSeconds = timestamp - displayLinkStartTimestamp!
        let floorElapsedSeconds = floor(elapsedSeconds)
        
        percentage = CGFloat(min(elapsedSeconds / etaSeconds!, 1))
        setNeedsDisplay()
        
        if floorElapsedSeconds != floor(oldElapsedSeconds) {
            //  Second tick; update timer label
            var timeLeft = self.etaSeconds! - floorElapsedSeconds
            let minutesLeft = Int(floor(timeLeft / 60))
            let secondsLeft = Int(timeLeft.truncatingRemainder(dividingBy: 60))
            
            if (minutesLeft == 0 && secondsLeft == 0) {
                //  Reached zero
                _finished = true
                self.reachedZero()
                displayLink?.remove(from: .main, forMode: .defaultRunLoopMode)
                return
            }
            
            let minutesString = (minutesLeft < 10 ? "0" : "") + "\(minutesLeft)"
            let secondsString = (secondsLeft < 10 ? "0" : "") + "\(secondsLeft)"
            
            label?.text = "\(minutesString):\(secondsString)"
            oldElapsedSeconds = elapsedSeconds
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        let center = rect.center()
        let endAngle = CGFloat(.pi * 2 * percentage - .pi * 0.5)
        let radius = rect.width / 2
        
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: 0))
        path.addArc(withCenter: center, radius: radius, startAngle: CGFloat(Float.pi * 1.5), endAngle: endAngle, clockwise: true)
        path.close()
        
        UIColor.orange.setFill()
        path.fill()
    }

}

extension CGRect {
    public func center() -> CGPoint {
        return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}

extension FloatingPoint {
    public func toRad() -> Self {
        return  self * .pi / 180
    }
}
