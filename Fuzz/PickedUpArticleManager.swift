//
//  PickedUpArticleManager.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class PickedUpArticleManager {
    
    private var cartButton: UIView
    private var infoButton: UIView
    //  Absolute frame.
    private var cartButtonAbsFrame: CGRect
    //  Absolute frame.
    private var infoButtonAbsFrame: CGRect
    private var viewController: ViewController
    
    private var isHoverShoppingCart = false
    private var isHoverArticleInfo = false
    
    init(with viewController: ViewController) {
        self.viewController = viewController
        
        let actionBarFrame = viewController.actionBar.frame
        infoButton = viewController.actionBar.viewWithTag(1)!
        cartButton = viewController.actionBar.viewWithTag(2)!
        
        cartButtonAbsFrame = cartButton.frame.offsetBy(dx: actionBarFrame.origin.x, dy: actionBarFrame.origin.y)
        infoButtonAbsFrame = infoButton.frame.offsetBy(dx: actionBarFrame.origin.x, dy: actionBarFrame.origin.y)
    }
    
    public func pickedUpArticleMoved(_ sender: ArticleCellView){
        let hoverArticleInfo = infoButtonAbsFrame.intersects(sender.frame)
        if !hoverArticleInfo {
            let hoverShopppingCart = cartButtonAbsFrame.intersects(sender.frame)
            if hoverShopppingCart && !isHoverShoppingCart {
                //  Entered
                viewController.actionBarShoppingCart.changeCircleLayerVisibility(visible: true)
            } else if !hoverShopppingCart && isHoverShoppingCart {
                //  Left
                viewController.actionBarShoppingCart.changeCircleLayerVisibility(visible: false)
            }
            
            if isHoverArticleInfo {
                //  Left
                viewController.actionBarArticleInfo.changeCircleLayerVisibility(visible: false)
            }
            
            isHoverShoppingCart = hoverShopppingCart
        } else {
            isHoverShoppingCart = false
            
            if !isHoverArticleInfo {
                //  Entered
                viewController.actionBarArticleInfo.changeCircleLayerVisibility(visible: true)
            }
        }
        
        isHoverArticleInfo = hoverArticleInfo
    }
    
    public func pickedUpArticleReleased(_ sender: ArticleCellView){
        if isHoverArticleInfo {
            viewController.showArticleInfo(sender.data!)
            viewController.actionBarShoppingCart.changeCircleLayerVisibility(visible: false)
        } else if isHoverShoppingCart {
            viewController.addToCart(sender.data!)
            viewController.actionBarShoppingCart.changeCircleLayerVisibility(visible: false)
        } else {
            viewController.presentDragHints()
        }
    }
}
