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
extension GArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        "[\(map { $0?.description ?? "nil"}.joined(separator: ", "))]"
    }
    
    /// Initializes an empty, but typed `GArray`. For example: `GArray(Node.self)`
    /// - Parameter type: `T` the type of the elements in the GArray, must conform to `_GodotBridgeable`.
    public convenience init<T: _GodotBridgeable>(_ type: T.Type = T.self) {
        let className: String
        
        if let type = type as? _GodotBridgeableObject.Type {
            className = type._godotTypeName
        } else {
            className = ""
        }
        
        self.init(
            base: GArray(),
            type: Int32(T._variantType.rawValue),
            className: StringName(className),
            script: nil
        )
    }
    
    /// Allows subscription array as in `array[0]`.
    /// Will not be selected as default overload for `TypedArray` subscript.
    @_disfavoredOverload
    public subscript(index: Int) -> Variant? {
        get {
            guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
                return nil
            }
            let ptr = ret.assumingMemoryBound(to: VariantContent.self)
            
            // We are making a copy of the variant managed by the array. Array is managing its copy, we are managing ours
            return Variant(copying: ptr.pointee)
        }
        set {
            guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
                return
            }
            let ptr = ret.assumingMemoryBound(to: VariantContent.self)
            
            guard ptr.pointee != newValue.content else {
                return
            }
                        
            // We are taking the variant from the array at the `index` and assuming control over it. Since we don't need it, we just destroy it
            gi.variant_destroy(ptr)
            
            // We are giving array a copy of `newValue` Variant to manage
            withUnsafePointer(to: newValue.content) { src in
                gi.variant_new_copy(ptr, src)
            }
        }
    }
    
    /// Borrows ``FastVariant`` at `index` to perform some action on it.
    public func withFastVariant<R>(at index: Int, _ body: (borrowing FastVariant?) -> R?) -> R? {
        guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
            return nil
        }
        
        let ptr = ret.assumingMemoryBound(to: VariantContent.self)
        var variant = FastVariant(unsafelyBorrowing: ptr.pointee)
        
        let result = body(variant)
        
        variant?.content = .zero // Avoid destroying a variant owned by Godot
        
        return result
    }
    
    /// Set ``FastVariant`` at `index`, consuming it
    public func setFastVariant(_ variantOrNil: consuming FastVariant?, at index: Int) {
        guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
            return
        }
        
        let ptr = ret.assumingMemoryBound(to: VariantContent.self)
        
        let newContent = variantOrNil?.content ?? .zero
        
        guard ptr.pointee != newContent else {
            /// Already has same value, our `variantOrNil` will be simply destroyed after `return`
            return
        }
                    
        // We are taking the variant from the array at the `index` and assuming control over it. Since we don't need it, we just destroy it
        gi.variant_destroy(ptr)
        
        // We are passing ownership over fast variant here, no copy is needed
        withUnsafePointer(to: newContent) { src in
            ptr.pointee = newContent
        }
        
        variantOrNil?.unsafelyForget()
    }
}
