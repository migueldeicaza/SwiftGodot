@testable import SwiftGodot
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

        // Warm-up the code path in case it performs any one-time permanent allocations.
        oneIteration(object: object)

        let before = Performance.getMonitor(.memoryStatic)
        let count = 1_000

        for _ in 0 ..< count {
            oneIteration(object: object)
        }

        let after = Performance.getMonitor(.memoryStatic)

        XCTAssertEqual(before, after, "Leaked \(Int((after - before) / Double(count))) bytes per iteration.")
    }

    // https://github.com/migueldeicaza/SwiftGodot/issues/513
    func test_513_leak2() {

        func oneIteration(bytes: PackedByteArray) {
            let image0 = SwiftGodot.Image()
            let variant = Variant(image0)
            let image: SwiftGodot.Image = variant.asObject()!
            _ = image.loadPngFromBuffer(bytes)
            // Doesn't leak with line below uncommented
            // image.unreference()
        }

        let bytes = PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 1, 3, 0, 0, 0, 37, 219, 86, 202, 0, 0, 0, 3, 80, 76, 84, 69, 0, 0, 0, 167, 122, 61, 218, 0, 0, 0, 1, 116, 82, 78, 83, 0, 64, 230, 216, 102, 0, 0, 0, 10, 73, 68, 65, 84, 8, 215, 99, 96, 0, 0, 0, 2, 0, 1, 226, 33, 188, 51, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130])

        // Warm-up the code path in case it performs any one-time permanent allocations.
        oneIteration(bytes: bytes)

        let before = Performance.getMonitor(.memoryStatic)
        let count = 1_000

        for _ in 0 ..< count {
            oneIteration(bytes: bytes)
        }

        let after = Performance.getMonitor(.memoryStatic)

        XCTAssertEqual(before, after, "Leaked \(Int((after - before) / Double(count))) bytes per iteration.")
    }

    
    func test_541_leak() {
        let before = Performance.getMonitor(.memoryStatic)
        
        for i in 0...10000000 {
            autoreleasepool {
                let variant = Variant("daosdoasodasoda")                
            }
        }
        
        let after = Performance.getMonitor(.memoryStatic)
        
        XCTAssertEqual(before, after, "Leaked \(Int(after - before))")
    }
}
