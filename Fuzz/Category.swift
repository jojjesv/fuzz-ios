//
//  Category.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-17.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

//  Category data
public class Category {
    public var id: Int
    public var name: String
    public var foregroundColor: UIColor
    public var backgroundColor: UIColor
    public var background: UIImage?
    public var enabled = true
    
    init(id: Int, name: String, foregroundColor: UIColor, backgroundColor: UIColor, background: UIImage?) {
        self.id = id
        self.name = name
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.background = background
    }
}
