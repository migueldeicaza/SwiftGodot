

@testable import SwiftGodot

@SwiftGodotTestSuite
final class TypedArrayTests {
    public func testAppendingElementStoresInArray() {
        let sut: TypedArray<Int> = []

        sut.append(111)
        
        assertEqual(sut.count, 1, "The \(VariantArray.self) behind the collection should have one element after one element has been appended")
        guard let variant = sut.array[0] else {
            fail()
            return
        }
        assertEqual(Int(variant), 111, "After appending an Int with the value of 111, the first variant in the \(VariantArray.self) should hold an Int with the value 111")
    }

    func testInitWithElementsStoresInArray() {
        let sut: TypedArray<Int> = [333]

        assertEqual(sut.count, 1, "The \(VariantArray.self) behind the collection should have one element after being initialized with one element")
        guard let variant = sut.array[0] else {
            fail()
            return
        }
        assertEqual(Int(variant), 333, "After initializing with an Int with the value of 333, the first variant in the \(VariantArray.self) should hold an Int with the value 333")
    }

    func testArrayCanBeModifiedOutsideOfTheCollection() {
        let sut: TypedArray<Int> = []
        
        sut.array.append(Variant(222))
        
        assertEqual(sut.count, 1, "The collection count should be 1 after appending an element")
        assertEqual(sut[0], 222, "After 222 is appended to the \(VariantArray.self), the first value should be to 222")
    }
    
    func testExplicitVariantTypedArray() {
        let typed = TypedArray<Variant?>()
        
        typed.append(10.toVariant())
        assertEqual(typed[0], 10.toVariant())
    }
    
    func testCompatibleArrays() {
        let typed = TypedArray<Object?>()
        let anotherTyped = TypedArray<Object?>(from: typed.array)
        
        assertTrue(typed.array === anotherTyped.array)
    }
    
    func testObjectArrayInvariance() {
        let typed = TypedArray<Node?>()
        let anotherTyped = TypedArray<Object?>(from: typed.array)
        let node = Node()
        typed.append(node)
        assertTrue(typed.array !== anotherTyped.array)
        assertTrue(typed.array != anotherTyped.array)
        node.queueFree()
    }
    
    func testSequenceInitializer() {
        let sequence = [1, 2, 3, 4]
                
        let typedArray = TypedArray(sequence)
        assertEqual(typedArray[2], 3)
        assertEqual(typedArray[3], 4)
        
        let dictionary = [
            "Hello": 2,
            "World": 3
        ]
        let anotherTypedArray = TypedArray(dictionary.keys)
        assertTrue(anotherTypedArray.contains { $0 == "Hello" })
        assertTrue(anotherTypedArray.contains { $0 == "World" })
    }
    
}

private extension VariantArray {
    convenience init(_ elements: [Int]) {
        self.init(Int.self)
        elements.forEach { append(Variant($0)) }
    }
}
