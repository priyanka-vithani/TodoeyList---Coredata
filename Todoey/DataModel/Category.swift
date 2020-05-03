//
//  Category.swift
//  Todoey
//
//  Created by Apple on 16/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var colour : String = ""
    let items = List<Item>()
}
