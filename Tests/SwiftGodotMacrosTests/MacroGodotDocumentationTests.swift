//
//  MacroGodotDocumentationTests.swift
//  SwiftGodotMacrosTests
//
//  Verifies the editor documentation that the @Godot macro generates from
//  documentation comments when the with_editor_documentation trait is enabled.
//

import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import SwiftGodotMacroLibrary

final class MacroGodotDocumentationTests: MacroGodotTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Godot": GodotMacro.self,
            "Export": GodotExport.self,
            "Callable": GodotCallable.self,
            "Signal": SignalAttachmentMacro.self,
        ]
    }

    override func setUp() {
        super.setUp()
        EditorDocumentation.isEnabled = true
    }

    func testDocumentsClassAndMembers() {
        assertExpansion(
            of: """
            /// A player-controlled character.
            ///
            /// Moves with ``speed`` and emits ``jumped`` when it leaves the ground.
            @Godot
            class Player: CharacterBody3D {
                /// Walking speed, in meters per second.
                @Export var speed: Double = 2

                /// Not documented in Godot, because it is not exported.
                var internalState = 0

                /// Makes the player jump.
                ///
                /// - Parameter height: How high to jump, in meters.
                /// - Returns: Whether the jump started.
                @Callable func jump(height: Double) -> Bool { true }

                /// Emitted when the player leaves the ground.
                @Signal var jumped: SimpleSignal

                enum Gait: Int, CaseIterable {
                    /// Slow and quiet.
                    case walk
                    /// Fast and loud.
                    case run
                }
            }
            """
        )
    }

    func testUndocumentedClassHasNoDocumentation() {
        assertExpansion(
            of: """
            @Godot
            class Plain: Node {
                @Export var value: Int = 0
            }
            """
        )
    }

    func testDeprecatedMember() {
        assertExpansion(
            of: """
            @Godot
            class Legacy: Node {
                @available(*, deprecated, message: "Use speed instead.")
                @Export var velocity: Double = 0
            }
            """
        )
    }

    // MARK: Conversion

    private func xml(for source: String) -> String? {
        let file = Parser.parse(source: source)
        guard let classDecl = file.statements.first?.item.as(ClassDeclSyntax.self) else { return nil }
        let processor = GodotMacroProcessor(classDecl: classDecl)
        _ = try? processor.processType()
        return processor.documentation.xml()
    }

    private func bbcode(_ markdown: String) -> String {
        let converter = DocCommentBBCodeConverter(resolveSymbol: { "<\($0)>" })
        return converter.convert(markdown.components(separatedBy: "\n")).fullText
    }

    func testInlineMarkup() {
        XCTAssertEqual(bbcode("Uses `a[0]`, **bold**, *italic* and _also italic_."),
                       "Uses [code]a[0][/code], [b]bold[/b], [i]italic[/i] and [i]also italic[/i].")
        XCTAssertEqual(bbcode("snake_case_names stay as they are"), "snake_case_names stay as they are")
        XCTAssertEqual(bbcode("2 * 3 * 4"), "2 * 3 * 4")
        XCTAssertEqual(bbcode("An [Array] of ``Node`` values."), "An [lb]Array[rb] of <Node> values.")
        XCTAssertEqual(bbcode("See [the docs](https://godotengine.org) or <https://swift.org>."),
                       "See [url=https://godotengine.org]the docs[/url] or [url]https://swift.org[/url].")
        XCTAssertEqual(bbcode("~~gone~~"), "[s]gone[/s]")
    }

    func testBlocks() {
        XCTAssertEqual(bbcode("""
            Summary line
            continues here.

            # Heading
            - first
            - second
              continues

            ```
            let x = [1]
            ```
            > Note: Be careful.
            - Warning: Really careful.
            """),
            """
            Summary line continues here.
            [b]Heading[/b]
            - first
            - second continues
            [codeblock]
            let x = [1]
            [/codeblock]
            [b]Note:[/b] Be careful.
            [b]Warning:[/b] Really careful.
            """)
    }

    func testParametersReturnsAndThrows() {
        XCTAssertEqual(bbcode("""
            Does things.
            - Parameters:
              - first: The first value.
              - second: The second value.
            - Returns: A result.
            - Throws: An error.
            """),
            """
            Does things.
            [b]Parameters:[/b]
            - [param first]: The first value.
            - [param second]: The second value.
            [b]Returns:[/b] A result.
            [b]Throws:[/b] An error.
            """)
    }

    func testSymbolReferences() {
        let output = xml(for: """
            /// Uses ``speed``, ``jump(height:)``, ``Player/jumped``, ``Gait``, ``Gait/run``, ``Node`` and ``helper()``.
            @Godot
            class Player: Node {
                @Export var speed: Double = 2
                @Callable(autoSnakeCase: true) func jumpHigh(height: Double) {}
                @Callable func jump(height: Double) {}
                @Signal var jumped: SimpleSignal
                enum Gait: Int, CaseIterable {
                    case walk, run
                }
            }
            """)
        XCTAssertEqual(
            output?.components(separatedBy: "\n").first { $0.hasPrefix("<brief_description>") },
            "<brief_description>Uses [member speed], [method jump], [signal jumped], [enum Gait], [constant run], [Node] and [code]helper()[/code].</brief_description>"
        )
    }

    func testGodotNamesAreUsed() throws {
        let output = try XCTUnwrap(xml(for: """
            @Godot
            class Names: Node {
                /// Snake-cased.
                @Export var maxSpeed: Double = 2
                /// Explicit.
                @Export(explicitName: "Custom") var renamed: Int = 0
                /// Auto snake case.
                @Callable(autoSnakeCase: true) func doThing() {}
            }
            """))
        XCTAssertTrue(output.contains("<member name=\"max_speed\" type=\"\">Snake-cased.</member>"))
        XCTAssertTrue(output.contains("<member name=\"Custom\" type=\"\">Explicit.</member>"))
        XCTAssertTrue(output.contains("<method name=\"do_thing\"><description>Auto snake case.</description></method>"))
    }

    func testXMLEscaping() throws {
        let output = try XCTUnwrap(xml(for: """
            /// Compares `a < b && c > d`.
            @Godot
            class Escaped: Node {}
            """))
        XCTAssertTrue(output.contains("<brief_description>Compares [code]a &lt; b &amp;&amp; c &gt; d[/code].</brief_description>"))
    }

    func testBlockComments() throws {
        let output = try XCTUnwrap(xml(for: """
            /**
             * A block comment.
             *
             * With a second paragraph.
             */
            @Godot
            class Blocky: Node {}
            """))
        XCTAssertTrue(output.contains("<brief_description>A block comment.</brief_description>"))
        XCTAssertTrue(output.contains("<description>With a second paragraph.</description>"))
    }

    func testStringLiteral() {
        XCTAssertEqual(swiftStringLiteral("a \"b\" \\ c\nd\te"), #""a \"b\" \\ c\nd\te""#)
    }
}
