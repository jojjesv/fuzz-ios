//
//  TextDialog.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-25.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

public class TextDialog: Dialog {
    @IBOutlet var view: DialogBackgroundView!
    @IBOutlet weak var dialogContent: UIView!
    
    @IBOutlet weak var headerView: UILabel!
    @IBOutlet weak var messageView: UILabel!
    
    public var header: String? {
        set {
            headerView.text = newValue
        }
        
        get {
            return headerView.text
        }
    }
    
    public var message: String? {
        set {
            messageView.text = newValue
        }
        
        get {
            return messageView.text
        }
    }
    
    public override init() {
        super.init()
        
        Bundle.main.loadNibNamed("TextDialog", owner: self, options: nil)
    }
    
    override func baseView() -> UIView! {
        return view
    }
    
    override func content() -> UIView! {
        return dialogContent
    }
}
