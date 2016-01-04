//
//  GoldLoginHelper.swift
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
  "__LASTFOCUS", "__VIEWSTATE", "__VIEWSTATEGENERATOR", "__EVENTTARGET", "__EVENTARGUMENT",
  "__EVENTVALIDATION", "ctl00$pageContent$userNameText", "ctl00$pageContent$passwordText",
  "ctl00$pageContent$loginButton.x", "ctl00$pageContent$loginButton.y",
  "ctl00$pageContent$PermPinLogin$userNameText", "ctl00$pageContent$PermPinLogin$passwordText"]

enum credentialKeys {
  static let netID = "netIDKey", password = "passwordKey"
}

class GoldLoginHelper: NSObject {
  
  /// Singleton instance
  static let sharedInstance = GoldLoginHelper()
  
  /// NSUserDefaults reference
  let userCredentials = NSUserDefaults.standardUserDefaults()
  
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
  
   /**
   Log in to GOLD with provided credentials
   
   - parameter netId:    GOLD NetID
   - parameter password: GOLD Password
   - parameter successBlock: success block
   - parameter failureBlock: failure block, called when log in failed
   */
  func login(netID netID: String, password: String,
    onSuccess successBlock: successHandler?,
    onFail failureBlock: failureHandler?) {
      
    self.netID = netID
    self.password = password
    login(onSuccess: successBlock, onFail: failureBlock)
  }
  
  func login(onSuccess successBlock: successHandler?, onFail failureBlock: failureHandler?) {
    
    let url = "https://my.sa.ucsb.edu/gold/Login.aspx"
    Alamofire.request(.GET, url)
      .responseData { response in
        
        if response.result.isSuccess {
          let parameters = self.assembleRequestData(response.data!)
          
          Alamofire.request(.POST, url, parameters:parameters)
            .responseData { response in
              
              if response.response!.URL!.path!.containsString("Home.aspx") {
                self.valid = true
                if successBlock != nil {successBlock!()}
              }
              else if response.result.isSuccess {
                let error = NSError(domain: "GoldDigger", code: 1, userInfo: nil)
                if failureBlock != nil {failureBlock!(error)}
                self.valid = false
              }
              else {
                if failureBlock != nil {failureBlock!(response.result.error)}
              }
          }
        }
    }
  }
  
  func assembleRequestData(html: NSData) -> [String: AnyObject]{
    let parser = PrameterParser()
    let parameters = Array(requestKeys[0..<6])
    let paramDict = parser.extractParameters(parameters, fromHTML: html)
    return assembleUserInfo(paramDict)
  }
  
  func assembleUserInfo(var parameters:[String: AnyObject]) -> [String: AnyObject]{
    parameters[requestKeys[6]] = netID
    parameters[requestKeys[7]] = password
    parameters[requestKeys[8]] = 87
    parameters[requestKeys[9]] = 5
    parameters[requestKeys[10]] = ""
    parameters[requestKeys[11]] = ""
    return parameters
  }
}
