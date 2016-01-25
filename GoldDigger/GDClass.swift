//
//  GDClass.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Kanna
import UIKit
import EventKit

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

  
  func toNSComponents() -> NSDateComponents? {
    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar.currentCalendar()
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "PST");
    let date = dateFormatter.dateFromString(self)
    return calendar.components([.Hour, .Minute, ], fromDate: date!)
  }
}

class GDClass: GDSection {
  var grading: String!
  var units: Int!
  
  var enrlCode: String!
  
  var section: GDSection?
  
  func inflate(withXML XML: XMLElement, index: Int) {
    let indexStr = String(index)
    
    let htmlClass = index % 2 == 0 ? " .clcellprimary" : " .clcellprimaryalt"
    let titleId = index % 2 == 0 ? "#pageContent_CourseList_CourseHeadingLabel_" :
    "#pageContent_CourseList_CourseHeadingLabelAlternate_"
    
    courseTitle = XML.at_css(titleId + indexStr)?.text?.trim()
    
    let instructorNodes = XML.css("#pageContent_CourseList_InstructorList_" + indexStr + htmlClass)
    processInstructorNodes(instructorNodes)
    
    let meetingNodes = XML.css("#pageContent_CourseList_MeetingTimesList_" + indexStr + htmlClass)
    processMeetingNodes(meetingNodes)
  }

  private func processInstructorNodes(nodes: XMLNodeSet) {
    instructor = nodes[0].text?.trim()
    if nodes.count > 1 {
      section = GDSection()
      section!.instructor = nodes[1].text?.trim()
    }
  }
  
  private func processMeetingNodes(nodes: XMLNodeSet) {
    daysStr = nodes[0].text?.trim()
    days = getDays(fromString: daysStr)
    
    let timeStringArr = nodes[1].text?.componentsSeparatedByString("-")
    startStr = timeStringArr![0]
    start = startStr.toNSComponents()
    endStr = timeStringArr![1]
    end = endStr.toNSComponents()
    
    location = nodes[2].at_css(".BuildingLocationLink")?.text!
    
    if nodes.count == 6 {
      section!.courseTitle = "Section-" + courseTitle
      section!.daysStr = nodes[3].text?.trim()
      section!.days = getDays(fromString: section!.daysStr)
      
      let timeStringArr = nodes[4].text?.componentsSeparatedByString("-")
      section!.startStr = timeStringArr![0]
      section!.start = section!.startStr.toNSComponents()
      section!.endStr = timeStringArr![1]
      section!.end = section!.endStr.toNSComponents()
      
      section!.location = nodes[5].at_css(".BuildingLocationLink")?.text!
    }
  }
  
  private func getDays(fromString str: String?) -> [EKRecurrenceDayOfWeek]? {
    return str == nil ? nil : str!.componentsSeparatedByString(" ").map({ (str) -> EKRecurrenceDayOfWeek in
      return str.toEKWeekday()
    })
  }
}
