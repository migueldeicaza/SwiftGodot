// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/12/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Implement this protocol to provide a custom test host.
public protocol TestHost {
  /// Create the host.
  init()

  /// Perform any necessary setup, then call the supplied
  /// closure to run the tests.
  /// The closure returns the number of failures.
  func embedTests(_ runner: @escaping () -> Int)
}
