//
//  CartItemsDataSource.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CartItemsDataSource: NSObject, UICollectionViewDataSource {
    private var viewController: ShoppingCartViewController
    
    public init(viewController: ShoppingCartViewController) {
        self.viewController = viewController
        
        super.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShoppingCartViewController.mappedCartItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let view = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CartItemCollectionCell
        
        let item = ShoppingCartViewController.mappedCartItems[indexPath.item]
        
        view.removeFromCart = {
            (data) in
            ShoppingCartViewController.removeFromCart(data)
            collectionView.deleteItems(at: [indexPath])
            self.viewController.cartItemsChanged()
        }
        view.data = item
        view.quantityLabel.text = "\(item.quantity!)st"
        
        let costStr = String(format: item.cost?.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", item.cost!)
        view.costLabel.text = "\(costStr)kr"
        if item.image == nil {
            if !item.fetchingImage {
                item.fetchingImage = true
                Caches.getImage(fromUrl: item.imageUrl!, callback: { (img) in
                    item.image = img
                    collectionView.reloadItems(at: [indexPath])
                })
            }
        } else {
            view.imageView.image = item.image
        }
    
        return view
    }
}
