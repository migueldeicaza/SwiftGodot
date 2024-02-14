import Foundation
@_implementationOnly import GDExtension

public extension RefCounted {
    /// Decrements the internal reference counter. Deletes underlying object if it goes to zero..
    /// 
    /// This is flagged `_exp` because it will eventually be folded into deinit for RefCounted
    /// objects
    func _exp_unref() {
        let instanceID = Int64(bitPattern: UInt64(getInstanceId()))
        if GD.isInstanceIdValid(id: instanceID) {
            if unreference() {
                gi.object_destroy(UnsafeMutableRawPointer(mutating: handle))
            }
        }
    }
}
