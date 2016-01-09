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
  let scheduler = NotificationScheduler()
  let userSettings = NSUserDefaults.standardUserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    netIDTextField.text = accountManager.netID
    passwordTextField.text = accountManager.password
    
    restoreSettings()
  }
  
  func restoreSettings() {
    let isNotificationOn = userSettings.valueForKey(SettingsKey.notification) as! Bool
    passNotificationSwitch.setOn(isNotificationOn, animated: false)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  // MARK: - Login
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == netIDTextField {
      passwordTextField.becomeFirstResponder()
    }
    else {
      textField.resignFirstResponder()
      if netIDTextField.text != nil && passwordTextField.text != nil {
        
        accountManager.login(netID: netIDTextField.text!, password: passwordTextField.text!, onSuccess: loginSuccessHandler, onFail: nil)
      }
    }
    return true
  }
  
  func loginSuccessHandler() {
    showDefaultAlert("Congrats!", message: "Login succeeded", actionTitle: "OK")
  }
  
  func showDefaultAlert(title: String, message: String, actionTitle: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let defaultAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(defaultAction)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Settings
  
  @IBAction func passNotificationToggled(sender: UISwitch) {
    if sender.on == true {
      turnOnNotification()
    }
    else {
      turnOffNotification()
    }
  }
  
  func turnOnNotification() {
    let registrationInfo = GDRegistrationInfo.sharedInstance
    registrationInfo.passTimeOfLatestQuarter { (dates, error) -> Void in
      if error == nil {
        self.scheduler.createNotificationFor(dates: dates as! [NSDate])
        self.showDefaultAlert("Congrats", message: "Your pass notification is set", actionTitle: "Good")
        self.updateUserDefaults(true)
      }
      else {
        self.showDefaultAlert("Sorry", message: "Not able to get your pass time", actionTitle: "OK")
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
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
