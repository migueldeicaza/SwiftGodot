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


@available(*, deprecated, renamed: "VariantArray", message: "GArray was renamed to `VariantArray` to better communicate its semantics")
public typealias GArray = VariantArray

extension VariantArray: CustomDebugStringConvertible {
    /// Provides debug description of this instance:
    /// ```
    /// let array = VariantArray()
    /// array.append(1)
    /// array.append(2)
    /// print(array) // prints [1, 2]
    /// ```
    public var debugDescription: String {
        "[\(map { $0?.description ?? "nil"}.joined(separator: ", "))]"
    }
    
    /// Return the typing information suitable for Swift metatype magic.
    @usableFromInline
    var typing: ContainerTypingParameter {
        let rawValue = getTypedBuiltin()
        guard let gtype = Variant.GType(rawValue: rawValue) else {
            fatalError("Unknown variant type rawValue: \(rawValue)")
        }
        
        switch gtype {
        case .object:
            let className = getTypedClassName().asciiDescription
            guard let metatype = typeOfClass(named: className) else {
                GD.printErr("Unknown class name: \(className).")
                return .builtin(.nil)
            }
            
            return .object(metatype)
        default:
            return .builtin(gtype)
        }
    }
    
    /// Initializes an empty, but typed `VariantArray`. For example: `VariantArray(Node?.self)`, `VariantArray(Int.self)`
    /// - Parameter type: `T` the type of the elements in the VariantArray, must conform to `_GodotContainerTypingParameter`.
    public convenience init<T: _GodotContainerTypingParameter>(_ type: T.Type = T.self) {
        self.init(
            base: VariantArray(),
            type: Int32(T._variantType.rawValue),
            className: T._className,
            script: nil
        )
    }
    
    /// Initializes an empty, but typed `VariantArray`. For example: `VariantArray(Node.self)`
    /// - Parameter type: `T` the type of the elements in the VariantArray, must conform to `_GodotNullableBridgeable`.
    ///
    /// ### Note
    /// It's the same as `init(T?.self)`.
    public convenience init<T: _GodotNullableBridgeable>(_ type: T.Type = T.self) {
        self.init(T?.self)
    }
    
    /// Allows subscription array as in `array[0]`.    
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
    public func withFastVariant<R>(at index: Int, _ body: (borrowing FastVariant?) -> R) -> R {
        guard let ret = gi.array_operator_index(&content, Int64 (index)) else {
            return body(nil)
        }
        
        let ptr = ret.assumingMemoryBound(to: VariantContent.self)
        var variant = FastVariant(unsafelyBorrowing: ptr.pointee)
        
        let result = body(variant)
        
        variant?.unsafelyForget()
        
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
