//
//  GDQuarterManager.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Bolts
import Kanna
import UIKit

class GDQuarterManager: NSObject {
  
  var currentQuarter: GDQuarter?
  var latestQuarter: GDQuarter?
  
  static let currentCSS = "#pageContent_quarterDropDown [selected]"
  static let latestCSS = "#pageContent_quarterDropDown option:nth-child(2)"
  
  func fetchCurrentQuarter(onComplete completeBlock: completeHandler?) {
    let registrationInfo = GDRegistrationInfo.sharedInstance
    registrationInfo.currentQuarter().continueWithBlock { (task: BFTask!) -> AnyObject? in
      if task.error != nil {
        if completeBlock != nil {completeBlock!(nil, task.error)}
      }
      else if task.result != nil {
        if completeBlock != nil {completeBlock!(task.result, nil)}
      }
      return nil
    }
  }
  
  // MARK: - Class methods
  
  class func assembleRequestData(parameterKeys: [String], htmlData: NSData) -> [String: AnyObject] {
    let params = Array(parameterKeys[0..<5])
    let paramDict = GDPrameterParser.extractParameters(params, fromHTML: htmlData)
    return assembleQuarterInfo(paramDict, htmlData: htmlData)
  }
  
  class func assembleQuarterInfo(var parameters:[String: AnyObject], htmlData: NSData) -> [String: AnyObject]{
    let dropDownName = "ctl00$pageContent$quarterDropDown"
    parameters["__EVENTTARGET"] = dropDownName
    parameters[dropDownName] = findLatestQuarterId(htmlData)
    return parameters
  }
  
  class func isCurentLatest(htmlData: NSData) -> Bool {
    let latest = findLatestQuarterId(htmlData)
    let current = findCurrentQuarterId(htmlData)
    
    return latest != nil && latest == current
  }
  
  class func findQuarterId(withHtmlData data: NSData, andCSS css: String) -> String? {
    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
      if let quarter = doc.at_css(css) {
        return quarter["value"]
      }
    }
    return nil
  }
  
  class func findQuarterName(withHtmlData data: NSData, andCSS css: String) -> String? {
    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
      if let quarter = doc.at_css(css) {
        return quarter.text
      }
    }
    return nil
  }
  
  class func findLatestQuarterId(htmlData: NSData) -> String? {
    return findQuarterId(withHtmlData: htmlData, andCSS: latestCSS)
  }
  
  class func findCurrentQuarterId(htmlData: NSData) -> String? {
    return findQuarterId(withHtmlData: htmlData, andCSS: currentCSS)
  }
}
