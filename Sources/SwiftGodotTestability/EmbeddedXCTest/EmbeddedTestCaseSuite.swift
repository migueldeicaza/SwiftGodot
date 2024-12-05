// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// Test suite which contains all the test cases for a given embedded test case class.
///
/// The suite runs the class setup and teardown methods before and after running the tests.
internal class EmbeddedTestCaseSuite: XCTestSuite {
  private let testCaseClass: XCTestCase.Type

  init(for testClass: XCTestCase.Type, tests: [XCTest]) {
    let testCaseClass = testClass
    self.testCaseClass = testCaseClass
    super.init(name: "\(testCaseClass) (Embedded)")
    for test in tests {
      addTest(test)
    }
  }

  override func setUp() {
    testCaseClass.setUp()
  }

  override func tearDown() {
    testCaseClass.tearDown()
  }
}
