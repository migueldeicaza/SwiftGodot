// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/24.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

@testable import SwiftGodot

/// Test case which runs all the other tests from within the Godot runtime.
/// It doesn't actually matter when this suite is run, but we name it with
/// __ to try to make it run first, since `swift test` seems to run test
/// suites in alphabetical order.
class __GodotTestRunner: XCTestCase {
    /// Failure count from the tests run in Godot
    static var failureCount = 0

    /// By the time this test runs, all the other tests have already run
    /// in the Godot runtime. We can check the failure count here to see
    /// if any tests failed.
    func testRunEverythingInGodot() {
        XCTAssert(Self.failureCount == 0, "Some tests failed when running in Godot")
    }

    /// Set up the Godot runtime and run all the tests in it.
    override func run() {
        // this call will be re-entered inside the Godot runtime, so we
        // need to check if the runtime is already initialized.
        if !GodotRuntime.isInitialized {
            GodotRuntime.run {
                /// make a copy of all the tests and run them in Godot
                let allTests = XCTestSuite.default
                let suite = XCTestSuite(name: "All Tests In Godot")
                for test in allTests.tests {
                    suite.addTest(test)
                }
                suite.run()

                // record the failure count
                Self.failureCount = suite.testRun!.totalFailureCount

                // shut down the Godot runtime
                GodotRuntime.stop()
            }
            super.run()
        }
    }
}
