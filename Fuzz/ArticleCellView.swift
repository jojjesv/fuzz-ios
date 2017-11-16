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
    
    private var touchOffset: CGPoint?
    private var initialOrigin: CGPoint?
    private var collectionParent: ArticlesCollectionView?
    
    public var data: ArticleData?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func wasPickedUp(){
        initialOrigin = frame.origin
        superview?.bringSubview(toFront: self)
        
        if let collection = superview as? ArticlesCollectionView {
            collection.isScrollEnabled = false
            
            if collectionParent == nil {
                collectionParent = collection
            }
            
            let newParent = collection.pickedUpArticleParent!
            
            removeFromSuperview()
            newParent.addSubview(self)
        }
    }
    
    private func wasReleased(){
        removeFromSuperview()
        collectionParent!.addSubview(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.frame.origin = self.initialOrigin!
        })
        
        collectionParent!.pickedUpArticleReleased(self)
        collectionParent!.isScrollEnabled = true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        guard let t = touches.first else { return }
        self.touchOffset = t.location(in: self)
        
        wasPickedUp()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let t = touches.first else { return }
        var loc = t.location(in: self.superview)
        
        loc.x -= touchOffset!.x
        loc.y -= touchOffset!.y
        
        self.frame.origin.x = loc.x
        self.frame.origin.y = loc.y
        
        self.collectionParent?.pickedUpArticleMoved(self)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        wasReleased()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
