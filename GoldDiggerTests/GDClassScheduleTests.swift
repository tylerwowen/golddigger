//
//  GDClassScheduleTests.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 1/10/16.
//  Copyright © 2016 Tyler Ouyang. All rights reserved.
//

import XCTest

import Bolts
@testable import GoldDigger

class GDClassScheduleTests: XCTestCase {
  
  let sut = GDClassSchedule.sharedInstance
  let accountManager = GDAccountManager.sharedInstance

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - Given
  func givenUserLoggedIn() -> BFTask {
    return accountManager.login(netID: "ouyang", password: "***REMOVED***", onSuccess: nil, onFailure: nil)
  }
  
  // MARK: - Tests
  
  func test__classOfCurrentQuarter() {
    let expectation = expectationWithDescription("get tables")
    givenUserLoggedIn().continueWithBlock { (task: BFTask!) -> AnyObject? in
      self.sut.classOfCurrentQuarter { (classes, error) -> Void in
        XCTAssertNil(error)
        expectation.fulfill()
      }
      return nil
    }
    waitForExpectationsWithTimeout(4) { (error) -> Void in
      XCTAssertNil(error)
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
