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
  
  @IBOutlet weak var lecTitleLabel: UILabel!
  @IBOutlet weak var lecInstructorLabel: UILabel!
  @IBOutlet weak var lecDaysLabel: UILabel!
  @IBOutlet weak var lecLocationLabel: UILabel!
  @IBOutlet weak var lecTimeLabel: UILabel!
  
  @IBOutlet weak var secInstructorLabel: UILabel!
  @IBOutlet weak var secLocationLabel: UILabel!
  @IBOutlet weak var secDaysLabel: UILabel!
  @IBOutlet weak var secTimeLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bind()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func bind() {
    lecTitleLabel.text = presentedClass.courseTitle
    lecInstructorLabel.text = presentedClass.instructor
    lecDaysLabel.text = presentedClass.daysStr
    lecLocationLabel.text = presentedClass.location
    lecTimeLabel.text = presentedClass.startStr + " - " + presentedClass.endStr
    
    if presentedClass.section != nil {
      secInstructorLabel.text = presentedClass.section!.instructor
      secLocationLabel.text = presentedClass.section!.location
      secDaysLabel.text = presentedClass.section!.daysStr
      secTimeLabel.text = presentedClass.section!.startStr + " - " + presentedClass.section!.endStr
    }
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
