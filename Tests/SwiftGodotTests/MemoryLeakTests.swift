import SwiftGodot
import SwiftGodotTestability
import XCTest

final class MemoryLeakTests: GodotTestCase {
    /// Check that `body` doesn't leak. Or ensure that something is leaking, if `useUnoReverseCard` is true
    func checkLeaks(useUnoReverseCard: Bool = false, _ body: () -> Void) {
        let before = Performance.getMonitor(.memoryStatic)
        body()
        let after = Performance.getMonitor(.memoryStatic)
        
        if useUnoReverseCard {
            XCTAssertNotEqual(before, after, "It should leak!")
        } else {
            XCTAssertEqual(before, after, "Leaked \(after - before) bytes")
        }
    }
    
    func testThatItLeaksIndeed() {
        let array = GArray()
        
        checkLeaks(useUnoReverseCard: true) {
            array.append(Variant(10))
        }
    }

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
        
        checkLeaks {
            for _ in 0 ..< 1_000 {
                oneIteration(object: object)
            }
        }
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

        checkLeaks {
            for _ in 0 ..< 1_000 {
                oneIteration(bytes: bytes)
            }
        }
    }
  
    // https://github.com/migueldeicaza/SwiftGodot/issues/541
    func test_541_leak() {
        checkLeaks {
            for _ in 0...10_000_000 {
                let _ = Variant("daosdoasodasoda")
            }
        }
    }
  
    // https://github.com/migueldeicaza/SwiftGodot/issues/544
    func test_544_leak() {
        let string = "Hello, World!"
        let variant = Variant(string)

        // https://docs.godotengine.org/en/stable/classes/class_string.html#class-string-method-left
        let methodName = StringName("left")

        checkLeaks {
            for _ in 0 ..< 2_000 {
                let _ = variant.call(method: methodName, Variant(2))
            }
        }
    }
    
    // https://github.com/migueldeicaza/SwiftGodot/issues/543
    func test_543_leak() {
        let string = "Hello, World!"
        let variant = Variant(string)

        checkLeaks {
            for _ in 0 ..< 2000 {
                _ = variant[0]
            }
        }
    }
    
    func test_array_leaks() {
        let array = GArray()
        array.append(Variant("S"))
        array.append(Variant("M"))
        
        checkLeaks {
            XCTAssertEqual(array[0], Variant("S"))
            
            for _ in 0 ..< 1_000 {
                array[0] = Variant("T")
                _ = array[1]
            }
        }
        
        XCTAssertEqual(array[0], Variant("T"))
        
        let variant = Variant(array)
        
        checkLeaks {
            XCTAssertEqual(variant[0], Variant("T"))
            
            for _ in 0 ..< 1_000 {
                variant[0] = Variant("U")
                variant[1] = Variant("K")
            }
            
            XCTAssertEqual(variant[1], Variant("K"))
        }
        
        XCTAssertEqual(variant[0], Variant("U"))
    }
}
