//
//  common.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import UIKit

extension String {
  func trim() -> String? {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}

typealias successBlock = (AnyObject?) -> Void
typealias successBlockNil = () -> Void
typealias failureHandler = (NSError?) -> Void
typealias completeHandler = (AnyObject?, NSError?) -> Void

func showDefaultAlert(title: String, message: String, actionTitle: String) {
  dispatch_async(dispatch_get_main_queue(), { () -> Void in
    let alert = UIAlertController(title: title,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert)
    let defaultAction = UIAlertAction(title: actionTitle,
      style: UIAlertActionStyle.Default,
      handler: nil)
    alert.addAction(defaultAction)
    
    UIApplication.sharedApplication().keyWindow?.rootViewController?
      .presentViewController(alert, animated: true, completion: nil)
  })
}