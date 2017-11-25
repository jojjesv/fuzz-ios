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
    
    @IBOutlet weak var loadingIndicator: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var postalCodeInput: UITextField!
    
    @IBOutlet weak var inputContainer: UIView!
    
    @IBOutlet weak var splashLogo: UIImageView!
    @IBOutlet weak var splashLogoText: UIImageView!
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var postSplashView: UIView!
    
    @IBOutlet weak var footer: FooterView!
    private var fetchedConfig = false
    
    public var categoriesJson: [String: Any]?
    
    private var logoTopConstraint: NSLayoutConstraint!
    
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
        
        footer.isHidden = true
        footer.alpha = 0
        
        delayHideSplash()
        fetchConfig()
        
        logoTopConstraint = view.constraint(withId: "logoTopY")!
        NSLayoutConstraint.deactivate([logoTopConstraint])
    }
    
    func delayHideSplash(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.hideSplash()
        }
    }
    
    func hideSplash(){
        NSLayoutConstraint.activate([logoTopConstraint])
        
        let centerConstraint = view.constraint(withId: "logoCenterY")!
        NSLayoutConstraint.deactivate([centerConstraint])
        
        let duration: TimeInterval = 0.3
        
        UIView.animate(withDuration: duration, animations: {
            self.splashLogoText.alpha = 0
        }, completion: {
            (finished) in
            //self.splashLogoText.removeFromSuperview()
            //self.splashLogoText = nil
        })
        
        UIView.animate(withDuration: duration * 2.5, animations: {
            self.splashLogo.frame.origin.y = self.logoTopConstraint.constant
        }, completion: {
            (finished) in
        })
        
        animatePostSplashLayout()
    }
    
    func animatePostSplashLayout(){
        if fetchedConfig {
            animateFooter()
        }
        
        postSplashView.isHidden = false
        
        let baseDelay = 0.2
        animatePostSplashView(view: subheader, startDelay: baseDelay)
        animatePostSplashView(view: inputContainer, startDelay: baseDelay * 2)
        animatePostSplashView(view: submitButton, startDelay: baseDelay * 3)
    }
    
    func animatePostSplashView(view: UIView, startDelay: TimeInterval){
        view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        view.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, delay: startDelay, options: [], animations: {
            view.alpha = 1.0
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wasDeliverable(){
        ShoppingCartViewController.postalCode = submittedPostalCode
        fetchCategories()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let main = segue.destination as? ViewController {
            main.categoriesJson = self.categoriesJson
        }
    }

    func submit(postalCode: String) {
        submittedPostalCode = postalCode
        
        showLoading()
        
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
    
    /// Shows a loading view adjacent to the submit button.
    func showLoading(){
        let view = loadingIndicator!
        
        view.isHidden = false
        
        view.continuousRotate()
        
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 0.35) {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            
            view.superview!.frame.origin.x += (view.frame.height + 12) / 2
        }
    }
    
    /// Hies the loading view adjacent to the submit button.
    func hideLoading(){
        let view = loadingIndicator!
        
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
            view.superview!.frame.origin.x -= (view.frame.height + 12) / 2
        }, completion: {
            (finished) in
            view.isHidden = true
        })
    }
    
    func fetchCategories(){
        Backend.request(getParams: "out=categories", postBody: nil, callback: { (data) in
            let response = String(data: data, encoding: .ascii)
            
            self.categoriesJson = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            self.fetchCategoryBackgrounds()
        })
    }
    
    func fetchCategoryBackgrounds(){
        let json = self.categoriesJson!
        
        var remainingBackgroundCount = 0
        
        let categories = json["items"] as! [[String: Any]]
        let baseImageUrl = json["base_image_url"] as! String
        
        for category in categories {
            if let _ = category["background"] {
                remainingBackgroundCount += 1
            }
        }
        
        for category in categories {
            guard let _ = category["background"] else { continue }
            
            let bgUrl = baseImageUrl + (category["background"] as! String)
            Caches.getImage(fromUrl: bgUrl, callback: {
                (img) in
                remainingBackgroundCount -= 1
                if remainingBackgroundCount == 0 {
                    //  Last one
                    self.toMain()
                }
            })
        }
    }
    
    //  Fetches configuration
    func fetchConfig(){
        Backend.request(getParams: "out=config&names=min_order_cost,company_address,company_email,company_name,company_phone_num,delivery_cost,open_days,open_time,closing_time", postBody: nil) { (data) in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
                self.backendError()
                return
            }
            
            ShoppingCartViewController.minCost = (json["min_order_cost"] as! NSString).doubleValue
            ShoppingCartViewController.deliveryCost = (json["delivery_cost"] as! NSString).doubleValue
            
            AboutAppDialog.data = json
            
            self.fetchedConfig = true
            
            if !self.postSplashView.isHidden {
                //  Is post splash
                DispatchQueue.main.async(execute: self.animateFooter)
            }
        }
    }
    
    func animateFooter(){
        footer.alpha = 0
        footer.isHidden = false
        
        let dy: CGFloat = 24
        
        footer.frame.origin.y += dy
    
        UIView.setAnimationCurve(.easeOut)
        UIView.animate(withDuration: 0.3) {
            self.footer.alpha = 1
            self.footer.frame.origin.y -= dy
        }
    }
    
    func backendError(){
        hideLoading()
        
        let dialog = TextDialog()
        dialog.message = "Fuzz kan inte nås just nu."
        dialog.header = "Nätverksfel"
        
        dialog.show(parent: view)
    }
}

extension UIView {
    public func constraint(withId: String) -> NSLayoutConstraint? {
        for constraint in self.constraints {
            print("ID: \(constraint.identifier)")
            if constraint.identifier == withId {
                return constraint
            }
        }
        
        return nil
    }
}
