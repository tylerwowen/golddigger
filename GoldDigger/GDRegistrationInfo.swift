//
//  GDRegistrationInfoParser.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Bolts
import Kanna
import UIKit

class GDRegistrationInfoParser: NSObject {
  
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
  
  func getAllPassTime(onComplete completeBlock: completeHandler?) {
    getHTMLOfLatestQuarter().continueWithBlock { (task) -> AnyObject? in
        if task.error != nil {
          if completeBlock != nil {completeBlock!(nil, task.error)}
        }
        else if task.result != nil {
          if completeBlock != nil {completeBlock!(self.getPassTimeArr(), nil)}
        }
        return nil
    }
  }
  
  func getLastDayToDrop(onComplete completeBlock: completeHandler?) {
    getHTMLOfLatestQuarter().continueWithBlock { (task) -> AnyObject? in
      if task.error != nil {
        if completeBlock != nil {completeBlock!(nil, task.error)}
      }
      else if task.result != nil {
        if completeBlock != nil {completeBlock!(self.parseLastDayToDrop(), nil)}
      }
      return nil
    }
  }
  
  // MARK: - Networking request
  
  func getHTMLOfLatestQuarter() -> BFTask {
    let task = BFTaskCompletionSource()
    if (htmlData != nil) {
      task.setResult(htmlData)
      return task.task
    }
    
    return getDefaultHTML().continueWithBlock { (task: BFTask!) -> BFTask in
      if task.error != nil {
        // Log in and retry
        return self.accountManager.login(onSuccess: nil, onFail: nil).continueWithSuccessBlock({ (task: BFTask!) -> BFTask in
          return self.getDefaultHTML()
        })
      }
      return task
      }.continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
        if self.isCurentLatest(task.result as! NSData) {
          self.htmlData = (task.result as! NSData)
          return task
        }
        else {// get the HTML for next quarter
          return self.getHTMLOfNextQuarter()
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
        if response.response!.URL!.path!.containsString("RegistrationInfo.aspx") {
          task.setResult(response.data)
        }
        else {
          let error = NSError(domain: "GoldDigger", code: 2, userInfo: nil)
          task.setError(error)
        }
    }
    return task.task
  }
  
  func getHTMLOfNextQuarter() -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.POST, rootURL, parameters:self.assembleRequestData())
      .responseData { response in
        if response.data != nil && self.isCurentLatest(response.data!) {
          self.htmlData = response.data
          task.setResult(response.data)
        }
        else {
          let error = NSError(domain: "GoldDigger", code: 3, userInfo: nil)
          task.setError(error)
        }
    }
    return task.task
  }
  
  func assembleRequestData() -> [String: AnyObject] {
    let parser = GDPrameterParser()
    let params = Array(parameterKeys[0..<5])
    let paramDict = parser.extractParameters(params, fromHTML: htmlData!)
    return assembleQuarterInfo(paramDict)
  }
  
  func assembleQuarterInfo(var parameters:[String: AnyObject]) -> [String: AnyObject]{
    parameters[parameterKeys[0]] = "ctl00$pageContent$quarterDropDown"
    parameters[parameterKeys[5]] = findLatestQuarter(htmlData!)
    return parameters
  }
  
  // MARK: - Utils
  
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
    if let doc = Kanna.HTML(html: htmlData!, encoding: NSUTF8StringEncoding) {
      
      var dateString = doc.at_css(passIDs[number]!)?.text
      dateString = dateString?.componentsSeparatedByString("-")[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      
      if dateString != nil {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
        
        return dateFormatter.dateFromString(dateString!)
      }
    }
    return nil
  }
  
  func parseLastDayToDrop() -> NSDate? {
    if let doc = Kanna.HTML(html: htmlData!, encoding: NSUTF8StringEncoding) {
      let dateString = doc.at_css(dropDeadLineID)?.text
      if dateString != nil {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        
        return dateFormatter.dateFromString(dateString!)
      }
    }
    return nil
  }
  
  func isCurentLatest(htmlData: NSData) -> Bool {
    let latest = self.findLatestQuarter(htmlData)
    let current = self.findCurrentQuarter(htmlData)
    
    return latest != nil && latest == current
  }
  
  func findLatestQuarter(htmlData: NSData) -> String? {
    if let doc = Kanna.HTML(html: htmlData, encoding: NSUTF8StringEncoding) {
      if let quarter = doc.at_css("#pageContent_quarterDropDown option:nth-child(2)") {
        return quarter["value"]
      }
    }
    return nil
  }
  
  func findCurrentQuarter(htmlData: NSData) -> String? {
    if let doc = Kanna.HTML(html: htmlData, encoding: NSUTF8StringEncoding) {
      if let quarter = doc.at_css("#pageContent_quarterDropDown [selected]") {
        return quarter["value"]
      }
    }
    return nil
  }

}
