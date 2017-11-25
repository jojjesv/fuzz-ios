//
//  ShoppingCartField.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-25.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class ShoppingCartField: MaxLengthTextField {
    public var nextField: ShoppingCartField?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nextField == nil {
            //  Is last field
            textField.resignFirstResponder()
        } else {
            nextField?.becomeFirstResponder()
        }
        return true
    }
    
    private var hasSetupNumberPadReturn: Bool! = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (!hasSetupNumberPadReturn && keyboardType == .numberPad) {
            //  https://gist.github.com/jplazcano87/8b5d3bc89c3578e45c3e
            
            let done = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            done.barStyle = .default
            
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let isNext = returnKeyType == .next
            let doneBtn = UIBarButtonItem(title: isNext ? "Nästa" : "Klar", style: .plain, target: self, action: #selector(self.doneTapped))
        
            done.items = [ flex, doneBtn ]
            done.sizeToFit()
            
            self.inputAccessoryView = done
            
        }
        
        hasSetupNumberPadReturn = true
    }
    
    @objc private func doneTapped(){
        textFieldShouldReturn(self)
    }
}
