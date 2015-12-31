//
//  GoldDiggerTests.swift
//  GoldDiggerTests
//
//  Created by Tyler Weimin Ouyang on 12/29/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//

import XCTest
@testable import GoldDigger

class GoldDiggerTests: XCTestCase {
  var sut: GoldLoginHelper!
  
  override func setUp() {
    super.setUp()
    sut = GoldLoginHelper.sharedInstance
    sut.netID = ""
    sut.password = ""
  }
  
  override func tearDown() {
    sut.netID = ""
    sut.password = ""
    super.tearDown()
  }
  
  func test__singleton__shouldBeSameObject() {
    let secondObject = GoldLoginHelper.sharedInstance
    XCTAssertEqual(sut, secondObject)
  }
  
  func test__netID__setToABC__changeUserDefalts() {

    // when
    sut.netID = "ABC"
    let userDefaultValue = sut.userCredentials.stringForKey(credentialKeys.netID)
    // then
    XCTAssertEqual(sut.netID, "ABC")
    XCTAssertEqual(userDefaultValue, "ABC")
  }
  
  func test__password__setToDEF__changeUserDefalts() {

    // when
    sut.password = "DEF"
    let userDefaultValue = sut.userCredentials.stringForKey(credentialKeys.password)
    // then
    XCTAssertEqual(sut.password, "DEF")
    XCTAssertEqual(userDefaultValue, "DEF")
  }
  
  func test__login__withoutCredentials__loginFail() {
    let expectation = expectationWithDescription("loginFail")
    
    sut.login(onSuccess: nil) { error in
      XCTAssertNotNil(error)
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(1, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }
  
  func test__login__withCredentials__loginSuccess() {
    let expectation = expectationWithDescription("loginSuccess")
    
    sut.login(netID: "ouyang", password: "***REMOVED***", onSuccess: { () in
      XCTAssertTrue(self.sut.valid)
      expectation.fulfill()
      }, onFail: nil)
    
    waitForExpectationsWithTimeout(1, handler: { error in
      XCTAssertNil(error, "Error")
    })
  }

  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
}
