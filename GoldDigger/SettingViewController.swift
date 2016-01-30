//
//  SettingViewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/29/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import UIKit

enum SettingsKey {
  static let notification = "locNotiKey", autoRegistration = "autoRegKey"
}


class SettingViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var netIDTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passNotificationSwitch: UISwitch!
  
  let accountManager = GDAccountManager.sharedInstance
  let scheduler = GDNotificationScheduler()
  let userSettings = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    netIDTextField.text = accountManager.netID
    passwordTextField.text = accountManager.password
    restoreSettings()
  }
  
  func restoreSettings() {
//    let isNotificationOn = userSettings.valueForKey(SettingsKey.notification) as? Bool
//    if isNotificationOn != nil {
//      passNotificationSwitch.setOn(isNotificationOn!, animated: false)
//    }
    // TODO: make it persistant
    passNotificationSwitch.setOn(scheduler.isNotificationScheduled(), animated: false)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2;
    case 1:
      return 1;
    case 2:
      return 2;
    default:
      return 1;
    }
  }
  
  // MARK: - Login
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == netIDTextField {
      passwordTextField.becomeFirstResponder()
    }
    else {
      textField.resignFirstResponder()
      if netIDTextField.text != nil && passwordTextField.text != nil {
        
        accountManager.login(netID: netIDTextField.text!, password: passwordTextField.text!, onSuccess: loginSuccessHandler, onFailure: loginFailureHandler)
      }
    }
    return true
  }
  
  func loginSuccessHandler() {
    showDefaultAlert("Login succeeded", message: "You can start digging now", actionTitle: "Cool")
  }
  
  func loginFailureHandler(error: NSError?) {
    print(error)
    showDefaultAlert("Login failed", message: "Please check your Net ID and password.", actionTitle: "OK")
  }
  
  // MARK: - Settings
  
  @IBAction func passNotificationToggled(sender: UISwitch) {
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    
    let granted = UIApplication.sharedApplication().currentUserNotificationSettings()
    if granted!.types == .None {
      sender.on = false;
    }
    else {
      sender.on ? turnOnNotification() : turnOffNotification()
    }
  }
  
  func turnOnNotification() {
    let registrationInfo = GDRegistrationInfo.sharedInstance
    registrationInfo.passTimeOfFutureQuarter { (dates, error) -> Void in
      if error == nil {
        self.scheduler.createNotificationFor(dates: dates as! [NSDate])
        showDefaultAlert("Your pass notifications are set", message: "You will receive a notification when your pass time arrives", actionTitle: "Good")
        self.updateUserDefaults(true)
      }
      else {
        showDefaultAlert("Sorry, cannot get your pass time", message: "There isn't any future pass time available", actionTitle: "OK")
        self.passNotificationSwitch.setOn(false, animated: true)
      }
    }
  }
  
  func turnOffNotification() {
    scheduler.removeScheduledNotification()
    updateUserDefaults(false)
  }
  
  func updateUserDefaults(isNotificationOn: Bool) {
    userSettings.setBool(isNotificationOn, forKey: SettingsKey.notification)
    userSettings.synchronize()
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "voteSegue" {
      let controller = segue.destinationViewController as! WebviewController
      controller.URL = NSURL(string: "https://docs.google.com/forms/d/1FMzHHYGIMv9aj7naNhJIWBOKn7kXGdcjfgXuFMQ2Fb4/viewform")
    }
    else {
      let controller = segue.destinationViewController as! WebviewController
      controller.URL = NSURL(string: "https://tylerwowen.github.io/golddigger/")
    }
  }
  
  
}
