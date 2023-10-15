//
//  Endable.swift
//  
//
//  Created by Mikhail Tishin on 15.10.2023.
//

public protocol Endable {
    
    associatedtype VectorType: AdditiveArithmetic
    
    var position: VectorType { get }
    var size: VectorType { get set }

}

public extension Endable {
    
    var end: VectorType {
        set {
            size = newValue - position
        }
        get {
            return position + size
        }
    }
    
}

extension Vector2: AdditiveArithmetic {}
extension Vector2i: AdditiveArithmetic {}
extension Vector3: AdditiveArithmetic {}
extension Vector3i: AdditiveArithmetic {}

extension AABB: Endable {}
extension Rect2: Endable {}
extension Rect2i: Endable {}
