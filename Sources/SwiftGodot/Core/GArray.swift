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
            
            // We are making a copy of the variant managed by the array. Array is managing its copy, we are managing ours
            return Variant(copying: ptr.pointee)
        }
        set {
            guard let ret = gi.array_operator_index (&content, Int64 (index)) else {
                return
            }
            let ptr = ret.assumingMemoryBound(to: Variant.ContentType.self)
            
            guard ptr.pointee != newValue.content else {
                return
            }
                        
            // We are taking the variant from the array at the `index` and assuming control over it. Since we don't need it, we just destroy it
            gi.variant_destroy(ptr)
            
            // We are giving array a copy of `newValue` Variant to manage
            gi.variant_new_copy(ptr, &newValue.content)
        }
    }
    
    @available(*, deprecated, renamed: "append(_:)", message: "This method signature has been deprecated in favor of append(_:)")
    public func append(value: Variant) {
        append(value)
    }
}
