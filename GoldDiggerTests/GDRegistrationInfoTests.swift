//
//  GDRegistrationInfoTests.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import XCTest

import Alamofire
import Bolts
@testable import GoldDigger

class GDRegistrationInfoTests: XCTestCase {
  var sut = GDRegistrationInfo.sharedInstance
  let accountManager = GDAccountManager.sharedInstance
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    sut.currentQuaterData = nil
    sut.futureQuaterData = nil
    sut.passTimeArr = Array<NSDate>()
    super.tearDown()
  }
  
  // MARK: - Given
  
  func givenPassTimeTestData(number: Int) -> NSData! {
    var testHTMLString = "<span id=\"pageContent_Pass"
    switch number {
    case 1:
      testHTMLString += "One"
    case 2:
      testHTMLString += "Two"
    default:
      testHTMLString += "Three"
    }
    testHTMLString += "Label\">12/18/2015 10:15 AM - 3/11/2016 11:45 PM</span>"
    return testHTMLString.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  func givenUserLoggedIn() -> BFTask {
    return accountManager.login(netID: "ouyang", password: "***REMOVED***", onSuccess: nil, onFailure: nil)
  }
  
  // MARK: - Test cases
  
  func test__passTimeOfLatestQuarter__currentEqualsToLatest_fails__returnsError() {
    let expectation = expectationWithDescription("getThreePassTime")
    
    givenUserLoggedIn().continueWithSuccessBlock { (task) -> AnyObject? in
      self.sut.passTimeOfFutureQuarter() { (data, error) -> Void in
        XCTAssertNotNil(error)
        expectation.fulfill()
      }
      return nil
    }
    waitForExpectationsWithTimeout(3) { error in
      XCTAssertNil(error)
    }
  }
  
  func test__doesItStoreState() {
    let expectation = expectationWithDescription("getThreePassTime")
    
    givenUserLoggedIn().continueWithSuccessBlock { (task) -> AnyObject? in
      return self.sut.getDefaultHTML()
      }.continueWithBlock { (task) -> AnyObject? in
        self.sut.currentQuaterData = task.result as? NSData
        print(self.sut.currentQuaterData?.length)
        print(self.sut.futureQuaterData?.length)
        return self.sut.getFutureQuarterHTML()
      }.continueWithBlock { (task) -> AnyObject? in
        self.sut.futureQuaterData = task.result as? NSData
        print(self.sut.currentQuaterData?.length)
        print(self.sut.futureQuaterData?.length)
        return self.sut.getDefaultHTML()
      }.continueWithBlock { (task) -> AnyObject? in
        self.sut.currentQuaterData = task.result as? NSData
        print(self.sut.currentQuaterData?.length)
        print(self.sut.futureQuaterData?.length)
        XCTAssert(true)
        expectation.fulfill()
        return nil
    }
    
    waitForExpectationsWithTimeout(30) { error in
      XCTAssertNil(error)
    }
  }
  
  // MARK: Networking request
  
  func test__getDefaultHTML__userNotLoggedIn__reportsError() {
    let expectation = expectationWithDescription("downloadRIFPage")
    accountManager.logout()
    self.sut.getDefaultHTML().continueWithBlock { (task) in
      XCTAssertNotNil(task.error)
      expectation.fulfill()
      return nil
    }
    waitForExpectationsWithTimeout(4) { error in
      XCTAssertNil(error)
    }
  }
  
  func test__getDefaultHTML__userLoggedIn__downloadsRIFPage() {
    let expectation = expectationWithDescription("downloadRIFPage")
    givenUserLoggedIn().continueWithSuccessBlock { (task: BFTask) -> AnyObject? in
      self.sut.getDefaultHTML().continueWithBlock { (task) in
        XCTAssertNotNil(task.result)
        expectation.fulfill()
        return nil
      }
    }
    waitForExpectationsWithTimeout(4) { error in
      XCTAssertNil(error)
    }
  }
  
  
  // MARK: Utils Tests
  
  func test__parsePassTime__passtime1() {
    let testHTMLData = givenPassTimeTestData(1)
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "M/d/yyyy h:mm a"
    let expectedDate = formatter.dateFromString("12/18/2015 10:15 AM")
    
    sut.futureQuaterData = testHTMLData
    let date = sut.parsePassTime(1)
    XCTAssertNotNil(date)
    XCTAssertEqual(date, expectedDate)
  }
  
  func test__parsePassTime__passtime2() {
    let testHTMLData = givenPassTimeTestData(2)
    
    sut.futureQuaterData = testHTMLData
    let date = sut.parsePassTime(2)
    XCTAssertNotNil(date)
  }
  
  func test__parsePassTime__passtime3() {
    let testHTMLData = givenPassTimeTestData(3)
    
    sut.futureQuaterData = testHTMLData
    let date = sut.parsePassTime(3)
    XCTAssertNotNil(date)
  }
  
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
