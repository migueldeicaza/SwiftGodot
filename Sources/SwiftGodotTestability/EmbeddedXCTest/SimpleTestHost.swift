// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Test embedding host that just runs the tests,
/// and exits with a status code if there was a failure.
public struct SimpleTestHost: TestHost {
  public init() {}
  public func embedTests(_ runEmbeddedTests: () -> Int) {
    let failures = runEmbeddedTests()
    if failures > 0 {
      exit(Int32(failures))
    }
  }
}
