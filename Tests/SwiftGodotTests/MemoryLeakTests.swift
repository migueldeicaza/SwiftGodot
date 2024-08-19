import SwiftGodot
import SwiftGodotTestability
import XCTest

final class MemoryLeakTests: GodotTestCase {

    // https://github.com/migueldeicaza/SwiftGodot/issues/513
    func test_513_leak1() {
        func oneIteration(object: Object) {
            let list = object.getPropertyList()
            let it = list.makeIterator()
            for prop: GDictionary in it {
                _ = prop
            }
        }

        let object = Object()

        oneIteration(object: object)

        let before = Performance.getMonitor(.memoryStatic)

        for _ in 0 ..< 10_000 {
            oneIteration(object: object)
        }

        let after = Performance.getMonitor(.memoryStatic)

        XCTAssertEqual(before, after)
    }

}
