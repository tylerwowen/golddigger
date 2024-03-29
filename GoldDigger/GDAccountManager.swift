//
//  GDAccountManager.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/29/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import Alamofire
import Bolts
import Kanna
import UIKit

private let requestKeys = [
  "__LASTFOCUS",
  "__VIEWSTATE",
  "__VIEWSTATEGENERATOR",
  "__EVENTTARGET",
  "__EVENTARGUMENT",
  "__EVENTVALIDATION",
  "ctl00$pageContent$userNameText",
  "ctl00$pageContent$passwordText",
  "ctl00$pageContent$loginButton.x",
  "ctl00$pageContent$loginButton.y",
  "ctl00$pageContent$PermPinLogin$userNameText",
  "ctl00$pageContent$PermPinLogin$passwordText",
  "ctl00$pageContent$PermPinLogin$loginButton.x",
  "ctl00$pageContent$PermPinLogin$loginButton.y"]

enum credentialKeys {
  static let netID = "netIDKey", password = "passwordKey"
}

class GDAccountManager: NSObject {
  
  /// Singleton instance
  static let sharedInstance = GDAccountManager()
  
  /// NSUserDefaults reference
  let userCredentials = NSUserDefaults.standardUserDefaults()
  
  let rootURL = "https://my.sa.ucsb.edu/gold/Login.aspx"
  
  /// Indicates if user credentials are valid
  var valid = false
  
  var netID: String? {
    didSet {
      userCredentials.setValue(netID, forKey: credentialKeys.netID)
      userCredentials.synchronize()
    }
  }
  var password: String? {
    didSet {
      userCredentials.setValue(password, forKey: credentialKeys.password)
      userCredentials.synchronize()
    }
  }
  
  private override init() {
    super.init()
    
    if (userCredentials.stringForKey(credentialKeys.netID) == nil) {
      netID = ""
      userCredentials.setValue(netID, forKey: credentialKeys.netID)
    }
    else {
      netID = userCredentials.stringForKey(credentialKeys.netID)
    }
    
    if (userCredentials.stringForKey(credentialKeys.password) == nil) {
      password = ""
      userCredentials.setValue(password, forKey: credentialKeys.password)
    }
    else {
      password = userCredentials.stringForKey(credentialKeys.password)
    }
    
    userCredentials.synchronize()
  }
  
  // MARK: - Log in/out
  
  /**
  Log in to GOLD with provided credentials
  
  - parameter netId:    GOLD NetID
  - parameter password: GOLD Password
  - parameter successBlock: success block
  - parameter failureBlock: failure block, called when log in failed
  */
  func login(netID netID: String, password: String,
    onSuccess successBlock: successBlockNil?,
    onFailure failureBlock: failureHandler?) -> BFTask {
      
      self.netID = netID
      self.password = password
      return login(onSuccess: successBlock, onFailure: failureBlock)
  }
  
  func login(onSuccess successBlock: successBlockNil?, onFailure failureBlock: failureHandler?) -> BFTask {
    var parameters = [String: AnyObject]()
    return downloadLoginPage(rootURL)
      .continueWithSuccessBlock {
        (task: BFTask!) -> BFTask in
        parameters = task.result as! [String: AnyObject]
        return self.loginWithParameters(parameters)
      }
      .continueWithBlock {
        (task: BFTask!) -> AnyObject? in
        if (task.error != nil && task.error?.domain == "GoldDigger") {
          self.appendPermPinParameters(&parameters)
          return self.loginWithParameters(parameters)
        }
        return task
      }
      .continueWithBlock {
        (task: BFTask!) -> AnyObject? in
        if (task.error != nil) {
          if failureBlock != nil {failureBlock!(task.error)}
        }
        else {
          self.valid = true
          if successBlock != nil {successBlock!()}
        }
        return task
    }
  }
  
  func loginWithParameters(parameters: [String: AnyObject]) -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.POST, rootURL, parameters: parameters)
      .responseData { response in
        if response.result.isFailure {
          task.setError(response.result.error!)
        }
        else if response.response!.URL!.path!.containsString("Home.aspx")
          || response.response!.URL!.path!.containsString("AlertMessage.aspx"){
            task.setResult(nil)
        }
        else {
          let error = NSError(
            domain: "GoldDigger",
            code: 1,
            userInfo: ["Login error":"Invalid credential"])
          task.setError(error)
        }
    }
    return task.task
  }
  
  func logout() {
    Alamofire.request(.GET, "https://my.sa.ucsb.edu/gold/Logout.aspx")
  }
  
  // MARK: - Helpers
  
  func downloadLoginPage(url: String) -> BFTask {
    let task = BFTaskCompletionSource()
    Alamofire.request(.GET, url)
      .responseData { response in
        if response.result.isSuccess {
          task.setResult(self.assembleRequestData(response.data!))
        } else {
          let error = NSError(
            domain: "GoldDigger",
            code: 0,
            userInfo: ["Network error":"Failed to download login page"])
          task.setError(error)
        }
    }
    return task.task
  }
  
  func assembleRequestData(html: NSData) -> [String: AnyObject] {
    let parameters = Array(requestKeys[0..<6])
    var paramDict = GDPrameterParser.extractParameters(parameters, fromHTML: html)
    assembleUserInfo(&paramDict)
    return paramDict
  }
  
  func assembleUserInfo(inout parameters:[String: AnyObject]) {
    parameters[requestKeys[6]] = netID
    parameters[requestKeys[7]] = password
    parameters[requestKeys[8]] = 0
    parameters[requestKeys[9]] = 0
    parameters[requestKeys[10]] = netID
    parameters[requestKeys[11]] = password
  }
  
  func appendPermPinParameters(inout parameters:[String: AnyObject]) {
    parameters[requestKeys[12]] = 0
    parameters[requestKeys[13]] = 0
  }
}
