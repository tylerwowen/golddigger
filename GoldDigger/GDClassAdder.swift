//
//  GDClassAdder.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/25/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Bolts
import Kanna
import UIKit

class GDClassAdder: NSObject {

  /// Singleton instance
  static let sharedInstance = GDClassAdder()
  
  private let accountManager = GDAccountManager.sharedInstance
  private let rootURL = "https://my.sa.ucsb.edu/gold/AddStudentSchedule.aspx"
  private let scheduleURL = "https://my.sa.ucsb.edu/gold/StudentSchedule.aspx"
  var htmlData: NSData?
  
  private let parameterKeys = [
    "__EVENTTARGET",
    "__EVENTARGUMENT",
    "__LASTFOCUS",
    "__VIEWSTATE",
    "__VIEWSTATEGENERATOR",
    "ctl00$pageContent$quarterDropDown",
    "ctl00$pageContent$EnrollCodeTextBox",
    "ctl00$pageContent$AddCourseButton.x",
    "ctl00$pageContent$AddCourseButton.y"
  ]
  
  // MARK: - Networking
  
  func getHTML() -> BFTask {
    let task = BFTaskCompletionSource()
    // check if already feched
    if (htmlData != nil) {
      task.setResult(htmlData)
      return task.task
    }
    
    return getDefaultHTML()
      .continueWithBlock { (task: BFTask!) -> BFTask in
        if task.error != nil {
          // Log in and retry
          return self.accountManager.login(onSuccess: nil, onFailure: nil)
            .continueWithSuccessBlock({ (task: BFTask!) -> BFTask in
              return self.getDefaultHTML()
            })
        }
        else {
          return task
        }
    }
  }
  
  /**
   Get the latest schedule page from GOLD
   
   - returns: a BFTask
   */
  func getDefaultHTML() -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.GET, scheduleURL)
      .responseData { response in
        if response.result.isFailure {
          task.setError(response.result.error!)
        }
        else if response.response!.URL!.path!.containsString("StudentSchedule.aspx") {
          task.setResult(response.data)
        }
        else {
          let error = NSError(
            domain: "GoldDigger",
            code: 10,
            userInfo: ["Data not available":"Not logged in"])
          task.setError(error)
        }
    }
    return task.task
  }

}
