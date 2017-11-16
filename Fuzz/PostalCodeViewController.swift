//
//  PostalCodeViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class PostalCodeViewController: UIViewController {

    private let postalCodeKey = "pC";
    
    private var submittedPostalCode: String?
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var postalCodeInput: UITextField!
    
    @IBAction func submitPressed(_ sender: Any) {
        self.submit(postalCode: postalCodeInput.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ud = UserDefaults.standard
        if let postalCode = ud.string(forKey: postalCodeKey) {
            //  Has stored postal code
            postalCodeInput.text = postalCode
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wasDeliverable(){
        toMain()
    }
    
    func wasUndeliverable(){
        let message = "Just nu levererar vi tyvärr inte till \(submittedPostalCode!). Kolla förbi senare!"
        let dialog = UIAlertController(title: "Olevererbar adress", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        present(dialog, animated: true, completion: nil)
    }
    
    func toMain(){
        let ud = UserDefaults.standard
        ud.set(submittedPostalCode, forKey: postalCodeKey)
        ud.synchronize()
        
        performSegue(withIdentifier: "toMain", sender: self)
    }

    func submit(postalCode: String) {
        submittedPostalCode = postalCode
        
        Backend.request(getParams: "out=check_deliverable&postal_code=\(postalCode)", postBody: nil, callback: { (data) in
            let response = String(data: data, encoding: String.Encoding.utf8)!
            
            switch response {
                
            case ResponseCodes.positive:
                self.wasDeliverable()
            case ResponseCodes.negative:
                self.wasUndeliverable()
                
            default:
                break
            }
        })
    }
}
