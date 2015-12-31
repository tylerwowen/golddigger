//
//  SettingViewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/29/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var netIDTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  let loginHelper = GoldLoginHelper.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    netIDTextField.text = loginHelper.netID
    passwordTextField.text = loginHelper.password
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == netIDTextField {
      passwordTextField.becomeFirstResponder()
    }
    else {
      textField.resignFirstResponder()
      if netIDTextField.text != nil && passwordTextField.text != nil {
        
        loginHelper.login(netID: netIDTextField.text!, password: passwordTextField.text!, onSuccess: loginSuccessHandler, onFail: nil)
      }
    }
    return true
  }
  
  func loginSuccessHandler() {
    let alert = UIAlertController(title: "Congrats!", message: "Login succeeded", preferredStyle: UIAlertControllerStyle.Alert)
    let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
    alert.addAction(defaultAction)
    self.presentViewController(alert, animated: true, completion: nil)
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
