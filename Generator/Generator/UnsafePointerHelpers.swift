import SwiftSyntax
import SwiftSyntaxBuilder

/// Generate methods to help marshaling arguments to Godot while keeping things civil and on stack
func generateUnsafePointerHelpers(_ p: Printer) {
    let maxNestingDepth = 16
    
    for i in 1..<maxNestingDepth {
        generateUnsafeRawPointersN(p, pointerCount: i)
    }
}

/// Generate a struct that serves as a stack storage for multiple pointers, so that a pointer to it can be passed to Godot as `pargs` parameter.
///
/// ```swift
/// struct UnsafeRawPointersN3 {
///     let p0: UnsafeRawPointer?
///     let p1: UnsafeRawPointer?
///     let p2: UnsafeRawPointer?
/// }
/// ```
private func generateUnsafeRawPointersN(_ p: Printer, pointerCount count: Int) {
    p("struct UnsafeRawPointersN\(count)") {
        for i in 0..<count {
            p("let p\(i): UnsafeRawPointer?")
        }
    }
    
    p("extension UnsafeRawPointersN\(count)") {
        let args = (0..<count)
            .map {
                "_ p\($0): UnsafeRawPointer?"
            }
            .joined(separator: ", ")
        
        p("init(\(args))") {
            for i in 0..<count {
                p("self.p\(i) = p\(i)")
            }
        }
    }
}
