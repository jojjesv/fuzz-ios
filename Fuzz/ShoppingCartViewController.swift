//
//  ShoppingCartViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit
import Stripe
import RNCryptor

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
    private let cardNumKey = "cardNum"
    private let cardExpireKey = "cardExpire"
    
    public var orderId: Int?
    
    @IBOutlet weak var cartItems: UICollectionView!
    @IBOutlet weak var cardNumInput: ShoppingCartField!
    @IBOutlet weak var cardCvcInput: ShoppingCartField!
    @IBOutlet weak var addressInput: ShoppingCartField!
    @IBOutlet weak var doorCodeInput: ShoppingCartField!
    @IBOutlet weak var floorInput: ShoppingCartField!
    @IBOutlet weak var messageInput: ShoppingCartField!
    @IBOutlet weak var fullNameInput: ShoppingCartField!
    @IBOutlet weak var phoneNumInput: ShoppingCartField!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImage: UIImageView!
    
    @IBOutlet weak var paymentMethodCard: UIView!
    @IBOutlet weak var paymentMethodCash: UIView!
    private var selectedPaymentMethodView: UIView!
    
    private var selectedPaymentMethod = "card"
    
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
    private static var mappedCart = [ArticleData]()
    
    //  Merged cart items.
    public static var mappedCartItems: [ArticleData] {
        get {
            return mappedCart
        }
    }
    
    public static func addToCart(_ article: ArticleData) {
        self.cart.append(article)
        
        for item in mappedCart {
            if item.id == article.id {
                //  Increment quantity and cost
                item.cost = item.cost! + article.cost!
                item.quantity = item.quantity! + article.quantity!
                return
            }
        }
        
        //  doesn't exist in cart
        mappedCart.append(article)
    }
    
    public static func removeFromCart(_ article: ArticleData) {
        var i = 0
        for item in mappedCart {
            if item.id == article.id {
                mappedCart.remove(at: i)
                break
            }
            i += 1
        }
        
        i = 0
        for item in cart {
            if (item.id == article.id && item.quantity == article.quantity && item.cost == article.cost) {
                cart.remove(at: i)
                break
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
            let q = str.count - 1
            str = String(str.prefix(q))
        }
        
        return str
    }
    
    //  Encrypt or decrypt a string,
    private func encOrDec(encrypt: Bool, string: String) -> String? {
        let key = "Q52ExlaQrLdU"
        let data = encrypt ? string.data(using: .utf8)! : Data.init(base64Encoded: string)!
        
        if encrypt {
            let encrData = try! RNCryptor.encrypt(data: data, withPassword: key).base64EncodedData()
            return String(data: encrData, encoding: .utf8)
        } else {
            let decrData = try! RNCryptor.decrypt(data: data, withPassword: key)
            return String(data: decrData, encoding: .utf8)
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateCost(_ prefix: String, _ cost: Double, forLabel label: UILabel){
        let costFormatted = String(format: cost.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", cost)
        let costStr = "\(costFormatted)kr"
        
        let attrText = NSMutableAttributedString(string: prefix + costStr)
        attrText.addAttributes([ NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.75) ], range: NSMakeRange(prefix.count, costStr.count))
        
        label.attributedText = attrText
    }
    
    internal func cartItemsChanged(){
        var cost = 0.0
        
        //  total cost
        for item in ShoppingCartViewController.mappedCart {
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
        cartItemsDataSource = CartItemsDataSource(viewController: self)
        cartItems.dataSource = cartItemsDataSource
        cartItems.reloadData()
        
        let layout = cartItems.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        
        checkDefaults()
        setupPaymentMethodOptions()
        
        cardCvcInput.nextField = addressInput
        addressInput.nextField = floorInput
        doorCodeInput.nextField = fullNameInput
        fullNameInput.nextField = phoneNumInput
        phoneNumInput.nextField = messageInput
    }
    
    //  Checks for previously saved fields data.
    private func checkDefaults(){
        let userDefaults = UserDefaults.standard
        
        addressInput.text = userDefaults.string(forKey: addressKey)
        floorInput.text = userDefaults.string(forKey: floorKey)
        doorCodeInput.text = userDefaults.string(forKey: doorCodeKey)
        fullNameInput.text = userDefaults.string(forKey: fullNameKey)
        phoneNumInput.text = userDefaults.string(forKey: phoneNumKey)
        
        if let cardNum = userDefaults.string(forKey: cardNumKey) {
            cardNumInput.text = encOrDec(encrypt: false, string: cardNum)
        }
    }
    
    private func setupPaymentMethodOptions(){
        selectedPaymentMethodView = paymentMethodCard
        
        paymentMethodCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.paymentMethodOptionTapped(gestureRecognizerSender:)))
        )
        
        paymentMethodCash.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.paymentMethodOptionTapped(gestureRecognizerSender:)))
        )
    }
    
    @objc private func paymentMethodOptionTapped(gestureRecognizerSender: UITapGestureRecognizer) {
        let senderView = gestureRecognizerSender.view
        guard selectedPaymentMethodView != senderView else {
            return
        }
        
        var newMethod = ""
        
        if senderView == paymentMethodCash {
            newMethod = "cash"
        } else if senderView == paymentMethodCard {
            newMethod = "card"
        }
        
        func tintSubviews(view: UIView, color: UIColor) {
            for subview in view.subviews {
                if let label = subview as? UILabel {
                    label.textColor = color
                } else {
                    view.tintColor = color
                }
            }
        }
        
        selectedPaymentMethodView.backgroundColor = UIColor.white
        
        senderView?.backgroundColor = UIColor(named: "ShoppingCartDark")
        //  First subview is a stackview
        tintSubviews(view: senderView!.subviews[0], color: UIColor.white)
        
        //  De-select old
        selectedPaymentMethodView.backgroundColor = UIColor.white
        tintSubviews(view: selectedPaymentMethodView.subviews[0], color: UIColor.black)
        
        self.selectedPaymentMethod = newMethod
        self.selectedPaymentMethodView = senderView
    }
    
    //  Presents the overlaying loading view.
    private func showLoading(){
        loadingView.isHidden = false
        loadingView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.loadingView.alpha = 1
        }
        
        //  Animate image.
        loadingImage.continuousRotate()
    }
    
    @IBAction func submit(_ sender: Any) {
        if let errorMessage = validateForm() {
            let view = UIAlertController(title: "Ogiltiga uppgifter", message: errorMessage, preferredStyle: .alert)
            view.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                view.dismiss(animated: true, completion: nil)
            }))
            show(view, sender: self)
            return
        }
        
        showLoading()
        placeOrderTriesRemaining = placeOrderTries
        placeOrder()
    }
    
    func placeOrder(){
        let paymentMethod = self.selectedPaymentMethod
        
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
        postData += "&payment_method=\(paymentMethod)"
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
        
        switch paymentMethod {
        case "cash":
            Backend.request(getParams: "action=place_order", postBody: postData, callback: self.parsePlaceOrder)
            break
            
        case "card":
            submitCardPayment(orderData: postData)
            break
            
        default: break
        }
    }
    
    /// Validates the form and optionally returns an error code.
    private func validateForm() -> String? {
        switch self.selectedPaymentMethod {
        case "card":
            
            if (cardNumInput.text == nil || cardNumInput.text?.count != 4 * 4) {
                return "Kontrollera ditt kortnummer."
            }
            
            if (cardCvcInput.text == nil || cardCvcInput.text?.count != 3) {
                return "Kontrollera ditt korts CVC-kod."
            }
            
            break
            
        default:
            break
        }
        
        if (addressInput.text == nil || (addressInput.text?.count)! < 3) {
            return "Ange din adress."
        }
        
        if (fullNameInput.text == nil || (fullNameInput.text?.count)! < 2) {
            return "Ange ditt fullständiga namn."
        }
        
        let phoneNumLength = phoneNumInput.text?.count
        if (phoneNumLength != 10 && phoneNumLength != 12) {
            return "Ange ditt telefonnummer."
        }
        
        return nil
    }
    
    private func fieldIsInvalid(){
        
    }
    
    private func submitCardPayment(orderData: String){
        let cardParams = STPCardParams()
        cardParams.number = cardNumInput.text
        cardParams.expMonth = 10
        cardParams.expYear = 2018
        cardParams.cvc = cardCvcInput.text
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            if let e = error {
                print("Card error", e)
            } else {
                self.submitCardToken(token: token!, orderData: orderData)
            }
        }
    }
    
    private func placeOrderFailed(){
        //  TODO: Handle error
    }
    
    private func submitCardToken(token: STPToken, orderData: String){
        //  Store data
        let defaults = UserDefaults.standard
        
        defaults.set(cardNumKey, forKey: encOrDec(encrypt: true, string: cardNumInput.text!)!)
        defaults.synchronize()
        
        let post = "token_id=\(token.tokenId)&\(orderData)"
        Backend.request(getParams: "action=process_card_payment", postBody: post, callback: self.parsePlaceOrder)
    }
    
    private func paymentMethod() -> String {
        return "cash"
    }
    
    private func parsePlaceOrder(_ data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        let response = String(data: data, encoding: .utf8)
        
        guard json != nil else { return }
        
        let obj = json!!
        
        //  TODO: handle json error
        
        let status = String(obj["status"] as! Int)
        
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
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let postOrder = segue.destination as? PostOrderViewController {
            postOrder.orderId = self.orderId
        }
    }
}

extension UIView {
    /// Makes this view continuously rotate.
    public func continuousRotate() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.duration = 0.75
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim.repeatCount = .infinity
        anim.fromValue = 0.0
        anim.toValue = -359.0.toRad()
        self.layer.add(anim, forKey: "Anim")
    }
}
