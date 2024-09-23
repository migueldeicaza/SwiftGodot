import SwiftSyntax
import SwiftSyntaxBuilder

/// Generate methods to help marshaling arguments to Godot while keeping things civil and on stack
func generateUnsafePointerHelpers(_ p: Printer) {
    let maxNestingDepth = 16
    
    for i in 1..<maxNestingDepth {
        p(generateUnsafeRawPointersN(pointerCount: i))
        p("")
    }
    
    for i in 1..<maxNestingDepth {
        p(generateWithUnsafeArgumentsPointer(argumentsCount: i))
        p("")
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

private func generateUnsafeRawPointersN(pointerCount count: Int) -> String {
    let syntax = StructDeclSyntax(name: "UnsafeRawPointersN\(raw: count)") {
        for i in 0..<count {
            "let p\(raw: i): UnsafeRawPointer?"
        }
    }
        
    return syntax.formatted().description
}


/// Generate methods to put the unsafe pointers into the `UnsafeRawPointersN#` to provide a scope to execute logic using the unsafe pointer to that struct, rebound to a
/// `UnsafeRawPointer`. This approach works on assumption, that the struct has the same layout as a static size array of `const void *` with the same element count.
///
/// ```swift
/// func withUnsafeArgumentsPointer<T0, T1, T2, R>(_ p0: UnsafePointer<T0>, _ p1: UnsafePointer<T1>, _ p2: UnsafePointer<T2>, _ body: (UnsafePointer<UnsafeRawPointer?>) -> R) -> R {
///     var storage = UnsafeRawPointersN3(p0: p0, p1: p1, p2: p2)
///
///     return withUnsafePointer(to: &storage) { ptr in
///         ptr.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 3) { rawPtr in
///             body(rawPtr)
///         }
///     }
/// }
/// ```
private func generateWithUnsafeArgumentsPointer(argumentsCount count: Int) -> String {
    let funcDecl = FunctionDeclSyntax(
        attributes: "@inline(__always)",
        funcKeyword: .keyword(.func, leadingTrivia: .newline),
        name: "withUnsafeArgumentsPointer",
        genericParameterClause: GenericParameterClauseSyntax(parameters: GenericParameterListSyntax {
            for i in 0..<count {
                GenericParameterSyntax(name: "T\(raw: i)")
            }
            
            GenericParameterSyntax(name: "R")
        }),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                for i in 0..<count {
                    FunctionParameterSyntax(
                        
                        firstName: "_",
                        secondName: "p\(raw: i)",
                        type: TypeSyntax(stringLiteral: "UnsafePointer<T\(i)>")
                    )
                }
                
                FunctionParameterSyntax(stringLiteral: "_ body: (UnsafePointer<UnsafeRawPointer?>) -> R")
            },
            returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "R"))
        )
    ) {
        let storageInitParameters = (0..<count).map { i in
            "p\(i): p\(i)"
        }.joined(separator: ", ")
                
        """
        return withUnsafePointer(to: UnsafeRawPointersN\(raw: count)(\(raw: storageInitParameters))) { ptr in
            ptr.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: \(raw: count)) { rawPtr in
                body(rawPtr)
            }                
        }
        """
    }
    
    return funcDecl.formatted().description
}
