//
//  CategoriesView.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-16.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CategoriesView: UITableView, UITableViewDelegate {
    
    //  Delegate to manage swiping horizontally to hide categories
    public var touchDelegate: CategoriesTouchDelegate?
    public var selectedChanged: (([Category]) -> ())?
    
    private var _visible = false
    public var visible: Bool {
        get {
            return _visible
        }
    }
    
    private var _selectedCategories = [Category]()
    public var selectedCategories: [Category] {
        get {
            return _selectedCategories
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
    }
    
    private var _transitionValue: CGFloat = 0
    
    public var transitionValue: CGFloat {
        set {
            
            //  clamp and interpolate
            var val = min(max(newValue, 0), 1) - 1
            
            val = 1 - pow((1 - val), 2)
            
            for cell in visibleCells {
                let _cell = cell as! CategoryCell
                _cell.stackView.frame.origin.x = _cell.stackView.frame.width * val
            }
            
            _transitionValue = val + 1
        }
        get {
            return _transitionValue
        }
    }
    
    //  Determines visibility based on transition value.
    public func determineVisibility(){
        showOrHide(show: _transitionValue >= 0.5)
    }
    
    public func showOrHide(show: Bool) {
        self._visible = show
        UIView.animate(withDuration: 0.3, animations: {
            self.transitionValue = show ? 1.0 : 0.0
        }, completion: {
            (finished) in
            
            self.isUserInteractionEnabled = show
        })
    }
    
    @objc public func toggleVisibility(){
        showOrHide(show: !visible)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataSource = self.dataSource as! CategoriesDataSource
        
        let item = dataSource.data[indexPath.item]
        _selectedCategories.append(item)
        
        self.selectedChanged!(selectedCategories)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let dataSource = self.dataSource as! CategoriesDataSource
        
        let item = dataSource.data[indexPath.item]
        for i in 0..<_selectedCategories.count {
            if _selectedCategories[i].id == item.id {
                _selectedCategories.remove(at: i)
                break
            }
        }
        
        self.selectedChanged!(selectedCategories)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchDelegate?.touchesBegan(touches, with: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchDelegate?.touchesMoved(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchDelegate?.touchesEnded(touches, with: event)
    }
}

public protocol CategoriesTouchDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
}
