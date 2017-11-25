//
//  ArticlesCollectionView.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation

import UIKit

//  Manages categories gestures.
class ArticlesCollectionView: UICollectionView, UICollectionViewDelegate, CategoriesTouchDelegate {
    
    public var background: ArticlesBackground!
    private let scrollSlop = CGFloat(2)
    private var initialTouch: CGPoint?
    private var oldTouch: CGPoint?
    private var scrollDirection: ScrollDirection = .none
    private var articlesPerFetch = 13
    private var src = ArticlesDataSource()
    public var page: Int! = 0
    private var fetching = false
    private var fetchedLastArticles = false
    private var oldPickedUpLocation: CGPoint?
    
    public var categoriesHeader: UIView?
    private var initialCategoriesHeaderOrigin: CGPoint?
    
    private var headerHideScrollThreshold: CGFloat! = 24.0
    private var oldScrollY: CGFloat! = 0.0
    
    //  View parent for picked up articles.
    public var pickedUpArticleParent: UIView?
    
    private var _pickedUpArticle: ArticleCellView?
    public var pickedUpArticle: ArticleCellView? {
        set {
            if scrollDirection == .none {
                if newValue != nil {
                    self.viewController?.hideDragHints()
                }
                _pickedUpArticle = newValue
            }
        } get {
            return _pickedUpArticle
        }
    }
    
    public var categories: CategoriesView?
    public var viewController: ViewController?
    private var categoriesArray: [Category]?
    
