//
//  AboutAppDialog.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class AboutAppDialog: Dialog {
    
    private static var _data: [String: String]?
    public static var data: [String: Any]? {
        set {
            if _data == nil {
                _data = [String: String]()
            }
            
            func copy(_ string: String) {
                _data![string] = newValue![string] as? String
            }
        
            copy("company_address")
            copy("company_name")
            copy("company_email")
            copy("company_phone_num")
        }
        get {
            return _data
        }
    }
    
    @IBOutlet var view: DialogBackgroundView!
    @IBOutlet weak var dialogContent: UIView!
    
    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    public override init() {
        super.init()
        
        Bundle.main.loadNibNamed("AboutAppDialog", owner: self, options: nil)
        
        let data = AboutAppDialog._data!
        nameHeader.text = data["company_name"]
        addressLabel.text = data["company_address"]
        phoneLabel.text = data["company_phone_num"]
        mailLabel.text = data["company_email"]
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        } else {
            versionLabel.text = nil
        }
    }
    
    override func baseView() -> UIView! {
        return view
    }
    
    override func content() -> UIView! {
        return dialogContent
    }
}
