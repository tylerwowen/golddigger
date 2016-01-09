//
//  GDClass.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import EventKit
import Kanna
import UIKit

extension String {
  func toEKWeekday() -> EKRecurrenceDayOfWeek {
    switch self {
    case "SUN":
      return EKRecurrenceDayOfWeek(.Sunday)
    case "M":
      return EKRecurrenceDayOfWeek(.Monday)
    case "T":
      return EKRecurrenceDayOfWeek(.Tuesday)
    case "W":
      return EKRecurrenceDayOfWeek(.Wednesday)
    case "R":
      return EKRecurrenceDayOfWeek(.Thursday)
    case "F":
      return  EKRecurrenceDayOfWeek(.Friday)
    default:
      return EKRecurrenceDayOfWeek(.Saturday)
    }
  }
  
  func toNSDate() -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.dateFromString(self)
  }
}

class GDClass: NSObject {
  var grading: String!
  var units: Int!
  
  var courseTitle: String!
  var enrlCode: String!
  var localtion: String!
  var instructor: String!
  
  var days: [EKRecurrenceDayOfWeek]!
  var start: NSDate?
  var end: NSDate?
  
  var isSection = false
  var section: GDClass?
  
  func decorate(withHTML html: String, index: Int) {
    let indexStr = String(index)
    
    let htmlClass = index % 2 == 0 ? " .clcellprimary" : " .clcellprimaryalt"
    let titleId = index % 2 == 0 ? "#pageContent_CourseList_CourseHeadingLabel_" :
    "#pageContent_CourseList_CourseHeadingLabelAlternate_"
    
    let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding)
    if doc != nil {
      courseTitle = doc!.at_css(titleId + indexStr)?.text?.trim()
      
      let instructorNodes = doc!.css("#pageContent_CourseList_InstructorList_" + indexStr + htmlClass)
      instructor = instructorNodes[0].text?.trim()
      
      let meetingNodes = doc!.css("#pageContent_CourseList_MeetingTimesList_" + indexStr + htmlClass)
      
      days = getDays(fromString: (meetingNodes[0].text?.trim()))
      
      let timeStringArr = meetingNodes[1].text?.componentsSeparatedByString("-")
      start = timeStringArr![0].toNSDate()
      end = timeStringArr![1].toNSDate()
      
      print(self)
    }
  }
  
  func getDays(fromString str: String?) -> [EKRecurrenceDayOfWeek]? {
    return str == nil ? nil : str!.componentsSeparatedByString(" ").map({ (str) -> EKRecurrenceDayOfWeek in
      return str.toEKWeekday()
    })
  }

}
