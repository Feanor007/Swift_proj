//
//  Checklist.swift
//  Checklist
//
//  Created by 唐泽宇 on 2019/2/17.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import UIKit

class Checklist: NSObject,Codable {
    var name = ""
    var iconName = "No Icon"
    var items = [ChecklistItem]()
    var lists = [ChecklistItem]()
    init(name:String, iconName: String = "No Icon"){
        self.name = name
        self.iconName = iconName
        super.init()
    }
    /*func countUncheckedItems() -> Int {
        var count = 0
        for item in items where !item.checked {
            count += 1
        }
        return count
    }*/
    func countUncheckedItems() -> Int {
        return items.reduce(0) {cnt, item in cnt + (item.checked ? 0 : 1)}
    }
}
