//
//  FeedbackDialog.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class FeedbackDialog: Dialog {
    @IBOutlet var view: UIView!
    @IBOutlet weak var dialogContent: UIView!
    @IBOutlet weak var input: FeedbackInput!
    @IBOutlet weak var submitButton: FeedbackSubmitButton!
    private var viewParent: UIView?

    public override init() {
        super.init()
        
        Bundle.main.loadNibNamed("FeedbackDialog", owner: self, options: nil)
        
        input.submitCallback = self.submit
        submitButton.submitCallback = self.submit
    }
    
    override func baseView() -> UIView! {
        return view
    }
    
    override func content() -> UIView! {
        return dialogContent
    }
    
    public override func show(parent: UIView) {
        super.show(parent: parent)
        self.viewParent = parent
    }
    
    private func submit(){
        let feedback = input.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        var post = "platform=ios"
        
        if var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = version.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            post += "&app_version=\(version)"
        }
        
        post += "&message=\(feedback)"
        
        Backend.request(getParams: "action=send_feedback", postBody: post) { (data) in
            self.dismiss()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                let thanksDialog = FeedbackThanksDialog()
                thanksDialog.show(parent: self.viewParent!)
            })
        }
    }
}

internal class FeedbackInput: MaxLengthTextField {
    public var submitCallback: (() -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.submitCallback!()
        return true
    }
}

//  As actions didn't work in dialog class.
internal class FeedbackSubmitButton: UIButton {
    public var submitCallback: (() -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.submit))
        )
    }
    
    @objc func submit(){
        self.submitCallback!()
    }
}
