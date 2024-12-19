// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// This code is copied with permission from https://github.com/elegantchaos/EmbeddedXCTest.
// Check back there for updates.

import XCTest

/// Non-generic base class for EmbeddedTestCase.
open class EmbeddedTestBase: XCTestCase {
}

/// Base class for test cases that are embedded.
///
/// When running normally, the tests will be silent and will do nothing.
/// When re-run the embedded context, the test case will perform its normal
/// actions.
open class EmbeddedTestCase<T: TestHost>: EmbeddedTestBase {
  override open var name: String {
    return EmbeddingController.isRunningEmbedded ? "Embedded(\(super.name))" : super.name
  }
  open override var testRunClass: AnyClass? {
    EmbeddingController.isRunningEmbedded ? SilentTestRun.self : super.testRunClass
  }

  open override class func setUp() {
    EmbeddingController.setUp(hostClass: T.self)
    super.setUp()
  }

  open override func run() {
    if EmbeddingController.isRunningEmbedded {
      super.run()
    }
  }
}
