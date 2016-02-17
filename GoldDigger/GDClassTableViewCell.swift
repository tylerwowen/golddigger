//
//  GDClassTableViewCell.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/24/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import UIKit

class GDClassTableViewCell: UITableViewCell {
  
  @IBOutlet weak var courseTitleLabel: UILabel!
  @IBOutlet weak var instructorLabel: UILabel!
  @IBOutlet weak var daysLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  func bind(with classData: GDSection) {
    courseTitleLabel.text = classData.courseTitle
    instructorLabel.text = classData.instructor
    locationLabel.text = classData.location
    daysLabel.text = classData.daysStr
    if classData.startStr != nil && classData.startStr != nil{
      timeLabel.text = classData.startStr! + " - " + classData.endStr!
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
}
