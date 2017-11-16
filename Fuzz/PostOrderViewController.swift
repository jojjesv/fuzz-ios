//
//  PostOrderViewController.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class PostOrderViewController: UIViewController {
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let shoppingCart = sender as? ShoppingCartViewController else {
            //  TODO: handle failure
            return
        }
        
        
    }
}
