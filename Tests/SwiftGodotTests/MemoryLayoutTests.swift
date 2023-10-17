//
//  MemoryLayoutTests.swift
//  
//
//  Created by Mikhail Tishin on 17.10.2023.
//

import XCTest
@testable import SwiftGodot

final class MemoryLayoutTests: XCTestCase {
    
    final class MemoryLayoutChecker<T> {
        
        let type: T.Type
        let size: Int
        var checkedSize: Int = 0
        var checkedOffsets: [Int] = []
        
        init(_ type: T.Type) {
            self.type = type
            self.size = MemoryLayout<T>.size
        }
        
        func assert<V>(keyPath: KeyPath<T, V>, offset: Int, file: StaticString = #file, line: UInt = #line) {
            guard let layoutOffset = MemoryLayout<T>.offset(of: keyPath) else {
                XCTFail("\(keyPath) has no memory footprint", file: file, line: line)
                return
            }
            guard !checkedOffsets.contains(layoutOffset) else {
                XCTFail("\(keyPath) has already been checked", file: file, line: line)
                return
            }
            checkedOffsets.append(layoutOffset)
            XCTAssertEqual(layoutOffset, offset, "Unexpected offset at \(keyPath)", file: file, line: line)
            checkedSize += MemoryLayout<V>.size
        }
        
        func assertChecked(file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual(checkedSize, size, "Memory footprint wasn't checked entirely", file: file, line: line)
        }
        
    }
    
    func testVector2() throws {
        let checker = MemoryLayoutChecker(Vector2.self)
        checker.assert(keyPath: \.x, offset: 0)
        checker.assert(keyPath: \.y, offset: 4)
        checker.assertChecked()
    }
    
}
