// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

/// Test run which does nothing.
/// We return one of these when an embedded test is run
/// without the embedded engine running. This avoids having
/// duplicate runs of the test appear in the output.
open class SilentTestRun: XCTestCaseRun {
  override init(test: XCTest) { super.init(test: XCTestCase()) }
  open override func start() {}
  open override func stop() {}
  open override func record(_ issue: XCTIssue) {}
  open override var hasBeenSkipped: Bool { true }
  open override var hasSucceeded: Bool { false }
  open override var skipCount: Int { 0 }
  open override var failureCount: Int { 0 }
  open override var executionCount: Int { 0 }
  open override var testCaseCount: Int { 0 }
  open override var unexpectedExceptionCount: Int { 0 }
  open override var totalFailureCount: Int { 0 }
  open override var totalDuration: TimeInterval { 0 }
  open override var testDuration: TimeInterval { 0 }
}
