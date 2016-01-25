//
//  GDNotificationScheduler.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/2/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit

class GDNotificationScheduler: NSObject {
  
  func createNotificationFor(date date: NSDate) {
    let notification = UILocalNotification()
    notification.fireDate = date
    notification.alertBody = "Pass time is now"
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }
  
  func createNotificationFor(dates dates: [NSDate]) {
    for date in dates {
      createNotificationFor(date: date)
    }
  }
  
  func removeScheduledNotification() {
    // WARNING: this may calcel other notification
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
}
