
import SwiftGodotTestability
@testable import SwiftGodot

public final class TypedArrayTests: GodotTestCase {
    public override class var allTests: [GodotTest] {
        [
            GodotTest(name: "testAppendingElementStoresInArray", method: testAppendingElementStoresInArray),
            GodotTest(name: "testInitWithElementsStoresInArray", method: testInitWithElementsStoresInArray),
            GodotTest(name: "testArrayCanBeModifiedOutsideOfTheCollection", method: testArrayCanBeModifiedOutsideOfTheCollection),
            GodotTest(name: "testExplicitVariantTypedArray", method: testExplicitVariantTypedArray),
            GodotTest(name: "testCompatibleArrays", method: testCompatibleArrays),
            GodotTest(name: "testObjectArrayInvariance", method: testObjectArrayInvariance),
            GodotTest(name: "testSequenceInitializer", method: testSequenceInitializer),
        ]
    }

    public required init() {}

    public func testAppendingElementStoresInArray() {
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
        let typed = TypedArray<Variant?>()
        
        typed.append(10.toVariant())
        XCTAssertEqual(typed[0], 10.toVariant())
    }
    
    func testCompatibleArrays() {
        let typed = TypedArray<Object?>()
        let anotherTyped = TypedArray<Object?>(from: typed.array)
        
        XCTAssert(typed.array === anotherTyped.array)
    }
    
    func testObjectArrayInvariance() {
        let typed = TypedArray<Node?>()
        let anotherTyped = TypedArray<Object?>(from: typed.array)
        typed.append(Node())
        XCTAssert(typed.array !== anotherTyped.array)
        XCTAssert(typed.array != anotherTyped.array)
    }
    
    func testSequenceInitializer() {
        let sequence = [1, 2, 3, 4]
                
        let typedArray = TypedArray(sequence)
        XCTAssertEqual(typedArray[2], 3)
        XCTAssertEqual(typedArray[3], 4)
        
        let dictionary = [
            "Hello": 2,
            "World": 3
        ]
        let anotherTypedArray = TypedArray(dictionary.keys)
        XCTAssertTrue(anotherTypedArray.contains { $0 == "Hello" })
        XCTAssertTrue(anotherTypedArray.contains { $0 == "World" })
    }
    
}

private extension VariantArray {
    convenience init(_ elements: [Int]) {
        self.init(Int.self)
        elements.forEach { append(Variant($0)) }
    }
}
