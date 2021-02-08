//
//  DataModel.swift
//  Checklist
//
//  Created by 唐泽宇 on 2019/2/19.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import Foundation
class DataModel {
    var lists = [Checklist]()
    var indexOfSelectedChecklist: Int {
        // Use of computed property
        get{
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize()
        }
    }
    init () {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    func documentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklist.plist")
    }
    func saveChecklists(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(lists)
            try data.write(to:dataFilePath(), options:Data.WritingOptions.atomic)
        }catch{
            print("Error encoding list array: \(error.localizedDescription)")
        }
    }
    func loadChecklists(){
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path){
            let decoder = PropertyListDecoder()
            do{
                lists = try decoder.decode([Checklist].self, from: data)
                sortChecklists()
            }catch{
                print("Error decoding list array: \(error.localizedDescription)")
            }
        }
    }
    func registerDefaults(){
        let dictionary = ["ChecklistIndex": -1, "FirstTime": true] as [String: Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    func handleFirstTime() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime == true {
            let checklist = Checklist(name: "Lists")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    func sortChecklists() {
        lists.sort(by: {list1, list2 in return list1.name.localizedStandardCompare(list2.name) == .orderedAscending})
    }
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
}


