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
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "PST");
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    if let date = dateFormatter.dateFromString(self) {
      let calendar = NSCalendar.currentCalendar()
      return calendar.components([.Hour, .Minute, ], fromDate: date)
    }
    return nil
  }
}

class GDClass: GDSection {
  var grading: String!
  var units: Int!
  
  var enrlCode: String!
  
  var sections = [GDSection]()
  
  func inflate(withXML XML: XMLElement, index: Int) {
    let indexStr = String(index)
    
    let htmlClass = index % 2 == 0 ? " .clcellprimary" : " .clcellprimaryalt"
    let titleId = index % 2 == 0 ? "#pageContent_CourseList_CourseHeadingLabel_" :
    "#pageContent_CourseList_CourseHeadingLabelAlternate_"
    
    courseTitle = XML.at_css(titleId + indexStr)?.text?.trim() ?? ""
    
    let instructorNodes = XML.css("#pageContent_CourseList_InstructorList_" + indexStr + htmlClass)
    let meetingNodes = XML.css("#pageContent_CourseList_MeetingTimesList_" + indexStr + htmlClass)
    
    createSections(instructorNodes, meetingNodes: meetingNodes)
    processInstructorNodes(instructorNodes)
    processMeetingNodes(meetingNodes)
  }
  
  private func createSections(instructorNodes: XMLNodeSet, meetingNodes: XMLNodeSet) {
    let numOfSections = max(meetingNodes.count / 3 - 1, instructorNodes.count - 1)
    sections = [GDSection](count: numOfSections, repeatedValue: GDSection());
  }

  private func processInstructorNodes(nodes: XMLNodeSet) {
    instructor = nodes[0].text?.trim()
    if nodes.count > 1 {
      let end = min(nodes.count - 1, sections.count)
      for i in 0..<end {
      sections[i].instructor = nodes[i+1].text?.trim()
      }
    }
  }
  
  private func processMeetingNodes(nodes: XMLNodeSet) {
    daysStr = nodes[0].text?.trim()
    days = getDays(fromString: daysStr)
    
    if let timeStringArr = nodes[1].text?.componentsSeparatedByString("-") {
      startStr = timeStringArr[0]
      start = startStr?.toNSComponents()
      endStr = timeStringArr[1]
      end = endStr?.toNSComponents()
    }
    location = nodes[2].at_css(".BuildingLocationLink")?.text
    
    if nodes.count % 3 == 0 && nodes.count > 3 {
      for i in 0..<nodes.count/3 - 1 {
        sections[i].courseTitle = "Section - " + courseTitle!
        sections[i].daysStr = nodes[3+i*3].text?.trim()
        sections[i].days = getDays(fromString: sections[i].daysStr)
        
        if let timeStringArr = nodes[4+i*3].text?.componentsSeparatedByString("-") {
          sections[i].startStr = timeStringArr[0]
          sections[i].start = sections[i].startStr?.toNSComponents()
          sections[i].endStr = timeStringArr[1]
          sections[i].end = sections[i].endStr?.toNSComponents()
        }
        
        sections[i].location = nodes[5+i*3].at_css(".BuildingLocationLink")?.text
      }
    }
  }

  private func getDays(fromString str: String?) -> [EKRecurrenceDayOfWeek]? {
    return str == nil ? nil : str!.componentsSeparatedByString(" ").map({ (str) -> EKRecurrenceDayOfWeek in
      return str.toEKWeekday()
    })
  }
}
