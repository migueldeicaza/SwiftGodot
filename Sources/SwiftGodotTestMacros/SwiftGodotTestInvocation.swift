//
//  SwiftGodotTestInvocation.swift
//

/// Represents a single test invocation with its name and execution closure.
public struct SwiftGodotTestInvocation {
    /// The name of the test method.
    public let name: String

    /// Closure that runs the test.
    public let run: () -> Void

    /// Creates a new GodotTest.
    ///
    /// - Parameters:
    ///   - name: The name of the test (usually the method name).
    ///   - run: Closure that executes the test.
    public init(name: String, run: @escaping () -> Void) {
        self.name = name
        self.run = run
    }
}
