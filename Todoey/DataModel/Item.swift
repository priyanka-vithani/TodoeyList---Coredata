//
//  Item.swift
//  Todoey
//
//  Created by Apple on 16/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object{
    @objc dynamic var Rtitle: String = ""
    @objc dynamic var Rdone: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
