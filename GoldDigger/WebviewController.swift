//
//  WebviewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/29/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit

class WebviewController: UIViewController, UIWebViewDelegate{
  
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  @IBOutlet weak var webView: UIWebView!
  
  var URL: NSURL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let URLReq = NSURLRequest(URL: URL)
    webView.loadRequest(URLReq)
    webView.delegate = self
  }
  
  
  func webViewDidStartLoad(webView: UIWebView) {
    indicator.startAnimating()
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    indicator.stopAnimating()
  }
  
}
