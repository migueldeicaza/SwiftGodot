@testable import SwiftGodot
@testable import SwiftGodotRuntime
import XCTest

final class RuntimeLookupTests: XCTestCase {
    func testNodeLookupUsesPublicModuleMangling() {
        XCTAssertTrue(typeOfClass(named: "Node") == Node.self)
        XCTAssertEqual(
            mangledGodotTypeNames(for: "Node"),
            [
                "10SwiftGodot4NodeC",
                "17SwiftGodotRuntime4NodeC",
            ]
        )
    }
}
