//
//  GDRegistrationInfo.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Bolts
import Kanna
import UIKit

class GDRegistrationInfo: NSObject {
  
  /// Singleton instance
  static let sharedInstance = GDRegistrationInfo()
  
  private let accountManager = GDAccountManager.sharedInstance
  private let rootURL = "https://my.sa.ucsb.edu/gold/RegistrationInfo.aspx"
  
  var currentQuaterData: NSData?
  // May be the same as the `currentQuarterData`
  var futureQuaterData: NSData?
  
  private let passIDs = [
    1: "#pageContent_PassOneLabel",
    2: "#pageContent_PassTwoLabel",
    3: "#pageContent_PassThreeLabel"
  ]
  
  enum QuarterInfoIdDs {
    static let start = "#pageContent_FirstDayInstructionLabel",
    end = "#pageContent_LastDayInstructionLabel",
    drop = "#pageContent_DropDeadlineLabel"
  }
  
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
  
  func currentQuarter() -> BFTask {
    let newTask = BFTaskCompletionSource()
    prepareData().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        newTask.setError(task.error!)
      }
      else {
        newTask.setResult(self.decorateQuarter(
          withData: self.currentQuaterData!,
          andCSS: GDQuarterManager.currentCSS))
      }
      return nil
    }
    return newTask.task
  }
  
  func futureQuarter() -> BFTask {
    let newTask = BFTaskCompletionSource()
    prepareComprehensiveData().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        newTask.setError(task.error!)
      }
      else {
        newTask.setResult(self.decorateQuarter(
          withData: self.futureQuaterData!,
          andCSS: GDQuarterManager.latestCSS))
      }
      return nil
    }
    return newTask.task
  }
  
  func passTimeOfFutureQuarter(onComplete completeBlock: completeHandler?) {
    prepareComprehensiveData().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        if completeBlock != nil {completeBlock!(nil, task.error)}
      }
      else if self.futureQuaterData != nil {
        if completeBlock != nil {completeBlock!(self.getPassTimeArr(), nil)}
      }
      return nil
    }
  }
  
  func lastDayToDrop(onComplete completeBlock: completeHandler?) {
    prepareData().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        if completeBlock != nil {completeBlock!(nil, task.error)}
      }
      else if self.currentQuaterData != nil {
        if completeBlock != nil {
          completeBlock!(self.parseDateForId(QuarterInfoIdDs.drop, withData: self.currentQuaterData!), nil)
        }
      }
      return nil
    }
  }
  
  // MARK: - Networking request
  
  /**
  Fetches the current quarter data, and store it in
  `currentQuaterData`
  
  - returns: a BFTask
  */
  func prepareData() -> BFTask {
    let task = BFTaskCompletionSource()
    // check if already feched
    if (currentQuaterData != nil) {
      task.setResult(currentQuaterData)
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
      .continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
        // Store html data
        self.currentQuaterData = (task.result as! NSData)
        return task
    }
  }
  
  /**
   If a future quarter is available, fetches the
   future quarter data and update `latestQuarterData`
   
   - returns: a BFTask
   */
  func prepareComprehensiveData() -> BFTask {
    let newTask = BFTaskCompletionSource()
    // check if already feched
    if (futureQuaterData != nil) {
      newTask.setResult(futureQuaterData)
      return newTask.task
    }
    return prepareData()
      .continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
        if GDQuarterManager.isCurentLatest(self.currentQuaterData!) {
          let error = NSError(
            domain: "GoldDigger",
            code: 11,
            userInfo: ["Data not available":"No newer quarter data found"])
          newTask.setError(error)
          return newTask.task
        }
        else {// get the HTML for next quarter
          return self.getFutureQuarterHTML()
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
          // internet connection is not available ??
          task.setError(response.result.error!)
        }
        else if response.response!.URL!.path!.containsString("RegistrationInfo.aspx") {
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
  
  /**
   When there is a future quarter avaialble, get it.
   
   It will automatically call logout on success to clean up GOLD state.
   GOLD stores the state of current viewing quarter. If logout is not
   called, other objects my get wrong default page.
   
   - returns: a BFTask
   */
  func getFutureQuarterHTML() -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.POST, rootURL,
      parameters: GDQuarterManager.assembleRequestData(parameterKeys, htmlData: currentQuaterData!))
      .responseData { response in
        if response.result.isFailure {
          task.setError(response.result.error!)
        }
        else if response.data != nil && GDQuarterManager.isCurentLatest(response.data!) {
          self.futureQuaterData = response.data
          self.accountManager.logout()
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
  
  func getPassTimeArr() -> [NSDate] {
    if passTimeArr.count != 0 {
      return passTimeArr
    }
    for var i = 1; i <= 3; i++ {
      passTimeArr.append(self.parsePassTime(i)!)
    }
    return passTimeArr
  }
  
  func parsePassTime(number: Int) -> NSDate? {
    if let doc = Kanna.HTML(html: futureQuaterData!, encoding: NSUTF8StringEncoding) {
      
      var dateString = doc.at_css(passIDs[number]!)?.text
      dateString = dateString?.componentsSeparatedByString("-")[0].trim()
      
      if dateString != nil {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
        
        return dateFormatter.dateFromString(dateString!)
      }
    }
    return nil
  }
  
  func parseDateForId(id: String, withData data: NSData) -> NSDate? {
    
    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
      let dateString = doc.at_css(id)?.text
      if dateString != nil {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "PST")
        return dateFormatter.dateFromString(dateString!)
      }
    }
    return nil
  }
  
  func decorateQuarter(withData data: NSData, andCSS css: String) -> GDQuarter? {
    let quarter = GDQuarter()
    quarter.start = parseDateForId(QuarterInfoIdDs.start, withData: data)
    quarter.end = parseDateForId(QuarterInfoIdDs.end, withData: data)
    quarter.name = GDQuarterManager.findQuarterName(withHtmlData: data, andCSS: css)
    return quarter
  }
}
