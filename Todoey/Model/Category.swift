//
//  Category.swift
//  
//
//  Created by Nick Giglio on 2/25/19.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
