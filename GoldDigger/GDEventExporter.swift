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
  let notes = "CreatedByGoldDigger@tylero"
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
    let predicate = store.predicateForEventsWithStartDate(quarter.start!, endDate: quarter.end!, calendars: [store.defaultCalendarForNewEvents])
    let events = store.eventsMatchingPredicate(predicate)
    for event in events {
      if event.notes == notes {
        return true;
      }
    }
    return false
  }
  
  func removeDuplicates() {
    let predicate = store.predicateForEventsWithStartDate(quarter.start!, endDate: quarter.end!, calendars: [store.defaultCalendarForNewEvents])
    let events = store.eventsMatchingPredicate(predicate)
    do {
      for event in events {
        if event.notes == notes {
          try store.removeEvent(event, span: .ThisEvent)
        }
      }
      try store.commit()
    } catch {
      
    }
  }
  
  func export(onComplete: completeHandler) {
    do {
      for (var i = 0; i < classArr.count; i++) {
        
        let lecture = assembleEvent(forMeeting: classArr[i])
        try store.saveEvent(lecture, span: .FutureEvents)
        if classArr[i].section != nil {
          let section = assembleEvent(forMeeting: classArr[i].section!)
          try store.saveEvent(section, span: .FutureEvents)
        }
      }
      try store.commit()
    } catch {
      let error = NSError(domain: "GoldDigger", code: 5, userInfo: nil)
      onComplete(nil, error)
    }
    onComplete(nil, nil)
  }
  
  func assembleEvent(forMeeting meeting: GDSection) -> EKEvent{
    let event = EKEvent(eventStore: store)
    let startEnd = startEndDates(meeting)
    
    event.calendar = store.defaultCalendarForNewEvents
    event.title = meeting.courseTitle
    event.location = meeting.location
    event.recurrenceRules = [recurrenceRule(meeting.days)]
    event.startDate = startEnd.0
    event.endDate = startEnd.1
    event.notes = notes
    
    return event
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
  
  func startEndDates(meeting: GDSection) -> (NSDate, NSDate) {
    let mergedComponents = meeting.start
    mergedComponents.weekday = meeting.days[0].dayOfTheWeek.rawValue
    
    let start = calendar.nextDateAfterDate(quarter.start!,
      matchingComponents: mergedComponents,
      options: .MatchNextTime)!
    let end = calendar.dateBySettingHour(meeting.end.hour, minute: meeting.end.minute, second: 0, ofDate: start, options: .MatchNextTime)!
    
    return (start, end)
  }
  
}
