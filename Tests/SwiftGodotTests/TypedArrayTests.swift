import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class TypedArrayTests: GodotTestCase {
    func testAppendingElementStoresInArray() {
        let sut: TypedArray<Int> = []

        sut.append(111)
        
        XCTAssertEqual(sut.count, 1, "The \(VariantArray.self) behind the collection should have one element after one element has been appended")
        guard let variant = sut.array[0] else {
            XCTFail()
            return
        }
        XCTAssertEqual(Int(variant), 111, "After appending an Int with the value of 111, the first variant in the \(VariantArray.self) should hold an Int with the value 111")
    }

    func testInitWithElementsStoresInArray() {
        let sut: TypedArray<Int> = [333]

        XCTAssertEqual(sut.count, 1, "The \(VariantArray.self) behind the collection should have one element after being initialized with one element")
        guard let variant = sut.array[0] else {
            XCTFail()
            return
        }
        XCTAssertEqual(Int(variant), 333, "After initializing with an Int with the value of 333, the first variant in the \(VariantArray.self) should hold an Int with the value 333")
    }
    
    func testArrayCanBeModifiedOutsideOfTheCollection() {
        let sut: TypedArray<Int> = []
        
        sut.array.append(Variant(222))
        
        XCTAssertEqual(sut.count, 1, "The collection count should be 1 after appending an element")
        XCTAssertEqual(sut[0], 222, "After 222 is appended to the \(VariantArray.self), the first value should be to 222")
    }
    
    func testExplicitVariantTypedArray() {
        //let typed = TypedArray<Int?>
        
    }
}

private extension VariantArray {
    convenience init(_ elements: [Int]) {
        self.init(Int.self)
        elements.forEach { append(Variant($0)) }
    }
}
