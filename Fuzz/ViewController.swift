//
//  ViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var background: ArticlesBackground!
    @IBOutlet weak var actionBar: ActionBar!
    @IBOutlet weak var pickedUpParent: UIView!
    @IBOutlet weak var articlesCollection: ArticlesCollectionView!
    @IBOutlet weak var actionBarLogo: UIImageView!
    @IBOutlet weak var categoriesHeader: UILabel!
    
    @IBOutlet weak var actionBarArticleInfo: ActionBarButton!
    @IBOutlet weak var actionBarShoppingCart: ActionBarButton!
    @IBOutlet weak var actionBarInfoDragNote: UIView!
    @IBOutlet weak var actionBarCartDragNote: UIView!
    
    private var timesPresentedDragHints: Int = 0
    private var isPresentingDragHints = false
    
    @IBOutlet weak var categories: CategoriesView!
    private var categoriesDataSource = CategoriesDataSource()
    
    //  Passed by postal code VC
    public var categoriesJson: [String: Any]?
    
    private var pickedUpArticleManager: PickedUpArticleManager?
    
    @IBOutlet weak var toggleCategoriesButton: UIView!
    
    @IBAction func showCart(_ sender: Any) {
        performSegue(withIdentifier: "toCart", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articlesCollection.viewController = self
        articlesCollection.pickedUpArticleParent = self.pickedUpParent
        pickedUpArticleManager = PickedUpArticleManager(with: self)
        
        articlesCollection.categories = categories
        articlesCollection.categoriesHeader = categoriesHeader
        articlesCollection.background = background
        categories.selectedChanged = refetchFromCategoryChange
    
        func setupActionBarDragNote(view: UIView, smallerCorner: UIRectCorner) {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor(named: "ShoppingCartDark")?.cgColor
            layer.frame = view.frame
            layer.frame.origin = CGPoint()
            layer.path = UIBezierPath().withOneSmallerRadius(rect: layer.frame, corner: smallerCorner).cgPath
            view.layer.insertSublayer(layer, at: 0)
        }
        
        setupActionBarDragNote(view: actionBarCartDragNote, smallerCorner: .topRight)
        //actionBarCartDragNote.layer.anchorPoint = CGPoint(x: actionBarCartDragNote.frame.width, y: 0.0)
        setupActionBarDragNote(view: actionBarInfoDragNote, smallerCorner: .topLeft)
        //actionBarInfoDragNote.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        setupCategories()
        
        //  Initial fetch
        refetchFromCategoryChange(newCategories: [])
        
        categories.touchDelegate = articlesCollection
        
        toggleCategoriesButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.toggleCategories))
        )
    }
    
    ///  Presents the drag hints for article info and shopping cart buttons.
    public func presentDragHints(){
        guard !isPresentingDragHints else { return }
        
        isPresentingDragHints = true
        
        let articleInfo = actionBarInfoDragNote
        let shoppingCart = actionBarCartDragNote
        
        articleInfo?.isHidden = false
        shoppingCart?.isHidden = false
        
        articleInfo?.alpha = 0
        articleInfo?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        shoppingCart?.alpha = 0
        shoppingCart?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 0.3) {
            articleInfo?.alpha = 1
            articleInfo?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.15, animations: {
            shoppingCart?.alpha = 1
            shoppingCart?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        timesPresentedDragHints += 1
        
        //  Schedule hiding
        let generation = timesPresentedDragHints
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.5) {
            if generation == self.timesPresentedDragHints {
                //  Not shown since
                self.hideDragHints()
            }
        }
    }
    
    public func hideDragHints(){
        guard isPresentingDragHints else { return }
        
        let articleInfo = actionBarInfoDragNote
        let shoppingCart = actionBarCartDragNote
        
        UIView.animate(withDuration: 0.3, animations: {
            articleInfo?.alpha = 0
            articleInfo?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: {
            (finished) in
            articleInfo?.isHidden = true
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.15, animations: {
            shoppingCart?.alpha = 0
            shoppingCart?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: {
            (finished) in
            articleInfo?.isHidden = true
        })
        
        isPresentingDragHints = false
    }
    
    @objc public func toggleCategories(){
        categories.toggleVisibility()
    }
    
    public func refetchFromCategoryChange(newCategories: [Category]){
        //  Categories to string
        var headerStr: String
        
        if newCategories.count == 0 {
            headerStr = "Populärt denna vecka"
        } else {
            headerStr = newCategories.first!.name
            
            let n = newCategories.count
            for i in 1..<n {
                if i == n - 1 {
                    //  Last
                    headerStr += " och "
                } else {
                    headerStr += ", "
                }
                
                headerStr += newCategories[i].name
            }
        }
        
        categoriesHeader.text = headerStr
        
        articlesCollection.fetch(categories: newCategories, append: false)
    }
    
    private func setupCategories(){
        //  First segue from postal code
        let categories = self.categoriesJson!["items"] as! [[String: Any]]
        
        for item in categories {
            let bgColorHex = item["color"] as! String
            let bgColorInt = UInt(bgColorHex, radix: 16)!
            let bgRGB: [CGFloat] = [
                CGFloat(bgColorInt >> 16 & 0xFF) / 255.0,
                CGFloat(bgColorInt >> 8 & 0xFF) / 255.0,
                CGFloat(bgColorInt & 0xFF) / 255.0
            ]
            let bgColor = UIColor(
                red: bgRGB[0],
                green: bgRGB[1],
                blue: bgRGB[2],
                alpha: 1.0
            )
            
            let isDarkBg = 0.299 * bgRGB[0] + 0.587 * bgRGB[1] + 0.114 * bgRGB[2] < 0.75
            
            self.categoriesDataSource.data.append(
                Category(id: item["id"] as! Int,
                         name: item["name"] as! String,
                         foregroundColor: isDarkBg ? UIColor.white : UIColor.black,
                         backgroundColor: bgColor,
                         background: nil
                )
            )
        }
        
        self.categories.actionBarLogo = self.actionBarLogo
        self.categories.transitionValue = 0
        
        self.categories.dataSource = categoriesDataSource
        self.categories.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public func pickedUpArticleMoved(_ sender: ArticleCellView){
        pickedUpArticleManager?.pickedUpArticleMoved(sender)
    }
    
    public func pickedUpArticleReleased(_ sender: ArticleCellView){
        pickedUpArticleManager?.pickedUpArticleReleased(sender)
    }
    
    public func showArticleInfo(_ article: ArticleData) {
        let dialog = ArticleInfoDialog()
        dialog.setup(for: article)
        dialog.show(parent: self.view)
    }
    
    public func addToCart(_ article: ArticleData) {
        ShoppingCartViewController.addToCart(article)
    }
}

