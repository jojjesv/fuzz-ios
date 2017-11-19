//
//  ArticleData.swift
//  Fuzz
//
//  Created by Johan Svensson on 2017-11-15.
//  Copyright © 2017 Fuzz. All rights reserved.
//

import Foundation
import UIKit

public class ArticleData {
    public var id: Int?
    public var quantity: Int?
    public var cost: Double?
    public var name: String?
    public var isNew: Bool?
    public var image: UIImage?
    public var fetchingImage = false
    public var imageUrl: String?
}
