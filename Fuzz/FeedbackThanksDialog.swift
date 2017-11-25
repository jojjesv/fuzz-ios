//
//  FeedbackThanksDialog.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-25.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

public class FeedbackThanksDialog: Dialog {
    @IBOutlet var view: DialogBackgroundView!
    @IBOutlet weak var dialogContent: UIView!
    
    public override init() {
        super.init()
        
        self.isCancelable = false
        Bundle.main.loadNibNamed("FeedbackThanksDialog", owner: self, options: nil)
        
        let contentMask = CAShapeLayer()
        contentMask.path = UIBezierPath().withOneSmallerRadius(frameSize: dialogContent.frame.size, corner: .topLeft, remainingCornerRadius: 24).cgPath
        dialogContent.layer.mask = contentMask
    }
    
    override func content() -> UIView! {
        return dialogContent
    }
    
    override func baseView() -> UIView! {
        return view
    }
    
    public override func show(parent: UIView) {
        super.show(parent: parent)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.dismiss()
        }
    }
}
