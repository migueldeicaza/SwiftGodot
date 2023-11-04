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
    private static var metadata: ExtensionMetadata?
    
    func testAABB () throws {
        let checker = try prepareMemoryChecker (for: AABB.self)
        checker.assertSize ()
        checker.assert (keyPath: \.position)
        checker.assert (keyPath: \.size)
        checker.assertCheck ()
    }
    
    func testBasis () throws {
        let checker = try prepareMemoryChecker (for: Basis.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assertCheck ()
    }
    
    func testColor () throws {
        let checker = try prepareMemoryChecker (for: Color.self)
        checker.assertSize ()
        checker.assert (keyPath: \.red, member: "r")
        checker.assert (keyPath: \.green, member: "g")
        checker.assert (keyPath: \.blue, member: "b")
        checker.assert (keyPath: \.alpha, member: "a")
        checker.assertCheck ()
    }
    
    func testPlane () throws {
        let checker = try prepareMemoryChecker (for: Plane.self)
        checker.assertSize ()
        checker.assert (keyPath: \.normal)
        checker.assert (keyPath: \.d)
        checker.assertCheck ()
    }
    
    func testProjection () throws {
        let checker = try prepareMemoryChecker (for: Projection.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assert (keyPath: \.w)
        checker.assertCheck ()
    }
    
    func testQuaternion () throws {
        let checker = try prepareMemoryChecker (for: Quaternion.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assert (keyPath: \.w)
        checker.assertCheck ()
    }
    
    func testRect2 () throws {
        let checker = try prepareMemoryChecker (for: Rect2.self)
        checker.assertSize ()
        checker.assert (keyPath: \.position)
        checker.assert (keyPath: \.size)
        checker.assertCheck ()
    }
    
    func testRect2i () throws {
        let checker = try prepareMemoryChecker (for: Rect2i.self)
        checker.assertSize ()
        checker.assert (keyPath: \.position)
        checker.assert (keyPath: \.size)
        checker.assertCheck ()
    }
    
    func testTransform2D () throws {
        let checker = try prepareMemoryChecker (for: Transform2D.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.origin)
        checker.assertCheck ()
    }
    
    func testTransform3D () throws {
        let checker = try prepareMemoryChecker (for: Transform3D.self)
        checker.assertSize ()
        checker.assert (keyPath: \.basis)
        checker.assert (keyPath: \.origin)
        checker.assertCheck ()
    }
    
    func testVector2 () throws {
        let checker = try prepareMemoryChecker (for: Vector2.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assertCheck ()
    }
    
    func testVector2i () throws {
        let checker = try prepareMemoryChecker (for: Vector2i.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assertCheck ()
    }
    
    func testVector3 () throws {
        let checker = try prepareMemoryChecker (for: Vector3.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assertCheck ()
    }
    
    func testVector3i () throws {
        let checker = try prepareMemoryChecker (for: Vector3i.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assertCheck ()
    }
    
    func testVector4 () throws {
        let checker = try prepareMemoryChecker (for: Vector4.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assert (keyPath: \.w)
        checker.assertCheck ()
    }
    
    func testVector4i () throws {
        let checker = try prepareMemoryChecker (for: Vector4i.self)
        checker.assertSize ()
        checker.assert (keyPath: \.x)
        checker.assert (keyPath: \.y)
        checker.assert (keyPath: \.z)
        checker.assert (keyPath: \.w)
        checker.assertCheck ()
    }
    
}

// MARK: - Preparation
private extension MemoryLayoutTests {
        
    func getMetadata () throws -> ExtensionMetadata {
        if let metadata = Self.metadata {
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
        Self.metadata = extensionMetadata
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
        
        private let type: T.Type
        private let sizeMetadata: JGodotSize
        private let offsetMetadata: JGodotBuiltinClassMemberOffsetClass
        
        private let size: Int
        private var checkedSize: Int = 0
        private var checkedMembers: [String] = []
        private var checkedOffsets: [Int] = []
        
        init (_ type: T.Type, sizeMetadata: JGodotSize, offsetMetadata: JGodotBuiltinClassMemberOffsetClass) {
            self.type = type
            self.sizeMetadata = sizeMetadata
            self.offsetMetadata = offsetMetadata
            self.size = MemoryLayout<T>.size
        }
        
        func assertSize (file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual (size, sizeMetadata.size, "Memory layout doesn't match extected size", file: file, line: line)
        }
        
        func assert<V> (keyPath: KeyPath<T, V>, member: String? = nil, file: StaticString = #file, line: UInt = #line) {
            guard let layoutOffset = MemoryLayout<T>.offset (of: keyPath) else {
                XCTFail ("\(keyPath) has no memory footprint", file: file, line: line)
                return
            }
            let member = member ?? String(describing: keyPath).components(separatedBy: ".").last ?? ""
            guard !checkedOffsets.contains (layoutOffset), !checkedMembers.contains (member) else {
                XCTFail ("\(keyPath) has already been checked", file: file, line: line)
                return
            }
            checkedOffsets.append (layoutOffset)
            checkedMembers.append (member)
            guard let expectedOffset = offsetMetadata.members.first(where: { $0.member == member })?.offset else {
                XCTFail ("Couldn't find extected offset for \(keyPath)", file: file, line: line)
                return
            }
            XCTAssertEqual (layoutOffset, expectedOffset, "Unexpected offset at \(keyPath)", file: file, line: line)
            checkedSize += MemoryLayout<V>.size
        }
        
        func assertCheck (file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual (checkedSize, size, "Memory footprint wasn't checked entirely", file: file, line: line)
            let uncheckedMembers = offsetMetadata.members.map({ $0.member }).filter({ !checkedMembers.contains($0) })
            XCTAssertEqual(uncheckedMembers, [], "Not all members were checked", file: file, line: line)
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
