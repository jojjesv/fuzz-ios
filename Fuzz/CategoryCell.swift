//
//  CategoryCell.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-17.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class CategoryCell: UITableViewCell {
    public var data: Category!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var removeIcon: UIImageView!
    
    private var widthConstraint: NSLayoutConstraint!
    
    public func setRemoveIconVisiblity(visible: Bool) {
        removeIcon.isHidden = !visible
        
        if widthConstraint == nil {
            for constraint in container.constraints {
                if constraint.identifier == "width" {
                    widthConstraint = constraint
                    break
                }
            }
        }
        widthConstraint.constant = -24 - (visible ? 24 + 8 : 0)
        container.setNeedsUpdateConstraints()
    }
    
}