    private var hasPickedUpArticle = false
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    private var d: TestDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        setupArticlesLongPress()
    }
    
    private func setupArticlesLongPress(){
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(attemptPickUpArticle))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        longPressGestureRecognizer.cancelsTouchesInView = false
        d = TestDelegate()
        longPressGestureRecognizer.delegate = d
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private class TestDelegate: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    
    //  Searches for an article to pick up
    @objc private func attemptPickUpArticle(){
        if longPressGestureRecognizer.state == .began {
            let location = longPressGestureRecognizer.location(in: self)
            //location.x += contentOffset.x
            //location.y += contentOffset.y
            
            oldPickedUpLocation = nil
            
            for cell in visibleCells {
                if cell.frame.contains(location) {
                    (cell as! ArticleCellView).attemptPickUp()
                    break
                }
            }
        } else if longPressGestureRecognizer.state == .ended {
            //  release
            if let pickedUp = pickedUpArticle {
                pickedUp.releaseIfPickedUp()
                pickedUpArticle = nil
            }
        } else {
            guard let pickedUp = pickedUpArticle else { return }
            
            let location = longPressGestureRecognizer.location(in: self)
            if oldPickedUpLocation == nil {
                oldPickedUpLocation = location
            }
            
            let dx: CGFloat = location.x - oldPickedUpLocation!.x
            let dy: CGFloat = location.y - oldPickedUpLocation!.y
            
            oldPickedUpLocation = location
            
            pickedUp.frame.origin.x += dx
            pickedUp.frame.origin.y += dy
            
            viewController?.pickedUpArticleMoved(pickedUp)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let nextPageOffsetThreshold = scrollView.contentSize.height - scrollView.frame.height
        
        let scrollY = scrollView.contentOffset.y
        
        if scrollY >= nextPageOffsetThreshold {
            fetchNextArticlesPage()
        }
        
        let headerThreshold = headerHideScrollThreshold
        if scrollY >= headerThreshold! && oldScrollY! < headerThreshold! {
            changeHeaderVisibility(visible: false)
        } else if scrollY < headerThreshold! && oldScrollY! >= headerThreshold! {
            changeHeaderVisibility(visible: true)
        }
        
        let deltaScroll = scrollY - oldScrollY
        
        background.offset(by: -deltaScroll)
        
        oldScrollY = scrollY
    }
    
    private func changeHeaderVisibility(visible: Bool){
        let header = categoriesHeader!
        header.isHidden = false
        
        if initialCategoriesHeaderOrigin == nil {
            initialCategoriesHeaderOrigin = header.frame.origin
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            header.frame.origin.y = (self.initialCategoriesHeaderOrigin?.y)! - (visible ? 0.0 : header.frame.height)
            header.alpha = visible ? 1 : 0
        }, completion: visible ? nil : {
            (finished) in
            if finished {
                header.isHidden = true
            }
        })
    }
    
    private func fetchNextArticlesPage(){
        if !fetching && !fetchedLastArticles {
            page = page + 1
            fetch(categories: self.categoriesArray, append: true)
        }
    }
    
    public func fetch(categories: [Category]?, append: Bool){
        if fetching {
            return
        }
        
        fetching = true
        
        self.categoriesArray = categories
        
        var get = "out=articles&count=\(articlesPerFetch)&page=\(page!)"
        
        if !append {
            src.items.removeAll()
        }
        
        if categories != nil && categories!.count > 0 {
            get += "&categories="
            let n = categories!.count - 1
            for i in 0...n {
                get += "\(categories![i].id)"
                if i < n {
                    //  Append delimiter
                    get += ","
                }
            }
        } else {
            //  Fetch popular articles
            get += "&popular"
        }
        
        Backend.request(getParams: get, postBody: nil, callback: self.parse)
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
            
            if articles.count > 0 {
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
                    for i in oldItemCount..<self.src.items.count {
                        paths.append(IndexPath(item: i, section: 0))
                    }
                    
                    self.insertItems(at: paths)
                }
            }
            
            fetchedLastArticles = articles.count == 0
        
        } catch {
            parseError()
        }
        
        fetching = false
    }
    
    public func pickedUpArticleMoved(_ sender: ArticleCellView){
        viewController!.pickedUpArticleMoved(sender)
        hasPickedUpArticle = true
    }
    
    public func pickedUpArticleReleased(_ sender: ArticleCellView){
        viewController!.pickedUpArticleReleased(sender)
        hasPickedUpArticle = false
    }
    
    private func parseError(){
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initialTouch = touches.first?.location(in: self)
        oldTouch = initialTouch
        if let categories = touches.first?.view as? CategoriesView {
            categories.isScrollEnabled = false
        } else {
            isScrollEnabled = true
        }
        
        print("TOUCH BEGAN")
        
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let pos = touches.first?.location(in: self)
        let deltaPos: CGPoint! = CGPoint(x: pos!.x - oldTouch!.x, y: pos!.y - oldTouch!.y)
        oldTouch = pos
        
        let categories = touches.first?.view as? CategoriesView
        
        switch scrollDirection {
        case .none:
            
            print("none")
            
            if pickedUpArticle == nil {
                let deltaX = pos!.x - initialTouch!.x
                
                if self.categories!.visible ? deltaX < scrollSlop : deltaX > scrollSlop {
                    scrollDirection = .horizontal
                    if categories != nil {
                        categories?.isScrollEnabled = false
                    } else {
                        isScrollEnabled = false
                    }
                } else if abs(pos!.y - initialTouch!.y) > scrollSlop {
                    scrollDirection = .vertical
                    if categories != nil {
                        categories?.isScrollEnabled = true
                        categories?.touchesBegan(touches, with: event)
                    } else {
                        print("became vertical")
                        isScrollEnabled = true
                        
                    }
                }
            } else {
                //  move picked up
                
                pickedUpArticle!.frame.origin.x += deltaPos.x
                pickedUpArticle!.frame.origin.y += deltaPos.y
                
                print("deltaPos", deltaPos)
                print("frame", pickedUpArticle!.frame.origin)
                viewController!.pickedUpArticleMoved(pickedUpArticle!)
            }
            
        case .horizontal:
            print("horizontal")
            let delta = pos!.x - initialTouch!.x
            var val = delta / 100
            
            if (self.categories!.visible) {
                val += 1
            }
            
            self.categories!.transitionValue = val
            
        case .vertical:
            print("vertical, scrollable:\(isScrollEnabled)")
            
        default:
            break
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if pickedUpArticle != nil {
            //  release picked up article
            pickedUpArticle = nil
        }
        if scrollDirection == .horizontal {
            //  Transitioning categories
            categories?.determineVisibility()
        }
        scrollDirection = .none
        
        isScrollEnabled = true
    }
    
    private enum ScrollDirection {
        case none
        case horizontal
        case vertical
    }
}
