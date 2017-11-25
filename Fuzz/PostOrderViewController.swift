//
//  PostOrderViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class PostOrderViewController: UIViewController, ETADelegate {
    private var trivialMessagesStrings: [String] = [ "Paketerar regnbågar", "Botar sockersjukar", "Ordnar första hjälpen mot sockersug", "Skördar snacks", "Jagar gummibjörnar på rymmen" ]
    
    public var orderId: Int!
    @IBOutlet weak var etaTimerLabel: UILabel!
    @IBOutlet weak var etaTimer: ETATimer!
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var trivialMessagesContainer: UIView!
    @IBOutlet weak var trivialMessages: UILabel!
    private var trivialMessageIndex = 0
    
    @IBOutlet weak var thanksContainer: UIStackView!
    @IBOutlet weak var thanksCandy: UIImageView!
    @IBOutlet weak var thanksLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        trivialMessagesStrings.shuffle()
        
        etaTimer.label = etaTimerLabel
        etaTimer.reachedZero = self.timerReachedZero
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            //self.etaChanged(etaMins: 1, deliverer: "Alfred A")
        }
        
        let listener = ETAListener(orderId: self.orderId)
        listener.delegate = self
        
        loopTrivialMessages()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            self.showThanks()
        })
    }
    
    private func loopTrivialMessages(){
        self.trivialMessages.text = self.trivialMessagesStrings[self.trivialMessageIndex]
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { (timer) in
            self.trivialMessageIndex = (self.trivialMessageIndex + 1) % self.trivialMessagesStrings.count
            self.setTrivialMessage(newMessage: self.trivialMessagesStrings[self.trivialMessageIndex])
        }
    }
    
    private func setTrivialMessage(newMessage: String){
        UIView.animate(withDuration: 0.3, animations: {
            self.trivialMessagesContainer.alpha = 0
        }, completion: {
            (finished) in
            self.trivialMessages.text = newMessage
            UIView.animate(withDuration: 0.3, animations: {
                self.trivialMessagesContainer.alpha = 1
            })
        })
    }
    
    public func etaChanged(etaMins: Int, deliverer: String) {
        etaTimer.isHidden = false
        etaTimer.alpha = 0
        etaTimer.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        etaTimer.etaChanged(etaMins: etaMins, deliverer: deliverer)
        
        UIView.animate(withDuration: 0.35) {
            self.etaTimer.alpha = 1
            self.etaTimer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        subheader.text = "Din beställning levereras av \(deliverer)"
    }
    
    private func timerReachedZero(){
        UIView.animate(withDuration: 1, animations: {
            self.etaTimer.transform = CGAffineTransform(scaleX: 0, y: 0)
        }, completion: {
            (finished) in
            
            self.etaTimer.removeFromSuperview()
            self.etaTimer = nil
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.showThanks()
            })
        })
    }
    
    private func showThanks(){
        thanksLabel.alpha = 0
        thanksContainer.alpha = 0
        thanksContainer.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        thanksContainer.isHidden = false
        
        func showText(){
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                self.thanksLabel.alpha = 1
            })
        }
        
        UIView.animate(withDuration: 0.75, animations: {
            self.thanksContainer.alpha = 1
            self.thanksContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: {
            (finished) in
            
            let candy = self.thanksCandy!
            
            UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
                
                candy.alpha = 0
                candy.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 64).rotated(by: CGFloat(25.0.toRad()))
                
            }, completion: {
                (finished) in
                showText()
            })
        })
    }
}

//  https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
