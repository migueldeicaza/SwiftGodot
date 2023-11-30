import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class VariantCollectionTests: GodotTestCase {
    func testAppendingElementStoresInArray() throws {
        let sut: VariantCollection<Int> = []

        sut.append(value: 111)
        
        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(111, Int(firstVariant))
    }

    func testInitWithElementsStoresInArray() throws {
        let sut: VariantCollection<Int> = [3]

        XCTAssertEqual(sut.array.count, 1)
        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(Int(firstVariant), 3)
    }

    func testArrayCanBeReassigned() throws {
        let sut: VariantCollection<Int> = [8]

        let newArray: GArray = [13].reduce(into: GArray(Int.self)) { $0.append(value: Variant($1)) }

        sut.array = newArray
        
        XCTAssertEqual(sut.array, newArray)
        XCTAssertEqual(sut.array.count, 1)
        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(Int(firstVariant), 13)
    }
    
    func testArrayCanBeModifiedOutsideOfTheCollection() {
        let sut: VariantCollection<Int> = []
        
        sut.array.append(value: Variant(100))
        
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut[0], 100)
    }
}
