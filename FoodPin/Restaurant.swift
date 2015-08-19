//
//  Restaurant.swift
//  FoodPin
//
//  Created by 从今以后 on 15/8/17.
//  Copyright (c) 2015年 从今以后. All rights reserved.
//

import Foundation
import CoreData

/* FIXME:
class Restaurant: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var location: String
    @NSManaged var type: String
    @NSManaged var isVisited: NSNumber
    @NSManaged var image: NSData
    @NSManaged var thumbnail: NSData
} */

class Restaurant {

    var name: String
    var location: String
    var type: String
    var isVisited: Bool
    var image: String
    var thumbnail: String

    init(name: String, type: String, location: String, image: String, thumbnail: String, isVisited: Bool) {
        
        self.name      = name
        self.location  = location
        self.type      = type
        self.isVisited = isVisited
        self.image     = image
        self.thumbnail = thumbnail
    }
}