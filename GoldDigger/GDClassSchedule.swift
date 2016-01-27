
//
//  GDClassScheduleAdapter.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Bolts
import Kanna
import UIKit

class GDClassSchedule: NSObject {
  
  /// Singleton instance
  static let sharedInstance = GDClassSchedule()
  
  private let accountManager = GDAccountManager.sharedInstance
  private let rootURL = "https://my.sa.ucsb.edu/gold/StudentSchedule.aspx"
  var htmlData: NSData?
  
  private let parameterKeys = [
    "__EVENTTARGET",
    "__EVENTARGUMENT",
    "__LASTFOCUS",
    "__VIEWSTATE",
    "__VIEWSTATEGENERATOR",
    "ctl00$pageContent$quarterDropDown",
    "ctl00$pageContent$sessionDropDown"
  ]
  
  var classArr = Array<GDClass>()
  
  func classOfCurrentQuarter(onComplete completeBlock: completeHandler?) -> BFTask {
    return prepareData().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        if completeBlock != nil {completeBlock!(nil, task.error)}
      }
      else if task.result != nil {
        self.htmlData = (task.result as! NSData)
        self.getClassArr()
        if completeBlock != nil {completeBlock!(self.getClassArr(), nil)}
      }
      return task
    }
  }
  
  // MARK: - Networking
  
  func prepareData() -> BFTask {
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
          return self.accountManager.login(onSuccess: nil, onFail: nil)
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
   Get the first(default) page returned from GOLD
   
   - returns: a BFTask
   */
  func getDefaultHTML() -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.GET, rootURL)
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
  
  // MARK: - Parsing
  
  func getClassArr() -> [GDClass] {
    if classArr.count != 0 {
      return classArr
    }
    if let doc = Kanna.HTML(html: htmlData!, encoding: NSUTF8StringEncoding) {
      let nodes = doc.css("#pageContent_CourseList>tr")
      for var i = 1; i < nodes.count; i++ {
        let course = GDClass()
        course.inflate(withXML: nodes[i], index: i-1)
        classArr.append(course)
      }
    }
    return classArr
  }
  
  func numOfClasses() -> Int {
    
    return classArr.count
  }
}
