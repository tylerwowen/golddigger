//
//  ScheduleTableViewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Bolts
import UIKit

class ScheduleTableViewController: UITableViewController {
  
  let classSchedule = GDClassSchedule.sharedInstance
  let quarterManager = GDQuarterManager.sharedInstance
  var exporter: GDEventExporter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if tableView.numberOfRowsInSection(0) == 0 {
      loadData()
    }
  }
  
  func loadData() {
    quarterManager.getCurrentQuarter(onComplete: nil)
      .continueWithSuccessBlock { (task: BFTask!) -> BFTask in
        return self.classSchedule.classOfCurrentQuarter(onComplete: nil)
      }
      .continueWithBlock { (task: BFTask!) -> AnyObject? in
        if task.error != nil {
          showDefaultAlert("Sorry", message: "Not able to get your schedule. Please check if you are already logged in.", actionTitle: "OK")
        }
        else if task.result != nil {
          self.tableView.reloadData()
        }
        return nil
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return classSchedule.numOfClasses()
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("classCell", forIndexPath: indexPath) as! GDClassTableViewCell
    
    cell.bind(with: classSchedule.getClassArr()[indexPath.row])
    
    return cell
  }
  
  @IBAction func exportToCalendar(sender: UIBarButtonItem) {
    let alerController = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .ActionSheet)
    let addToCalendarAction  = UIAlertAction(title: "Export to Calendar", style: .Default, handler: startExportingEvents)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    
    alerController.addAction(addToCalendarAction)
    alerController.addAction(cancelAction)
    
    self.presentViewController(alerController, animated: true, completion: nil)
  }
  
  func startExportingEvents(action: UIAlertAction) -> Void {

    if classSchedule.numOfClasses() == 0 {
      showDefaultAlert("Sorry",
        message: "You don't have any classes to export yest.",
        actionTitle: "OK")
    }
    else {
      exporter = GDEventExporter(with: classSchedule.getClassArr(), quarter: quarterManager.currentQuarter!)
      
      exporter.checkPermission({ () -> Void in
        if self.exporter.foundDuplication() {
          self.askToOverWrite()
        }
        else {
          self.exporter.export(self.exportResultHandler)
        }
        }, onFailure: { (error) -> Void in
          if error!.code == 4 {
            showDefaultAlert("Sorry", message: "I cannot export without your permission", actionTitle: "OK")
          }
      })
    }
  }
  
  func askToOverWrite() {
    let alerController = UIAlertController(title: "Did you want to overwrite?", message: "You already exported them before!", preferredStyle: .Alert)
    let addToCalendarAction  = UIAlertAction(title: "YES!!", style: .Default, handler: overwrite)
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

    alerController.addAction(addToCalendarAction)
    alerController.addAction(cancelAction)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.presentViewController(alerController, animated: true, completion: nil)
    })
  }
  
  func overwrite(action: UIAlertAction) -> Void {
    exporter.removeDuplicates()
    exporter.export(self.exportResultHandler)
  }
  
  func exportResultHandler(success: AnyObject?, error: NSError?) -> Void {
    if error == nil {
      showDefaultAlert("Success!", message: "Your schedule is added to your calendar", actionTitle: "Nice!")
    }
    else {
      showDefaultAlert("Oops", message: "Something bad happened.", actionTitle: "OK")
    }
  }
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
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
