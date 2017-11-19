//
//  CartItemCollectionCell.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CartItemCollectionCell: UICollectionViewCell {
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    public var data: ArticleData?
    public var removeFromCart: ((ArticleData) -> Void)?
    
    private var lastTouchUp: Date?
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        //  Maybe hide if double tapped
        let now = Date()
        
        if let then = lastTouchUp, now.timeIntervalSince(then) < 0.75 {
            //  Double-tapped
            removeFromCart!(data!)
        }
        
        lastTouchUp = now
    }
}
