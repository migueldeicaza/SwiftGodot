// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/2024.
//  All code (c) 2024 - present day, Sam Deane.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest

/// Object that observes XCTest events and collects information about
/// the tests that are being run.
/// During the initial run, the tests are collected into a suite, but
/// not actually run properly.
/// Once the normal test run is complete, we call back to the embedding
/// host, supplying it a closure that will re-run the tests.
/// The host can then run the tests in a different context.
public class EmbeddingController: NSObject, XCTestObservation {
  /// The shared instance of the observer.
  nonisolated(unsafe) static var _instance: EmbeddingController?

  /// The host that will re-run the tests.
  let host: TestHost

  /// Initialise the observer with a host.
  init(host: TestHost) {
    self.host = host
  }

  /// Test suite we build up by observing the normal test run.
  /// We'll re-run this suite later, with the isRunning flag set to true,
  let embeddedSuite = XCTestSuite(name: "Embedded Tests")

  /// Failures that occurred during the embedded test run.
  var embeddedFailures: [(XCTestCase, String, String?, Int)] = []

  /// Are we currently running the embedded tests?
  var isRunningEmbedded = false

  /// Are the embedded tests currently running?
  public static var isRunningEmbedded: Bool { _instance?.isRunningEmbedded ?? false }

  /// Install hooks into the testing system.
  ///
  /// We add ourselves as an observer of XCTest events, so that we can
  /// collect information about the tests that are being run.
  ///
  /// Once the normal test run is complete, we re-run the tests that
  /// we've collected, with our isRunning flag set to true, so that
  /// the test bodies are actually executed.
  public static func setUp(hostClass: TestHost.Type) {
    if _instance == nil {
      // turn off buffering on stdout so that we see the output immediately
      setbuf(__stdoutp, nil)

      let observer = EmbeddingController(host: hostClass.init())
      _instance = observer
      XCTestObservationCenter.shared.addTestObserver(observer)
    }
  }

  /// Record a test suite that has finished running.
  func registerSuite(_ suite: XCTestSuite) {
    if !isRunningEmbedded {
      if let test = suite.tests.first as? XCTestCase {
        let testClass = type(of: test)
        let injected = EmbeddedTestCaseSuite(for: testClass, tests: suite.tests)
        embeddedSuite.addTest(injected)
      }
    }
  }

  public func runEmbeddedTests() -> Int {
    print(
      """

      ----------------------------------------------------------
      Running injected tests
      ----------------------------------------------------------

      """)

    isRunningEmbedded = true
    embeddedSuite.run()
    isRunningEmbedded = false

    print(
      """

      ----------------------------------------------------------

      Finished running injected tests with \(embeddedFailures.count) failures.

      """)

    return embeddedFailures.count
  }

  public func testCase(
    _ test: XCTestCase, didFailWithDescription description: String, inFile path: String?,
    atLine line: Int
  ) {
    embeddedFailures.append((test, description, path, line))
  }

  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    if testSuite.className == "XCTestCaseSuite" {
      registerSuite(testSuite)
      // } else {
      // print("SKIPPED \(testSuite) \(type(of: testSuite))")
    }
  }

  public func testBundleDidFinish(_ testBundle: Bundle) {
    host.embedTests {
      self.runEmbeddedTests()
    }
  }
}
