//
//  SwiftGodotTestInvocation.swift
//

/// Represents a single test invocation with its name and execution closure.
public struct SwiftGodotTestInvocation {
    /// The name of the test method.
    public let name: String

    /// Closure that runs the test.
    ///
    /// Declared `async throws` so that a suite can mix synchronous tests with ones that
    /// await.  A synchronous, non-throwing method converts to this type implicitly, so
    /// existing suites are unaffected.
    ///
    /// Note that a test method's *isolation* travels with the method, not with this
    /// closure type: a test annotated with a global actor still runs its body on that
    /// actor, no matter where it is awaited from.  That is what lets the runner keep
    /// async test bodies on Godot's main thread.
    public let run: () async throws -> Void

    /// Creates a new GodotTest.
    ///
    /// - Parameters:
    ///   - name: The name of the test (usually the method name).
    ///   - run: Closure that executes the test.
    public init(name: String, run: @escaping () async throws -> Void) {
        self.name = name
        self.run = run
    }
}
