//
//  File.swift
//  
//
//  Created by Miguel de Icaza on 4/7/23.
//
import Foundation
extension PackedStringArray {
    /// Initializes a ``PackedStringArray`` from an array of strings
    public convenience init (_ values: [String]) {
        self.init ()
        for x in values {
            append(value: x)
        }
    }
    
    /// Accesses a specific element in the ``PackedStringArray``
    public subscript (index: Int) -> String {
        get {
            return GString.stringFromGStringPtr(ptr: gi.packed_string_array_operator_index (&content, Int64 (index))) ?? ""
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedByteArray {
    /// Accesses a specific element in the ``PackedByteArray``
    public subscript (index: Int) -> UInt8 {
        get {
            let ptr = gi.packed_byte_array_operator_index (&content, Int64 (index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Int64 (newValue))
        }
    }
    
    /// Returns a new Data object with a copy of the data contained by this PackedByteArray
    public func asData() -> Data? {
        if let ptr = gi.packed_byte_array_operator_index(&content, 0) {
            return Data (bytes: ptr, count: Int (size()))
        }
        return nil
    }
}

extension PackedColorArray {
    /// Accesses a specific element in the ``PackedColorArray``
    public subscript (index: Int) -> Color {
        get {
            let ptr = gi.packed_color_array_operator_index (&content, Int64 (index))
            return ptr!.assumingMemoryBound(to: Color.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedFloat32Array {
    /// Accesses a specific element in the ``PackedFloat32Array``
    public subscript (index: Int) -> Float {
        get {
            let ptr = gi.packed_float32_array_operator_index (&content, Int64 (index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Double (newValue))
        }
    }
}

extension PackedFloat64Array {
    /// Accesses a specific element in the ``PackedFloat64Array``
    public subscript (index: Int) -> Double {
        get {
            let ptr = gi.packed_float64_array_operator_index (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedInt32Array {
    /// Accesses a specific element in the ``PackedInt32Array``
    public subscript (index: Int) -> Int32 {
        get {
            let ptr = gi.packed_int32_array_operator_index (&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: Int64(newValue))
        }
    }
}

extension PackedInt64Array {
    /// Accesses a specific element in the ``PackedInt64Array``
    public subscript (index: Int) -> Int64 {
        get {
            let ptr = gi.packed_int64_array_operator_index(&content, Int64(index))
            return ptr!.pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedVector2Array {
    /// Accesses a specific element in the ``PackedVector2Array``
    public subscript (index: Int) -> Vector2 {
        get {
            let ptr = gi.packed_vector2_array_operator_index (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector2.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}

extension PackedVector3Array {
    /// Accesses a specific element in the ``PackedVector3Array``
    public subscript (index: Int) -> Vector3 {
        get {
            let ptr = gi.packed_vector3_array_operator_index (&content, Int64(index))
            return ptr!.assumingMemoryBound(to: Vector3.self).pointee
        }
        set {
            set (index: Int64 (index), value: newValue)
        }
    }
}


