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
    
    //  Image view in action bar to be tinted along transition value change.
    public var actionBarLogo: UIImageView!
    
    private let actionBarLogoTintFinal = UIColor(named: "ActionBarLogoFinal")
    private let backgroundFinal = UIColor(named: "CategoriesBackground")
    
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
            
            
            val = min(max(1 - pow((1 - val), 2), -1.4), 0)
            print("SOMEVAL: \(val)")
            
            for cell in visibleCells {
                let _cell = cell as! CategoryCell
                _cell.container.frame.origin.x = _cell.container.frame.width * val
            }
            
            _transitionValue = val + 1
            
            isHidden = _transitionValue == 0.4
            self.transitionActionBarLogo()
            self.transitionBackground()
        }
        get {
            return _transitionValue
        }
    }
    
    private func transitionActionBarLogo(){
        let logoFinalColor = actionBarLogoTintFinal
        let logoFinalComponents = logoFinalColor?.cgColor.components!
        
        let val = _transitionValue
        
        actionBarLogo.tintColor = UIColor(
            red: 1 - (1 - logoFinalComponents![0]) * val,
            green: 1 - (1 - logoFinalComponents![1]) * val,
            blue: 1 - (1 - logoFinalComponents![2]) * val,
            alpha: 1
        )
    }
    
    private func transitionBackground(){
        let finalColor = backgroundFinal
        
        let val = _transitionValue
        
        print("Val: \(val)")
        
        backgroundColor = finalColor?.withAlphaComponent(val * (finalColor?.cgColor.alpha)!)
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
        
        let cell = cellForRow(at: indexPath) as! CategoryCell
        
        if item.enabled {
            //  Deselect
            for i in 0..<_selectedCategories.count {
                if _selectedCategories[i].id == item.id {
                    _selectedCategories.remove(at: i)
                    break
                }
            }
            
            item.enabled = false
        } else {
            _selectedCategories.append(item)
            item.enabled = true
        }
        
        cell.removeIcon.isHidden = !item.enabled
        
        //reloadRows(at: [indexPath], with: .none)
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
