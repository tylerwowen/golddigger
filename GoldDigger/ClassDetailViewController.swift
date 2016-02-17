//
//  ClassDetailViewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/25/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController {
  
  var presentedClass: GDClass!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1 + presentedClass.sections.count
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("classCell", forIndexPath: indexPath) as! GDClassTableViewCell
    
    if indexPath.row == 0 {
      cell.bind(with: presentedClass)
    }
    else {
      cell.bind(with: presentedClass.sections[indexPath.row-1])
      cell.courseTitleLabel.textColor = UIColor.greenColor()
    }
    return cell
  }

  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
