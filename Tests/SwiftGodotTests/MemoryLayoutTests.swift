//
//  MemoryLayoutTests.swift
//  
//
//  Created by Mikhail Tishin on 17.10.2023.
//

import XCTest
import ExtensionApi
import ExtensionApiJson
@testable import SwiftGodot

final class MemoryLayoutTests: XCTestCase {
    
    private let buildConfiguration: String = "float_64"
    private var metadata: ExtensionMetadata?
    
    func testVector2 () throws {
        let checker = try prepareMemoryChecker (for: Vector2.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assertChecked ()
    }
    
}

// MARK: - Preparation
private extension MemoryLayoutTests {
        
    func getMetadata () throws -> ExtensionMetadata {
        if let metadata {
            return metadata
        }
        guard let url = URL.extensionApiJson else {
            throw MemoryTestError.jsonApiUnavailable
        }
        let data = try Data (contentsOf: url)
        let extensionApi = try JSONDecoder().decode (JGodotExtensionAPI.self, from: data)
        guard let sizes = extensionApi.builtinClassSizes.first (where: { $0.buildConfiguration == buildConfiguration })?.sizes,
              let offsets = extensionApi.builtinClassMemberOffsets.first (where: { $0.buildConfiguration == buildConfiguration })?.classes
        else { throw MemoryTestError.noConfigurationMetadata }
        let extensionMetadata = ExtensionMetadata (sizes: sizes, offsets: offsets)
        self.metadata = extensionMetadata
        return extensionMetadata
    }

    func prepareMemoryChecker<T> (for type: T.Type) throws -> MemoryLayoutChecker<T> {
        let metadata: ExtensionMetadata = try getMetadata ()
        let name = String (describing: type)
        guard let size = metadata.sizes.first (where: { $0.name == name }) else { throw MemoryTestError.noClassSize }
        guard let offset = metadata.offsets.first (where: { $0.name.rawValue == name }) else { throw MemoryTestError.noClassOffsets }
        return MemoryLayoutChecker (type, sizeMetadata: size, offsetMetadata: offset)
    }
    
}

// MARK: - Data types
private extension MemoryLayoutTests {
    
    final class MemoryLayoutChecker<T> {
        
        let type: T.Type
        let sizeMetadata: JGodotSize
        let offsetMetadata: JGodotBuiltinClassMemberOffsetClass
        
        let size: Int
        var checkedSize: Int = 0
        var checkedOffsets: [Int] = []
        
        init (_ type: T.Type, sizeMetadata: JGodotSize, offsetMetadata: JGodotBuiltinClassMemberOffsetClass) {
            self.type = type
            self.sizeMetadata = sizeMetadata
            self.offsetMetadata = offsetMetadata
            self.size = MemoryLayout<T>.size
        }
        
        func assertSize (file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual (size, sizeMetadata.size, "Memory layout doesn't match extected size", file: file, line: line)
        }
        
        func assert<V> (keyPath: KeyPath<T, V>, file: StaticString = #file, line: UInt = #line) {
            guard let layoutOffset = MemoryLayout<T>.offset (of: keyPath) else {
                XCTFail ("\(keyPath) has no memory footprint", file: file, line: line)
                return
            }
            guard !checkedOffsets.contains (layoutOffset) else {
                XCTFail ("\(keyPath) has already been checked", file: file, line: line)
                return
            }
            checkedOffsets.append (layoutOffset)
            let member = String (describing: keyPath).components(separatedBy: ".").last
            guard let expectedOffset = offsetMetadata.members.first(where: { $0.member == member })?.offset else {
                XCTFail ("Couldn't find extected offset for \(keyPath)", file: file, line: line)
                return
            }
            XCTAssertEqual (layoutOffset, expectedOffset, "Unexpected offset at \(keyPath)", file: file, line: line)
            checkedSize += MemoryLayout<V>.size
        }
        
        func assertChecked (file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual (checkedSize, size, "Memory footprint wasn't checked entirely", file: file, line: line)
        }
        
    }
    
    struct ExtensionMetadata {
        let sizes: [JGodotSize]
        let offsets: [JGodotBuiltinClassMemberOffsetClass]
    }
    
    enum MemoryTestError: Error {
        case jsonApiUnavailable, noConfigurationMetadata, noClassSize, noClassOffsets
    }
    
}
