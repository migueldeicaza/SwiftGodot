//
//  ObjectCollectionTests.swift
//  SwiftGodotTests
//
//  Created by Estevan Hernandez on 11/29/23.
//

import XCTest

import XCTest
import SwiftGodotTestability
@testable import SwiftGodot

final class ObjectCollectionTests: GodotTestCase {
    func testAppendingElementStoresInArray() {
        let sut: ObjectCollection<Node> = []
        let node = Node()
        
        sut.append(value: node)
        
        XCTAssertEqual(sut.count, 1, "The collection should have one element after one element has been appended")
        XCTAssertEqual(sut.array.count, 1, "The \(GArray.self) behind the collection should have one element after one element has been appended")
        XCTAssertEqual(node, Node.makeOrUnwrap(sut.array[0]), "The first element in the \(GArray.self) should hold the appended node")
        XCTAssertEqual(node, sut[0], "The first element in the collection should equal the appended node")
    }

    func testInitWithElementsStoresInArray() {
        let node = Node()
        let sut: ObjectCollection<Node> = [node]

        XCTAssertEqual(sut.count, 1, "The collection should have one element after being initialized with a node")
        XCTAssertEqual(sut.array.count, 1, "The \(GArray.self) behind the collection should have one element after being initialized with a node")
        XCTAssertEqual(Node.makeOrUnwrap(sut.array[0]), node, "The first element in the \(GArray.self) should be the node passed to init")
        XCTAssertEqual(sut[0], node, "The first element in the collection should be the node passed to init")
    }

    func testArrayCanBeReassigned() {
        let sut: ObjectCollection<Node> = [.init()]
        
        let otherNode = Node()
        let newArray: GArray = [otherNode].reduce(into: GArray(Node.self)) { $0.append(value: Variant($1)) }

        sut.array = newArray
        
        XCTAssertEqual(sut.array, newArray, "The GArray should equal the new \(GArray.self)")
        XCTAssertEqual(sut.count, 1, "The collection count should be 1 after the \(GArray.self) with 0 elements is reassigned with a \(GArray.self) with 1 element")
        XCTAssertEqual(sut.array.count, 1, "The \(GArray.self) count should be 1 after the \(GArray.self) with 0 elements is reassigned with a \(GArray.self) with 1 element")
        XCTAssertEqual(Node.makeOrUnwrap(sut.array[0]), otherNode, "The first element in the \(GArray.self) should hold the new node")
        XCTAssertEqual(sut[0], otherNode, "The first element in the collection should be the new node")
    }
    
    func testArrayCanBeModifiedOutsideOfTheCollection() {
        let sut: ObjectCollection<Node> = []
        
        let node = Node()
        sut.array.append(value: Variant(node))
        
        XCTAssertEqual(sut.count, 1, "The collection count should be 1 after a Variant was appended to the \(GArray.self)")
        XCTAssertEqual(sut[0], node, "The first element in the collection should be the appended node")
    }
}

