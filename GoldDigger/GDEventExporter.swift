//
//  GDEventExporter.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/24/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit
import EventKit

class GDEventExporter: NSObject {
  
  var classArr:[GDClass]!
  var quarter: GDQuarter!
  var store = EKEventStore()
  let calendar = NSCalendar.currentCalendar()
  
  init(with classArr: [GDClass], quarter: GDQuarter) {
    super.init()
    self.classArr = classArr
    self.quarter = quarter
  }
  
  func checkPermission(onSuccess: () -> Void, onFailure: failureHandler) {
    store.requestAccessToEntityType(EKEntityType.Event) { (granted, error) -> Void in
      if granted {
        onSuccess()
      }
      else {
        let error = NSError(domain: "GoldDigger", code: 4, userInfo: nil)
        onFailure(error)
      }
    }
  }
  
  func foundDuplication() -> Bool {
    
    return false
  }
  
  func removeDuplicates() {
    
  }
  
  func export(onComplete: completeHandler) {
    for (var i = 0; i < classArr.count; i++) {
      let lecture = classArr[i]
      let event = EKEvent(eventStore: self.store)
      let startEnd = startEndDates(lecture)
     
      event.calendar = self.store.defaultCalendarForNewEvents
      event.title = lecture.courseTitle
      event.location = lecture.location
      event.recurrenceRules = [recurrenceRule(lecture.days)]
      event.startDate = startEnd.0
      event.endDate = startEnd.1
      
      do {
        try self.store.saveEvent(event, span: .FutureEvents, commit: true)
      } catch {
        let error = NSError(domain: "GoldDigger", code: 5, userInfo: nil)
        onComplete(nil, error)
      }
    }
    onComplete(nil, nil)
  }
  
  func recurrenceRule(days:[EKRecurrenceDayOfWeek]) -> EKRecurrenceRule {
    return EKRecurrenceRule(
      recurrenceWithFrequency: EKRecurrenceFrequency.Weekly,
      interval: 1,
      daysOfTheWeek: days,
      daysOfTheMonth: nil,
      monthsOfTheYear: nil,
      weeksOfTheYear: nil,
      daysOfTheYear: nil,
      setPositions: nil,
      end: EKRecurrenceEnd(endDate: quarter.end!))
  }
  
  func startEndDates(lecture: GDClass) -> (NSDate, NSDate) {
    let mergedComponents = lecture.start
    mergedComponents.weekday = lecture.days[0].dayOfTheWeek.rawValue
    
    let start = calendar.nextDateAfterDate(quarter.start!,
      matchingComponents: mergedComponents,
      options: .MatchNextTime)!
    let end = calendar.dateBySettingHour(lecture.end.hour, minute: lecture.end.minute, second: 0, ofDate: start, options: .MatchNextTime)!
    
    return (start, end)
  }
  
}
