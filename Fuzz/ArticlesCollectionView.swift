//
//  ArticlesCollectionView.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation

import UIKit

class ArticlesCollectionView: UICollectionView, UICollectionViewDelegate {
    
    private var articlesPerFetch = 13
    private var src = ArticlesDataSource()
    
    //  View parent for picked up articles.
    public var pickedUpArticleParent: UIView?
    
    public var viewController: ViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        src.reloadItem = {
            (index) in
            self.reloadItems(at: [index])
        }
        self.delegate = self
        fetch()
    }
    
    public func fetch(){
        Backend.request(getParams: "out=articles&count=\(articlesPerFetch)", postBody: nil, callback: self.parse)
    }
    
    private func parse(_ src: Data) {
        let jsonObj = try? JSONSerialization.jsonObject(with: src, options: []) as? [String: Any]
        
        guard let obj = jsonObj! else {
            parseError()
            return
        }
        
        if dataSource == nil {
            dataSource = self.src
        }
        
        do {
            
            let baseImageUrl = obj["base_image_url"] as! String
            let articles = obj["articles"] as! [[String: Any]]
            
            let oldItemCount = self.src.items.count
            
            var quantities: [String]
            var costs: [String]
            var articleData: ArticleData
            for article in articles {
                quantities = (article["quantities"] as! String).components(separatedBy: ",")
                costs = (article["costs"] as! String).components(separatedBy: ",")
                
                for i in 0..<quantities.count {
                    articleData = ArticleData()
                    articleData.name = article["name"] as! String
                    articleData.id = article["id"] as! Int
                    articleData.imageUrl = baseImageUrl + (article["image"] as! String)
                    articleData.cost = Double(costs[i])
                    articleData.quantity = Int(quantities[i])
                    articleData.isNew = article["is_new"] as! Bool
                    
                    self.src.items.append(articleData)
                }
            }
            
            if oldItemCount == 0 {
                //  Reload all
                self.reloadData()
            } else {
                var paths = [IndexPath]()
                for i in oldItemCount...self.src.items.count {
                    paths.append(IndexPath(item: i, section: 0))
                }
                
                self.reloadItems(at: paths)
            }
        
        } catch {
            parseError()
        }
    }
    
    public func pickedUpArticleMoved(_ sender: ArticleCellView){
        viewController!.pickedUpArticleMoved(sender)
    }
    
    public func pickedUpArticleReleased(_ sender: ArticleCellView){
        viewController!.pickedUpArticleReleased(sender)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    private func parseError(){
        
    }
}
