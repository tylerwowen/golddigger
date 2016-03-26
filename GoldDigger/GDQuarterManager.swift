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
  
  static let sharedInstance = GDQuarterManager()

  var currentQuarter: GDQuarter?
  var latestQuarter: GDQuarter?

  let selectedCSS = "#pageContent_quarterDropDown [selected]"
  let latestCSS = "#pageContent_quarterDropDown option:nth-child(2)"
  
  func getCurrentQuarter(onComplete completeBlock: completeHandler?) -> BFTask {
    let newTask = BFTaskCompletionSource()

    if currentQuarter != nil {
      newTask.setResult(currentQuarter)
      return newTask.task
    }
    
    let registrationInfo = GDRegistrationInfo.sharedInstance
    
    return registrationInfo.currentQuarter()
      .continueWithBlock { (task: BFTask!) -> BFTask in
        if task.error != nil {
          if completeBlock != nil {completeBlock!(nil, task.error)}
        }
        else if task.result != nil {
          self.currentQuarter = task.result as? GDQuarter
          if completeBlock != nil {completeBlock!(task.result, nil)}
        }
        return task
    }
  }
  
  // MARK: - Change quarter
  
  func assembleRequestData(parameterKeys: [String], htmlData: NSData, id: String) -> [String: AnyObject] {
    let params = Array(parameterKeys[0..<5])
    var paramDict = GDPrameterParser.extractParameters(params, fromHTML: htmlData)
    assembleQuarterInfo(&paramDict, htmlData: htmlData, id: id)
    return paramDict
  }
  
  private func assembleQuarterInfo(
    inout parameters:[String: AnyObject],
    htmlData: NSData,
    id: String) {
      
      let dropDownName = "ctl00$pageContent$quarterDropDown"
      parameters["__EVENTTARGET"] = dropDownName
      parameters[dropDownName] = id
  }
  
  // MARK: - Utils
  
  func isSelectedLatest(htmlData: NSData) -> Bool {
    let latest = selectedQuarterId(withHtmlData: htmlData)
    let selected = latestQuarterId(withHtmlData: htmlData)
    
    return latest != nil && latest == selected
  }
  
  func selectedQuarterId(withHtmlData data: NSData) -> String? {
    return findQuarterId(withHtmlData: data, andCSS: selectedCSS)
  }
  
  func latestQuarterId(withHtmlData data: NSData) -> String? {
    return findQuarterId(withHtmlData: data, andCSS: latestCSS)
  }
  
  private func findQuarterId(withHtmlData data: NSData, andCSS css: String) -> String? {
    if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
      if let quarter = doc.at_css(css) {
        return quarter["value"]
      }
    }
    return nil
  }

}
