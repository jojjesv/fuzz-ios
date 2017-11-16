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
    
    private var pickedUpArticleManager: PickedUpArticleManager?
    
    @IBAction func showCart(_ sender: Any) {
        performSegue(withIdentifier: "toCart", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articlesCollection.viewController = self
        articlesCollection.pickedUpArticleParent = self.pickedUpParent
        pickedUpArticleManager = PickedUpArticleManager(with: self)
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
    
    public func showArticleInfo(forView view: ArticleCellView) {
        guard let data = view.data else { return }
        
        let dialog = UIAlertController(nibName: "InfoView", bundle: self.nibBundle)
        dialog.title = "Info"
        
        present(dialog, animated: true, completion: nil)
    }
}

