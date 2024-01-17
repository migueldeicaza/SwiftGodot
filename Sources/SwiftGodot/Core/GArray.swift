//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/8/23.
//

@_implementationOnly import GDExtension

public enum ArrayError {
    case outOfRange
}
extension GArray {
    /// Initializes an empty, but typed `GArray`. For example: `GArray(Node.self)`
    /// - Parameter type: `T` the type of the elements in the GArray, must conform to `VariantStorable`.
	public convenience init<T: VariantStorable>(_ type: T.Type = T.self) {
		self.init(
			base: GArray(),
			type: Int32(T.Representable.godotType.rawValue),
			className: T.Representable.godotType == .object ? StringName("\(T.self)") : StringName(),
			script: Variant()
		)
	}
    
    public subscript (index: Int) -> Variant {
        get {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return Variant()
            }
            let ptr = ret.assumingMemoryBound(to: Variant.ContentType.self)
            return Variant(fromContent: ptr.pointee)
        }
        set {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return
            }
            let ptr = ret.assumingMemoryBound(to: Variant.ContentType.self)
            ptr.pointee = newValue.content
        }
    }
}
