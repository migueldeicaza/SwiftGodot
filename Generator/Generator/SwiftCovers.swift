import Foundation
import SwiftParser
import SwiftSyntax

/// Source snippets of Swift that can replace FFI calls to Godot engine methods.
struct SwiftCovers {

    /// Load the Swift source files from `sourceDir` and extract snippets usable as method implementations.
    init(sourceDir: URL) {
        let urls: [URL]
        do {
            urls = try FileManager.default.contentsOfDirectory(
                at: sourceDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
            )
        } catch {
            print("warning: couldn't scan folder at \(sourceDir): \(error)")
            return
        }

        for url in urls {
            let source: String
            do {
                source = try String(contentsOf: url, encoding: .utf8)
            } catch {
                print("warning: couldn't read contents of \(url): \(error)")
                continue
            }

            let root = Parser.parse(source: source)

            for statement in root.statements {
                guard
                    let extensionSx = statement.item.as(ExtensionDeclSyntax.self),
                    extensionSx.genericWhereClause == nil,
                    let extendedType = extensionSx.extendedType.as(IdentifierTypeSyntax.self)
                else {
                    continue
                }

                for member in extensionSx.memberBlock.members {
                    guard
                        let function = member.decl.as(FunctionDeclSyntax.self),
                        function.modifiers.map({ $0.name.tokenKind }) == [.keyword(.public)],
                        function.genericParameterClause == nil,
                        function.genericWhereClause == nil,
                        case let signature = function.signature,
                        signature.effectSpecifiers == nil,
                        case let parameterTypes = signature.parameterClause.parameters
                            .compactMap({ $0.type.as(IdentifierTypeSyntax.self)?.name }),
                        parameterTypes.count == signature.parameterClause.parameters.count
                    else {
                        continue
                    }

                    let functionName = function.name
                    let returnType = signature.returnClause?.type ?? "Void"

                    print("found method for \(extendedType): '\(functionName)' returning \(returnType) and taking \(parameterTypes.map { "\($0)" }.joined(separator: ", ") )")
                }
            }
        }
    }

}
