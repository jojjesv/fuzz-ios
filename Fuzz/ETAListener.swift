//
//  ETAListener.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-22.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation

import UserNotifications
import UserNotificationsUI

//  Listens for ETA changes in order.
public class ETAListener {
    //  Poll interval, in seconds
    private let pollInterval = 4
    private var orderId: Int
    public var delegate: ETADelegate?
    private var timer: Timer?
    
    init(orderId: Int) {
        self.orderId = orderId
        
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(pollInterval), repeats: true, block: { timer in
            self.poll()
        })
    }
    
    @objc func poll(){
        let get = "out=delivery_eta&order_id=\(orderId)"
        
        Backend.request(getParams: get, postBody: nil) { (data) in
            if data.count > 0 {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                let mins = json!["minutes"] as! Int
                let deliverer = json!["deliverer"] as! String
                
                DispatchQueue.main.async {
                    self.etaChanged(etaMins: mins, deliverer: deliverer)
                }
                
                //  Stop polling
                self.timer!.invalidate()
            }
        }
    }
    
    private func etaChanged(etaMins: Int, deliverer: String){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.body = "Din beställning kommer om \(etaMins) minuter"
            let notification = UNNotificationRequest(identifier: String(self.orderId), content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(notification, withCompletionHandler: {
                error in
                print("Error: \(error)")
            })
        }
        delegate!.etaChanged(etaMins: etaMins, deliverer: deliverer)
    }
}

public protocol ETADelegate {
    func etaChanged(etaMins: Int, deliverer: String)
}
