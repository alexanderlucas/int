//
//  Countdown.swift
//  Tap Clock Thing
//
//  Created by Alex Lucas on 1/26/16.
//  Copyright © 2016 tbd. All rights reserved.
//

import Foundation
import UIKit

class Countdown {
    var startTime: Date
    var endTime: Date
    
    var interval: Double
    var halfInterval:Double

    var displayTime:String
    
    var halfwayPoint:Date
    
    
    var notiTimes = [Date:String]()
    
    init(start:Date, end:Date, int:Double){
        endTime = end
        startTime = start
        
        print(start)
        print(end)
        
        interval = int
        halfInterval = int/2
        
        halfwayPoint = Date(timeInterval: halfInterval, since: startTime)
        
        displayTime = ""
                        
    }
    
    func addFireTime(_ t:String) {
        switch t {
            case "5m":
                notiTimes[Date(timeInterval: interval - 300 - 1, since: startTime)] = "5 Minutes Remaining"
            case "2m":
                notiTimes[Date(timeInterval: interval - 120 - 1, since: startTime)] = "2 Minutes Remaining"
            case "1m":
                notiTimes[Date(timeInterval: interval - 60 - 1, since: startTime)] = "1 Minute Remaining"
            case "30s":
                notiTimes[Date(timeInterval: interval - 30 - 1, since: startTime)] = "30 Seconds Remaining"
            case "Every 1":
                if(interval>60){
                    for i in 1..<Int(interval/60) {
                        notiTimes[Date(timeInterval: Double(60*i) - 1, since: startTime)] = "\(i) Minute(s) Have Passed"
                    }
                }
            case "Every 5":
                print(interval)
                if(interval>300){
                    for i in 1..<Int(interval/300) {
                        print("YOOOOOOOO")
                        print(Double(300*i)-1)
                        notiTimes[Date(timeInterval: Double(300*i) - 1, since: startTime)] = "\(i*5) Minutes Have Passed"
                    }
                }
            case "Quarter":
            for i in 1...3 {
                notiTimes[Date(timeInterval: Double(i)*interval/4 - 1, since: startTime)] = "Quarter \(i)"
            }
            case "Half":
                notiTimes[Date(timeInterval: interval/2 - 1, since: startTime)] = "Half Way There"
            
            default:
                print("no buttons")
        }
        
    }
    
    func removeDuplicatesInArray() {
      //  notiTimes = Array(Set(notiTimes))
    }
    
    func setNotifications() {
        //for every notiTime
        
        //but for now
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        print(notiTimes.count)
        removeDuplicatesInArray()
        
        let keys = Array(notiTimes.keys)
        print(keys)
        print(notiTimes.count)
        
        for i in 0..<notiTimes.count {
            let notification = UILocalNotification()
            notification.alertBody = notiTimes[keys[i]]
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate = keys[i] //  (when notification will be fired)
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.category = "myCategory"
            notification.userInfo = ["startTime" : startTime, "endTime" : endTime, "interval":interval]
            
            UIApplication.shared.scheduleLocalNotification(notification)

        }
//        
//        let notification = UILocalNotification()
//        notification.alertBody = "Half way there" // text that will be displayed in the notification
//        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
//        notification.fireDate = halfwayPoint //  (when notification will be fired)
//        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
//        //notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
//        //notification.category = "TODO_CATEGORY"
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let endNot = UILocalNotification()
        endNot.alertBody = "Timer Done" // text that will be displayed in the notification
        endNot.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        endNot.category = "myCategory"

        let comp = DateComponents()
        (comp as NSDateComponents).setValue(-1, forComponent: NSCalendar.Unit.second);
        let expirationDate = (Calendar.current as NSCalendar).date(byAdding: comp, to: endTime, options: NSCalendar.Options(rawValue: 0))

        endNot.fireDate = expirationDate //  (when notification will be fired)
        endNot.soundName = UILocalNotificationDefaultSoundName // play default sound
        
        //notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
        //notification.category = "TODO_CATEGORY"
        
        UIApplication.shared.scheduleLocalNotification(endNot)

    }
    
   
}
