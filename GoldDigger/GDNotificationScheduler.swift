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
  
  func isNotificationScheduled() -> Bool {
    return UIApplication.sharedApplication().scheduledLocalNotifications?.count > 0
  }
  
  func removeScheduledNotification() {
    // WARNING: this may cancel other notification
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
}
