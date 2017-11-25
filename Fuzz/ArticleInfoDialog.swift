//
//  ArticleInfoDialog
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-19.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ArticleInfoDialog: Dialog {
    @IBOutlet var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var dialogContent: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override init() {
        super.init()
        
        Bundle.main.loadNibNamed("ArticleInfoDialog", owner: self, options: nil)
    }
    
    override func baseView() -> UIView! {
        return self.view
    }
    
    override func content() -> UIView! {
        return self.dialogContent
    }
    
    public func setup(for article: ArticleData) {
        nameLabel.text = "\(article.name!) \(article.quantity!) st."
        
        Caches.getImage(fromUrl: article.imageUrl!) { (image) in
            self.imageView.image = image
        }
        
        let get = "out=article_info&id=\(article.id!)"
        
        Backend.request(getParams: get, postBody: nil) { (data) in
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            //  TODO: Handle errors
            guard json != nil else { return }
            
            let description = json!!["description"] as? String
            let contents = json!!["contents"] as? String
            
            if description == nil {
                self.descriptionLabel.isHidden = true
            } else {
                self.descriptionLabel.isHidden = false
                self.descriptionLabel.text = description
            }
            
            if contents == nil {
                self.contentsLabel.text = "Har ingen innehållsinformation"
            } else {
                self.contentsLabel.text = "Innehåller \(contents!)"
            }
        }
    }
}
