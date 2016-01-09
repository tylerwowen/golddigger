//
//  GDSection.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit
import EventKit

class GDBaseClass: NSObject {
  var courseTitle: String!
  var enrlCode: String!
  var localtion: String!
  var instructor: String!

  var days: [EKRecurrenceDayOfWeek]!
  var start: NSDate!
  var end: NSDate!
  
  init(withRawData: String) {
    super.init()
    
  }
}
