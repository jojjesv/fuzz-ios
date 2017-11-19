//
//  ViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var actionBar: UIView!
    @IBOutlet weak var pickedUpParent: UIView!
    @IBOutlet weak var articlesCollection: ArticlesCollectionView!
    
    @IBOutlet weak var categoriesHeader: UILabel!
    
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
        categories.selectedChanged = refetchFromCategoryChange
        
        setupCategories()
        
        //  Initial fetch
        refetchFromCategoryChange(newCategories: [])
        
        categories.touchDelegate = articlesCollection
        
        toggleCategoriesButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.toggleCategories))
        )
    }
    
    @objc public func toggleCategories(){
        categories.toggleVisibility()
    }
    
    public func refetchFromCategoryChange(newCategories: [Category]){
        //  Categories to string
        var headerStr: String!
        
        if newCategories.count == 0 {
            headerStr = "Populärt denna vecka"
        } else {
            
        }
        
        articlesCollection.fetch(categories: newCategories, append: false)
    }
    
    private func setupCategories(){
        //  First segue from postal code
        let categories = self.categoriesJson!["items"] as! [[String: Any]]
        
        for item in categories {
            let colorHex = item["color"]
            
            self.categoriesDataSource.data.append(
                Category(id: item["id"] as! Int,
                         name: item["name"] as! String,
                         foregroundColor: UIColor.yellow,
                         backgroundColor: UIColor.blue,
                         background: nil
                )
            )
        }
        
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
        let dialog = UIAlertController(nibName: "InfoView", bundle: self.nibBundle)
        dialog.title = "Info"
        
        present(dialog, animated: true, completion: nil)
    }
    
    public func addToCart(_ article: ArticleData) {
        ShoppingCartViewController.addToCart(article)
    }
}

