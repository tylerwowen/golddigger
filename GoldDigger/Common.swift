//
//  common.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import Foundation

extension String {
  func trim() -> String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}

typealias SuccessBlock = (AnyObject?) -> Void
typealias SuccessBlockNil = () -> Void
typealias failureHandler = (NSError?) -> Void
typealias completeHandler = (AnyObject?, NSError?) -> Void