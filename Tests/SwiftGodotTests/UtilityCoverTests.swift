import SwiftGodot
import SwiftGodotTestability
import XCTest

@available(macOS 14, *)
final class UtilityCoverTests: GodotTestCase {

    func testSignf() {
        forAll {
            TinyGen.mixedDoubles
        } checkCover: {
            GD.signf(x: $0)
        }
    }

    func testSigni() {
        forAll {
            TinyGen.edgyInt64s
        } checkCover: {
            GD.signi(x: $0)
        }
    }

    func testSnappedi() {
        forAll {
            TinyGen.mixedDoubles
            TinyGen.edgyInt64s
        } checkCover: {
            GD.snappedi(x: $0, step: $1)
        }
    }

}
