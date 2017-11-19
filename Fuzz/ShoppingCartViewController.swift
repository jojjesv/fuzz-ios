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
    
    //  Cost for delivery
    public static var deliveryCost: Double? = 25.0
    
    //  Minimum total articles cost
    public static var minCost: Double? = 29.0
    
    private let addressKey = "adress"
    private let floorKey = "floor"
    private let doorCodeKey = "doorCode"
    private let fullNameKey = "fullName"
    private let phoneNumKey = "phoneNum"
    
    public var orderId: Int?
    
    @IBOutlet weak var cartItems: UICollectionView!
    @IBOutlet weak var cardNumInput: UITextField!
    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var doorCodeInput: UITextField!
    @IBOutlet weak var floorInput: UITextField!
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var phoneNumInput: UITextField!
    
    //  Cost label for articles cost
    @IBOutlet weak var costArticles: UILabel!
    
    //  Cost label for gross cost below minimum
    @IBOutlet weak var costBelowMin: UILabel!
    
    //  Cost label for delivery
    @IBOutlet weak var costDelivery: UILabel!
    
    //  Cost label for total cost
    @IBOutlet weak var costTotal: UILabel!
    
    private let placeOrderTries = 3
    private var placeOrderTriesRemaining = 0
    
    private var cartItemsDataSource: CartItemsDataSource?
    
    private static var cart = [ArticleData]()
    public static var cartItems: [ArticleData] {
        get {
            return cart
        }
    }
    
    public static func addToCart(_ article: ArticleData) {
        for item in cart {
            if item.id == article.id {
                //  Increment quantity and cost
                item.cost = item.cost! + article.cost!
                item.quantity = item.quantity! + article.quantity!
                return
            }
        }
        
        //  doesn't exist in cart
        cart.append(article)
    }
    
    public static func removeFromCart(_ article: ArticleData) {
        var i = 0
        for item in cart {
            if item.id == article.id {
                cart.remove(at: i)
                return
            }
            i += 1
        }
    }
    
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
    
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateCost(_ prefix: String, _ cost: Double, forLabel label: UILabel){
        let costStr = "\(cost)kr"
        
        let attrText = NSMutableAttributedString(string: prefix + costStr)
        attrText.addAttributes([ NSAttributedStringKey.foregroundColor: UIColor.blue ], range: NSMakeRange(prefix.count, costStr.count))
        
        label.attributedText = attrText
    }
    
    private func cartItemsChanged(){
        var cost = 0.0
        
        //  total cost
        for item in ShoppingCartViewController.cart {
            cost += item.cost!
        }
        
        updateCost("Kundvagn: ", cost, forLabel: self.costArticles)
        
        let min = ShoppingCartViewController.minCost!
        if cost < min {
            updateCost("Mellanskillnad (minst \(min)kr): ", min - cost, forLabel: self.costBelowMin)
            cost = min
            costBelowMin.isHidden = false
        } else {
            costBelowMin.isHidden = true
        }
        
        cost += ShoppingCartViewController.deliveryCost!
        
        updateCost("Summa: ", cost, forLabel: self.costTotal)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCost("Utkörning: ", ShoppingCartViewController.deliveryCost!, forLabel: self.costDelivery)
        
        cartItemsChanged()
        cartItemsDataSource = CartItemsDataSource()
        cartItems.dataSource = cartItemsDataSource
        cartItems.reloadData()
        
        let layout = cartItems.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
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
