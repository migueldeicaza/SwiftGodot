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

extension Object {
    /// Retain this object if it's `RefCounted`
    final func retainIfRefCounted() {
        (self as? RefCounted)?.reference()
    }
    
    /// Release this object if it's `RefCounted`
    final func releaseIfRefCounted() {
        (self as? RefCounted)?.unreference()
    }
}
