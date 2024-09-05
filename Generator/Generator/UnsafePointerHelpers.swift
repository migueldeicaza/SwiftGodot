import SwiftSyntax
import SwiftSyntaxBuilder

/// Generate methods to help marshaling arguments to Godot while keeping things civil and on stack
func generateUnsafePointerHelpers(_ p: Printer) {
    let maxNestingDepth = 16
    
    for i in 1..<maxNestingDepth {
        p(generateWithUnsafePointers(withDepth: i))
        p("")
    }
    
    for i in 1..<maxNestingDepth {
        p(generateUnsafeRawPointersN(pointerCount: i))
        p("")
    }
    
    for i in 1..<maxNestingDepth {
        p(generateWithUnsafePointerToUnsafePointersStoring(argumentsCount: i))
        p("")
    }
}

/// Generate a method nesting access to unsafe pointers to passed inout parameters and to allow executing a lambda in scope where all of these pointers are valid.
///
/// ```swift
/// func withUnsafePointers<T0, T1, T2, R>(to v0: inout T0, _ v1: inout T1, _ v2: inout T2, _ body: (UnsafePointer<T0>, UnsafePointer<T1>, UnsafePointer<T2>) -> R) -> R {
///     withUnsafePointer(to: v0) { p0 in
///         withUnsafePointer(to: v1) { p1 in
///             withUnsafePointer(to: v2) { p2 in
///                 body(p0, p1, p2)
///             }
///         }
///     }
/// }
/// ```
private func generateWithUnsafePointers(withDepth depth: Int) -> String {
    func codeBlockItemSyntax(currentDepth: Int = 0, maxDepth: Int) -> String {
        if currentDepth == maxDepth {
            let args = (0...maxDepth).map { i in
                "p\(i)"
            }.joined(separator: ", ")
            
            return "withUnsafePointer(to: v\(currentDepth)) { p\(currentDepth) in body(\(args)) }"
        } else {
            return "withUnsafePointer(to: v\(currentDepth)) { p\(currentDepth) in \(codeBlockItemSyntax(currentDepth: currentDepth + 1, maxDepth: maxDepth)) }"
        }
    }
    
    let funcDecl = FunctionDeclSyntax(
        name: "withUnsafePointers",
        genericParameterClause: GenericParameterClauseSyntax(parameters: GenericParameterListSyntax {
            for i in 0..<depth {
                GenericParameterSyntax(name: "T\(raw: i)")
            }
            
            GenericParameterSyntax(name: "R")
        }),
        signature: FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                for i in 0..<depth {
                    FunctionParameterSyntax(
                        
                        firstName: i == 0 ? "to" : "_",
                        secondName: "v\(raw: i)",
                        type: AttributedTypeSyntax(
                            specifier: TokenSyntax(stringLiteral: "inout"),
                            baseType: TypeSyntax(stringLiteral: "T\(i)")
                        )
                    )
                }
                
                let bodyParameters = (0..<depth).map { i in
                    "UnsafePointer<T\(i)>"
                }.joined(separator: ", ")
                
                FunctionParameterSyntax(stringLiteral: "_ body: (\(bodyParameters)) -> R")
            },
            returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "R"))
        )
    ) {
        CodeBlockItemSyntax(stringLiteral: codeBlockItemSyntax(maxDepth: depth - 1))
    }
    
    return funcDecl.formatted().description
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


/// Generate methods to put the unsafe pointers into the `UnsafeRawPointersN#` to provide a scope to execute logic using the unsafe pointer to that struct.
///
/// ```swift
/// func withUnsafePointerToUnsafePointers<T0, T1, T2, R>(storing v0: inout T0, _ v1: inout T1, _ v2: inout T2, _ body: (UnsafePointer<UnsafeRawPointersN3>) -> R) -> R {
///     withUnsafePointers(to: &v0, &v1, &v2) { p0, p1, p2 in
///         var storage = UnsafeRawPointersN3(p0: p0, p1: p1, p2: p2)
///
///         return withUnsafePointer(to: &storage) { ptr in
///             body(ptr)
///         }
///     }
/// }
/// ```
private func generateWithUnsafePointerToUnsafePointersStoring(argumentsCount count: Int) -> String {
    let funcDecl = FunctionDeclSyntax(
        name: "withUnsafePointerToUnsafePointers",
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
                
                FunctionParameterSyntax(stringLiteral: "_ body: (UnsafePointer<UnsafeRawPointersN\(count)>) -> R")
            },
            returnClause: ReturnClauseSyntax(type: TypeSyntax(stringLiteral: "R"))
        )
    ) {
//        let vParameters = (0..<count).map { i in
//            "&v\(i)"
//        }.joined(separator: ", ")
//        
//        let pParameters = (0..<count).map { i in
//            "p\(i)"
//        }.joined(separator: ", ")
//        
        let storageInitParameters = (0..<count).map { i in
            "p\(i): p\(i)"
        }.joined(separator: ", ")
        
        """
            var storage = UnsafeRawPointersN\(raw: count)(\(raw: storageInitParameters))
        
            return withUnsafePointer(to: &storage) { ptr in
                body(ptr)
            }
        """
    }
    
    return funcDecl.formatted().description
}
