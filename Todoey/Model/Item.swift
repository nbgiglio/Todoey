//
//  Data.swift
//  Todoey
//
//  Created by Nick Giglio on 2/25/19.
//  Copyright © 2019 Nick Giglio. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
