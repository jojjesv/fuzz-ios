//
//  Dialog.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class Dialog: NSObject {
    
    //  Retrieves the entire view.
    internal func baseView() -> UIView! {
        return nil
    }
    
    //  Retrieves the dialog content.
    internal func content() -> UIView! {
        return nil
    }
    
    //  Whether this dialog is cancelable by touching outside of the content view.
    public var isCancelable: Bool! = true
    
    var gesture: UITapGestureRecognizer?
    
    public func show(parent: UIView){
        let view: UIView! = self.baseView()
        let content: UIView! = self.content()
        
        view.frame.size = parent.frame.size
        view.frame.origin = CGPoint(x: 0.0, y: 0.0)
        
        parent.addSubview(view)
        
        if let bg = view as? DialogBackgroundView {
            bg.dialog = self
        }
        
        view.alpha = 0
        content.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
            content.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc public func dismiss(){
        let view: UIView! = self.baseView()
        let content: UIView! = self.content()
        
        view.alpha = 1
        
        UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0
            content.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: {
            (finished) in
            
            view.removeFromSuperview()
        })
    }
}

internal class DialogBackgroundView: UIView {
    public var dialog: Dialog?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        )
    }
    
    @objc private func handleTap(_ gesture: UIGestureRecognizer){
        guard (dialog?.isCancelable)! else { return }
        
        if subviews[0].frame.contains(gesture.location(in: self)) {
            //  Touched subview
            return
        }
        
        dialog?.dismiss()
    }
}

extension UIView {
    public func absoluteSuperview() -> UIView? {
        var nextParent: UIView? = superview
        
        while true {
            if nextParent?.superview == nil {
                return nextParent
            }
            nextParent = nextParent?.superview
        }
    }
}
