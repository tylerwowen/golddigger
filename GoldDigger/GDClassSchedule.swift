
//
//  GDClassScheduleAdapter.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit

class GDClassSchedule: NSObject {
  
  private var accountManager = GDAccountManager.sharedInstance
  private let rootURL = "https://my.sa.ucsb.edu/gold/RegistrationInfo.aspx"
  var htmlData: NSData?
  
  private let passIDs = [
    1: "#pageContent_PassOneLabel",
    2: "#pageContent_PassTwoLabel",
    3: "#pageContent_PassThreeLabel"
  ]
  
  private let dropDeadLineID = "pageContent_DropDeadlineLabel"
  
  private let parameterKeys = [
    "__EVENTTARGET",
    "__EVENTARGUMENT",
    "__LASTFOCUS",
    "__VIEWSTATE",
    "__VIEWSTATEGENERATOR",
    "ctl00$pageContent$quarterDropDown",
    "ctl00$pageContent$sessionDropDown"
  ]
  
  var passTimeArr = Array<NSDate>()
}
