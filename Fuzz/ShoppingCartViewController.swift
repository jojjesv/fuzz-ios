//
//  ShoppingCartViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ShoppingCartViewController: UIViewController {
    public static var postalCode: String?
    
    private let addressKey = "adress"
    private let floorKey = "floor"
    private let doorCodeKey = "doorCode"
    private let fullNameKey = "fullName"
    private let phoneNumKey = "phoneNum"
    
    public var orderId: Int?
    
    @IBOutlet weak var cardNumInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var doorCodeInput: UITextField!
    @IBOutlet weak var floorInput: UITextField!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var phoneNumInput: UITextField!
    
    private let placeOrderTries = 3
    private var placeOrderTriesRemaining = 0
    
    private static var cart = [ArticleData]()
    
    private static func cartToString() -> String {
        var str = ""
        
        for item in cart {
            str += "\(item.id!)x\(item.quantity!),"
        }
        
        if str.count > 0 {
            let q = str.count
            str = String(str.prefix(q))
        }
        
        return "1x43"
    }
    
    @IBAction func submit(_ sender: Any) {
        placeOrderTriesRemaining = placeOrderTries
        placeOrder()
    }
    
    func placeOrder(){
        let billingAddress = addressInput.text!
        let floor = floorInput.text!
        let doorCode = doorCodeInput.text!
        let fullName = fullNameInput.text!
        let message = messageInput.text!
        let phoneNum = phoneNumInput.text!
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(billingAddress, forKey: addressKey)
        userDefaults.set(floor, forKey: floorKey)
        userDefaults.set(doorCode, forKey: doorCodeKey)
        userDefaults.set(fullName, forKey: fullNameKey)
        userDefaults.set(phoneNum, forKey: phoneNumKey)
        userDefaults.synchronize()
        
        var postData = "billing_address=" + billingAddress.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        postData += "&payment_method="
        postData += "&orderer=" + fullName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        postData += "&cart_items=" + ShoppingCartViewController.cartToString().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        postData += "&postal_code=" + ShoppingCartViewController.postalCode!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        postData += "&phone_num=" + phoneNum.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        
        if floor.count > 0 {
            postData += "&floor=" + floor.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        }
        
        if doorCode.count > 0 {
            postData += "&door_code=" + doorCode.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        }
        
        if message.count > 0 {
            postData += "&message=" + message.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        }
        
        Backend.request(getParams: "action=place_order", postBody: postData, callback: self.parsePlaceOrder)
    }
    
    private func paymentMethod(fromId: Int) -> String {
        return "cash"
    }
    
    private func parsePlaceOrder(_ data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        guard let obj = json! else { return }
        
        //  TODO: handle json error
        
        let status = obj["status"] as! String
        
        switch status {
        case ResponseCodes.success:
            self.orderPlaced(orderId: (obj["order_id"] as! Int))
        case ResponseCodes.failed:
            placeOrderTriesRemaining -= 1
            if placeOrderTriesRemaining > 0 {
                //  Retry
                placeOrder()
            } else {
                
            }
            
        default:
            break
        }
    }
    
    private func orderPlaced(orderId: Int) {
        self.orderId = orderId
        performSegue(withIdentifier: "toPostOrder", sender: self)
    }
}
