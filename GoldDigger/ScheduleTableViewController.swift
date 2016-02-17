//
//  ScheduleTableViewController.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import Bolts
import UIKit

class ScheduleTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GDTaskDelegate {
  
  let classSchedule = GDClassSchedule.sharedInstance
  let quarterManager = GDQuarterManager.sharedInstance
  var exporter: GDEventExporter!
  
  var loadingView: UIView!
  @IBOutlet var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createLoadingView()
    loadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if tableView.numberOfRowsInSection(0) == 0 {
      loadData()
    }
  }
  
  func loadData() {
    showIndicator()
    classSchedule.classOfCurrentQuarter(onComplete: nil)
      .continueWithBlock { (task: BFTask!) -> AnyObject? in
        if task.error != nil {
          showDefaultAlert("Sorry", message: "Not able to get your schedule. Please check if you are already logged in.", actionTitle: "OK")
        }
        else if task.result != nil {
          self.tableView.reloadData()
        }
        self.hideIndicator()
        return nil
    }
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return classSchedule.numOfClasses()
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("classCell", forIndexPath: indexPath) as! GDClassTableViewCell
    
    cell.bind(with: classSchedule.getClassArr()[indexPath.row])
    
    return cell
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  // MARK: - Export class
  
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
      exporter = GDEventExporter()
      exporter.delegate = self
      exporter.checkPermission({ () -> Void in
        self.showIndicator()
        self.exporter.prepareData()
          .continueWithBlock { (task: BFTask!) -> AnyObject? in
            if self.exporter.foundDuplication() {
              self.askToOverWrite()
            }
            else {
              self.exporter.export()
            }
            return nil
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
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Cancel){
        (action) -> Void in
        self.hideIndicator()
    }

    alerController.addAction(addToCalendarAction)
    alerController.addAction(cancelAction)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.presentViewController(alerController, animated: true, completion: nil)
    })
  }
  
  func overwrite(action: UIAlertAction) -> Void {
    exporter.removeDuplicates()
    exporter.export()
  }
  
  func showIndicator() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.loadingView.hidden = false
    })
  }
  
  func hideIndicator() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.loadingView.hidden = true
    })
  }
  
  func createLoadingView() {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    loadingView = UIView(frame: view.frame)
    loadingView.backgroundColor = UIColor.blackColor()
    loadingView.alpha = 0.4
    loadingView.center = view.center
    spinner.center = loadingView.center
    loadingView.addSubview(spinner)
    view.addSubview(loadingView)
    spinner.startAnimating()
  }
  
  func didFinishTask() -> Void {
    showDefaultAlert("Success!", message: "Your schedule is added to your calendar", actionTitle: "Nice!")
    hideIndicator()
  }
  
  func didFailTask(error: NSError) -> Void {
    showDefaultAlert("Oops", message: "Something bad happened.", actionTitle: "OK")
    hideIndicator()
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
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let controller = segue.destinationViewController as! ClassDetailViewController
    let index = tableView.indexPathForSelectedRow?.row
    controller.presentedClass = classSchedule.getClassArr()[index!]
  }
  
}
