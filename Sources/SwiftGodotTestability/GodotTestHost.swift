// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/12/24.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct GodotTestHost: TestHost {
    public init() {}
    public func embedTests(_ runEmbeddedTests: @escaping () -> Int) {
        var failures = 0
        GodotRuntime.run {
            failures = runEmbeddedTests()
            GodotRuntime.stop()
        }

        if failures > 0 {
            exit(Int32(failures))
        }
    }
}