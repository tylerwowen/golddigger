//
//  GDQuarterMangerTests.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/8/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import XCTest
@testable import GoldDigger

class GDQuarterMangerTests: XCTestCase {
  
  typealias sutClass = GDQuarterManager
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - Given
  func givenQuarterSelectionTestData() -> NSData! {
    let testHTMLString = "<select name='ctl00$pageContent$quarterDropDown' id='pageContent_quarterDropDown' class='titledropdown'><option value=''>-Select-</option><option value='20161'>Winter 2016</option><option selected='selected' value='20154'>Fall 2015</option></select>"
    return testHTMLString.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  func givenBadQuarterSelectionTestData() -> NSData! {
    let testHTMLString = "<select name='ctl00$pageContent$quarterDropDown' id='pageContent_quarterDropDown' class='titledropdown'></select>"
    return testHTMLString.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  // MARK: - Tests
  
  func test__findLatestQuarter__validHTML__returnsQuarter() {
    let testHTMLData = givenQuarterSelectionTestData()
    
    let quarter = sutClass.findLatestQuarterId(testHTMLData)
    XCTAssertEqual(quarter, "20161")
  }
  
  func test__findLatestQuarter__invalidHTML__returnsNil() {
    let testHTMLData = givenBadQuarterSelectionTestData()
    
    let quarter = sutClass.findLatestQuarterId(testHTMLData)
    XCTAssertNil(quarter)
  }
  
  func test__findCurrentQuarter__validHTML__returnsQuarter() {
    let testHTMLData = givenQuarterSelectionTestData()
    
    let quarter = sutClass.findCurrentQuarterId(testHTMLData)
    XCTAssertEqual(quarter, "20154")
  }
  
  func test__findCurrentQuarter__invalidHTML__returnsNil() {
    let testHTMLData = givenBadQuarterSelectionTestData()
    
    let quarter = sutClass.findCurrentQuarterId(testHTMLData)
    XCTAssertNil(quarter)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
