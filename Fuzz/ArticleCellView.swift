//
//  ArticleCell.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ArticleCellView: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameView: UILabel!
    @IBOutlet weak var costView: UILabel!
    
    @IBOutlet weak var newBadge: UIView!
    @IBOutlet weak var quantityBadge: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    
    private var touchOffset: CGPoint?
    private var initialOrigin: CGPoint?
    private var collectionParent: ArticlesCollectionView?
    
    public var data: ArticleData?
    
    private var latestTouchSet: Set<UITouch>?
    private var latestTouchEvent: UIEvent?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.async {
            self.setupViews()
        }
    }
    
    private func setupViews(){
        newBadge.transform = CGAffineTransform(rotationAngle: CGFloat.pi * (-10 / 180))
        imageView.layer.cornerRadius = 12 * UIScreen.main.scale
    }
    
    public func attemptPickUp(){
        if collectionParent == nil {
            collectionParent = superview as! ArticlesCollectionView
        }
        print("PICKED UP")
        collectionParent?.pickedUpArticle = self
        if collectionParent?.pickedUpArticle != nil {
            //  Successfully picked up (conditioning in setter)
            wasPickedUp()
        }
    }
    
    private func wasPickedUp(){
        initialOrigin = frame.origin
        superview?.bringSubview(toFront: self)
        
        if let collection = superview as? ArticlesCollectionView {
            collection.isScrollEnabled = false
            
            let newParent = collection.pickedUpArticleParent!
            
            removeFromSuperview()
            newParent.addSubview(self)
            
            self.frame.origin.x += collection.frame.minX
            self.frame.origin.y += collection.frame.minY
            self.frame.origin.x -= collection.contentOffset.x
            self.frame.origin.y -= collection.contentOffset.y
            
            //  parent handles moving picked up article
            //self.touchesBegan(latestTouchSet!, with: nil)
        }
    }
    
    public func releaseIfPickedUp(){
        removeFromSuperview()
        
        let collection = collectionParent!
        collection.addSubview(self)
        
        frame.origin.x -= collection.frame.minX
        frame.origin.y -= collection.frame.minY
        frame.origin.x += collection.contentOffset.x
        frame.origin.y += collection.contentOffset.y
        
        UIView.animate(withDuration: 0.25, animations: {
            self.frame.origin = self.initialOrigin!
        })
        
        collectionParent!.pickedUpArticleReleased(self)
        collectionParent!.isScrollEnabled = true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        latestTouchSet = touches
        latestTouchEvent = event
        
        if collectionParent == nil {
            collectionParent = superview as! ArticlesCollectionView
        }
    
        guard let t = touches.first else { return }
        self.touchOffset = t.location(in: self)
        
        //wasPickedUp()
        
        print("scrollable:\(collectionParent?.isScrollEnabled)")
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
