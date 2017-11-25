//
//  CategoriesDataSource.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-17.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CategoriesDataSource: NSObject, UITableViewDataSource {
    public var data = [Category]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "cell") as! CategoryCell
        let item = data[indexPath.item]
        
        view.data = item
        DispatchQueue.main.async {
            view.container.backgroundColor = item.backgroundColor
        }
        
        view.label.text = item.name
        view.label.textColor = item.foregroundColor
        view.setRemoveIconVisiblity(visible: item.enabled)
        
        return view
    }
}
