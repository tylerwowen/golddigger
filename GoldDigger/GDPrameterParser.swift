//
//  GDPrameterParser.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/2/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Kanna
import UIKit

class GDPrameterParser: NSObject {
  
  class func extractParameters(parameters: [String], fromHTML html: NSData) -> [String: AnyObject]{
    if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
      
      var parametersDict = Dictionary<String, AnyObject>()
      for var i = 0; i < parameters.count; i++ {
        let key = parameters[i]
        let value = doc.at_css("#" + key)?["value"]
        parametersDict[key] = value != nil ? value : ""
      }
      return parametersDict
    }
    return ["":""]
  }

}
