//
//  Restaurant.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/15.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import Foundation

class Restaurant {

    var name: String
    var type: String
    var location: String
    var image: String
    var isVisited: Bool  

    init(name: String, type: String, location: String, image: String, isVisited: Bool) {
        self.name      = name
        self.type      = type
        self.location  = location
        self.image     = image
        self.isVisited = isVisited
    }
}