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
    func testAppendingElementStoresInArray() throws {
        let sut: ObjectCollection<Node> = []
        let node = Node()
        
        sut.append(value: node)
        
        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(node, Node.makeOrUnwrap(firstVariant))
    }

    func testInitWithElementsStoresInArray() throws {
        let node = Node()
        let sut: ObjectCollection<Node> = [node]

        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(Node.makeOrUnwrap(firstVariant), node)
    }

    func testArrayCanBeReassigned() throws {
        let sut: ObjectCollection<Node> = [.init()]
        
        let otherNode = Node()
        let newArray: GArray = [otherNode].reduce(into: GArray(Node.self)) { $0.append(value: Variant($1)) }

        sut.array = newArray
        
        XCTAssertEqual(sut.array, newArray)
        let firstVariant = try XCTUnwrap(sut.array.first)
        XCTAssertEqual(sut.array.count, 1)
        XCTAssertEqual(Node.makeOrUnwrap(firstVariant), otherNode)
    }
    
    func testArrayCanBeModifiedOutsideOfTheCollection() throws {
        let sut: ObjectCollection<Node> = []
        
        let node = Node()
        sut.array.append(value: Variant(node))
        
        let firstElement = try XCTUnwrap(sut.first)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(firstElement, node)
    }
}

