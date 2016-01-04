//
//  RegistrationInfoProcessor.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Kanna
import UIKit

class RegistrationInfoProcessor: NSObject {
  
  var helper = GoldLoginHelper.sharedInstance
  var htmlData: NSData?
  let rootURL = "https://my.sa.ucsb.edu/gold/RegistrationInfo.aspx"
  
  let passIDs = [
    1: "#pageContent_PassOneLabel",
    2: "#pageContent_PassTwoLabel",
    3: "#pageContent_PassThreeLabel"
  ]
  
  let parameterKeys = [
    "__EVENTTARGET",
    "__EVENTARGUMENT",
    "__LASTFOCUS",
    "__VIEWSTATE",
    "__VIEWSTATEGENERATOR",
    "ctl00$pageContent$quarterDropDown",
    "ctl00$pageContent$sessionDropDown"
  ]
  
  var passTime1: NSDate?
  var passTime2: NSDate?
  var passTime3: NSDate?
  
  var didTryLogIn = false
  
  func getAllPassTime(onComplete completeBlock: completeHandler?) {
    getHTML { (data, error) -> Void in
      if error == nil {
        if self.isCurentLatest() {
          if completeBlock != nil {completeBlock!(self.getPassTimeArr(), nil)}
        }
        // get the HTML with the lastest info
        else {
          self.getHTMLForLatestQuarter(onComplete: { (data, error) -> Void in
            if error == nil {
              if completeBlock != nil {completeBlock!(self.getPassTimeArr(), nil)}
            }
            else {
              if completeBlock != nil {completeBlock!(nil, error)}
            }
          })
        }
      }
      else {
        if completeBlock != nil {completeBlock!(nil, error)}
      }
    }
  }
  
  func getPassTimeArr() -> [NSDate]{
    var passTimeArr = Array<NSDate>()
    for var i = 1; i <= 3; i++ {
      passTimeArr.append(self.parsePassTime(i)!)
    }
    return passTimeArr
  }
  
  func getHTML(onComplete completeBlock: completeHandler?) {
    
    Alamofire.request(.GET, rootURL)
      .responseData { response in
        if response.response!.URL!.path!.containsString("RegistrationInfo.aspx") {
          self.htmlData = response.data
          if completeBlock != nil {completeBlock!(response.data, nil)}
        }
          
        else {
          if self.didTryLogIn {
            self.didTryLogIn = false
            let error = NSError(domain: "GoldDigger", code: 2, userInfo: nil)
            if completeBlock != nil {completeBlock!(nil, error)}
          }
            // Log in and retry
          else {
            self.didTryLogIn = true
            self.helper.login(onSuccess: { () -> Void in
              self.getHTML(onComplete: completeBlock)
              }, onFail: { (error) -> Void in
                if completeBlock != nil {completeBlock!(nil, error)}
            })
          }
        }
    }
  }
  
  func getHTMLForLatestQuarter(onComplete completeBlock: completeHandler?) {
    let parameters = self.assembleRequestData()
    
    Alamofire.request(.POST, rootURL, parameters:parameters)
      .responseData { response in
        if self.isCurentLatest() {
          self.htmlData = response.data
          if completeBlock != nil {completeBlock!(response.data, nil)}
        }
        else {
          let error = NSError(domain: "GoldDigger", code: 3, userInfo: nil)
          if completeBlock != nil {completeBlock!(nil, error)}
        }
    }
  }
  
  func assembleRequestData() -> [String: AnyObject] {
    let parser = PrameterParser()
    let params = Array(parameterKeys[0..<5])
    let paramDict = parser.extractParameters(params, fromHTML: htmlData!)
    return assembleQuarterInfo(paramDict)
  }
  
  func assembleQuarterInfo(var parameters:[String: AnyObject]) -> [String: AnyObject]{
    parameters[parameterKeys[0]] = "ctl00$pageContent$quarterDropDown"
    parameters[parameterKeys[5]] = findLatestQuarter()
    return parameters
  }

  func isCurentLatest() -> Bool {
    let latest = self.findLatestQuarter()!
    let current = self.findCurrentQuarter()!
    
    return latest.characters.count > 0 && latest == current
  } 
  
  func findLatestQuarter() -> String? {
    if htmlData == nil { return nil}
    if let doc = Kanna.HTML(html: htmlData!, encoding: NSUTF8StringEncoding) {
      return doc.at_css("#pageContent_quarterDropDown option:nth-child(2)")!["value"]
    }
    return nil
  }
  
  func findCurrentQuarter() -> String? {
    if htmlData == nil { return nil}
    if let doc = Kanna.HTML(html: htmlData!, encoding: NSUTF8StringEncoding) {
      return  doc.at_css("#pageContent_quarterDropDown [selected]")!["value"]
    }
    return nil
  }
  
  func parsePassTime(number: Int) -> NSDate? {
    if htmlData == nil { return nil}
    
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
}
