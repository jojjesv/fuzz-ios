//
//  ArticlesDataSource.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ArticlesDataSource: NSObject, UICollectionViewDataSource {
    public var items: [ArticleData]! = [ArticleData]()
    public var reloadItem: ((IndexPath) -> Void)?
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let view: ArticleCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "article", for: indexPath) as! ArticleCellView
        
        let item = self.items[indexPath.item];
        view.nameView.text = item.name
        
        var cost = String(item.cost!)
        
        if item.cost?.truncatingRemainder(dividingBy: 1.0) == 0 {
            //  No decimals
            cost = String(format: "%.0f", item.cost!)
        }
        
        view.costView.text = "\(cost)kr"
        
        if item.image == nil {
            if !item.fetchingImage {
                item.fetchingImage = true
                
                Caches.getImage(fromUrl: item.imageUrl!, callback: {
                    (img: UIImage?) in
                    
                    item.image = img
                    guard img != nil else { return }
                    
                    self.reloadItem!(indexPath)
                })
            }
        } else {
            view.imageView.image = item.image
        }
        
        return view
    }
}
