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
    
    init(with viewController: ViewController) {
        self.viewController = viewController
        
        let actionBarFrame = viewController.actionBar.frame
        infoButton = viewController.actionBar.viewWithTag(1)!
        cartButton = viewController.actionBar.viewWithTag(2)!
        
        cartButtonAbsFrame = cartButton.frame.offsetBy(dx: actionBarFrame.origin.x, dy: actionBarFrame.origin.y)
        infoButtonAbsFrame = infoButton.frame.offsetBy(dx: actionBarFrame.origin.x, dy: actionBarFrame.origin.y)
    }
    
    public func pickedUpArticleMoved(_ sender: ArticleCellView){
        print(sender.frame.intersects(infoButtonAbsFrame))
    }
    
    public func pickedUpArticleReleased(_ sender: ArticleCellView){
        viewController.showArticleInfo(forView: sender)
        print("Released", sender.frame.intersects(infoButtonAbsFrame))
    }
}
