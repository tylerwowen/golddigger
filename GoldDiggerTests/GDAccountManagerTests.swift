//
//  GDAccountManagerTests.swift
//  GoldDigger
//
//  Created by Tyler Weimin Ouyang on 12/30/15.
//  Copyright © 2015 Tyler Ouyang. All rights reserved.
//


import XCTest
@testable import GoldDigger

class GGDAccountManagerTests: XCTestCase {
  var sut: GDAccountManager!
  
  override func setUp() {
    super.setUp()
    sut = GDAccountManager.sharedInstance
    sut.netID = ""
    sut.password = ""
  }
  
  override func tearDown() {
    sut.netID = ""
    sut.password = ""
    super.tearDown()
  }
  
  func test__singleton__shouldBeSameObject() {
    let secondObject = GDAccountManager.sharedInstance
    XCTAssertEqual(sut, secondObject)
  }
  
  func test__netID__setToABC__changeUserDefalts() {
    
    // when
    sut.netID = "ABC"
    let userDefaultValue = sut.userCredentials.stringForKey(credentialKeys.netID)
    // then
    XCTAssertEqual(userDefaultValue, "ABC")
  }
  
  func test__password__setToDEF__changeUserDefalts() {
    
    // when
    sut.password = "DEF"
    let userDefaultValue = sut.userCredentials.stringForKey(credentialKeys.password)
    // then
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
      }, onFailure: nil)
    
    waitForExpectationsWithTimeout(4, handler: { error in
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
