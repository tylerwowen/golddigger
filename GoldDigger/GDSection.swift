//
//  GDSection.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/24/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit
import EventKit

class GDSection: NSObject {
  var location: String!
  var instructor: String!
  
  var days: [EKRecurrenceDayOfWeek]!
  var daysStr: String!
  var start: NSDateComponents!
  var startStr: String!
  var end: NSDateComponents!
  var endStr: String!
}
