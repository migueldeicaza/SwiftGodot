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

    static let testNamePattern = #/-\[\w+ (?<name>\w+)\]/#

    /// Print out the names of all the tests and suites in a suite.
    static func describe(suiteOrTest: XCTest, indent: String = "") {
        if let suite = suiteOrTest as? XCTestSuite {
            if !indent.isEmpty { // skip printing top level suite
                print("\(indent)\(suite.name)")
            }
            for test in suite.tests {
                if test.name != "__GodotTestRunner" {
                    describe(suiteOrTest: test, indent: indent + "  ")
                }
            }
        } else if let test = suiteOrTest as? XCTestCase {
            let shortName = try? testNamePattern.firstMatch(in: test.name)?.name
            let testName = shortName.map { String($0) } ?? test.name
            print("\(indent)- \(testName)")
        }
    }

    /// Extract all the godot tests from a tree of XCTest objects.
    /// This flattens the tree into a a suite containing only the suites
    /// with tests that are subclasses of GodotTestCase.
    /// Any suites that don't contain any Godot tests are skipped, since
    /// they will be run in the normal XCTest runtime.
    @discardableResult static func extractGodotTests(_ from: XCTest, into: XCTestSuite) -> Bool {
        guard let suite = from as? XCTestSuite else { return false }
        if suite.containsGodotTests {
            into.addTest(suite)
            return true
        } else {
            var hadTests = false
            for test in suite.tests {
                if !extractGodotTests(test, into: into) {
                    #if DEBUG_SKIPPING
                    print("Skipped \(test.name) as it has no Godot tests")
                    #endif
                } else {
                    hadTests = true
                }
            }
            return hadTests
        }
    }

    /// Set up the Godot runtime and run all the tests in it.
    override func run() {
        // this call will be re-entered inside the Godot runtime, so we
        // need to check if the runtime is already initialized.
        if !GodotRuntime.isInitialized {

            // turn off buffering on stdout so that we see the output immediately
            setbuf(__stdoutp, nil)

            print("""
                
                Starting Godot Engine
                =====================

                """)

            // run the engine
            GodotRuntime.run {
                /// make a copy of all the GodotTestCase tests and run them in Godot
                let allTests = XCTestSuite.default
                let suite = XCTestSuite(name: "All Godot Tests")
                for test in allTests.tests {
                    Self.extractGodotTests(test, into: suite)
                }

                print("""
                    
                    Running Tests in Godot Engine
                    =============================

                    """)

                #if DEBUG_TEST_EXTRACTION // enable this to see the list of tests that will be run; useful for debugging
                print("We will run the following tests:")
                Self.describe(suiteOrTest: suite)
                print("\n\n")
                #endif

                suite.run()

                // record the failure count
                let run = suite.testRun!
                Self.failureCount = run.totalFailureCount

                print("""
                    
                    Done Godot Engine Tests
                    =======================
                    \(run.testCaseCount) tests run, \(run.totalFailureCount) failures.


                    Shutting Down Engine
                    ====================

                    """)

                // shut down the Godot runtime
                GodotRuntime.stop()
            }

            print("""
                
                Engine Shut Down Done
                =====================


                """)

            super.run()
        }
    }
}

extension XCTestSuite {
    var containsGodotTests: Bool {
        for test in tests {
            if test is GodotTestCase {
                return true
            }
        }
        return false
    }
}