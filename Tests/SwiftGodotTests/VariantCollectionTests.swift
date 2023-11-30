import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class VariantCollectionTests: GodotTestCase {
    func testAppendingElementStoresInArray() {
        let sut: VariantCollection<Int> = []

        sut.append(value: 111)
        
        XCTAssertEqual(sut.array.count, 1, "The \(GArray.self) behind the collection should have one element after one element has been appended")
        XCTAssertEqual(Int(sut.array[0]), 111, "After appending an Int with the value of 111, the first variant in the \(GArray.self) should hold an Int with the value 111")
    }

    func testInitWithElementsStoresInArray() {
        let sut: VariantCollection<Int> = [333]

        XCTAssertEqual(sut.array.count, 1, "The \(GArray.self) behind the collection should have one element after being initialized with one element")
        XCTAssertEqual(Int(sut.array[0]), 333, "After initializing with an Int with the value of 333, the first variant in the \(GArray.self) should hold an Int with the value 333")
    }

    func testArrayCanBeReassigned() {
        let sut: VariantCollection<Int> = [888]

        let newArray: GArray = .init([999, 1111])

        sut.array = newArray
        
        XCTAssertEqual(sut.array, newArray, "After reassigning the \(GArray.self) it should equal the new \(GArray.self)")
        XCTAssertEqual(sut.array.count, 2, "The \(GArray.self) behind the collection should have two elemnts after being replaced with a \(GArray.self) of two elements")
        XCTAssertEqual(Int(sut.array[0]), 999, "After being replaced with a \(GArray.self) whose first variant wraps 999, the first element should hold an Int with a value of 999")
        XCTAssertEqual(Int(sut.array[1]), 1111, "After being replaced with a \(GArray.self) whose second variant wraps an Int of 1111, the second element should hold an Int with a value of 1111")
    }
    
    func testArrayCanBeModifiedOutsideOfTheCollection() {
        let sut: VariantCollection<Int> = []
        
        sut.array.append(value: Variant(222))
        
        XCTAssertEqual(sut.count, 1, "The collection count should be 1 after appending an element")
        XCTAssertEqual(sut[0], 222, "After 222 is appended to the \(GArray.self), the first value should be to 222")
    }
}

private extension GArray {
    convenience init(_ elements: [Int]) {
        self.init(Int.self)
        elements.forEach { append(value: Variant($0)) }
    }
}
