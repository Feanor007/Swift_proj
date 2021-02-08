//
//  ChecklistItem.swift
//  Checklist
//
//  Created by 唐泽宇 on 2019/2/12.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import Foundation
import UserNotifications
class ChecklistItem: NSObject, Codable {
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    func toggleChecked(){
        checked = !checked
    }
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = text
            content.sound = UNNotificationSound.default
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            let centre = UNUserNotificationCenter.current()
            centre.add(request)
            print("Scheduled: \(request) for itemID: \(itemID)")
        }
    }
    func removeNotification(){
        let centre = UNUserNotificationCenter.current()
        centre.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
    override init (){
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    deinit{
        removeNotification()
    }
}
