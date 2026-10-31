//
//  ObjectFreeObservers.swift
//  SwiftGodot
//
//  Notice, as it happens, that Godot freed an object.
//

/// Calls handlers when Godot frees the object they observe, from the instance binding's
/// free callback: on the thread that freed it, while it is being destroyed.
///
/// Used by `GodotTasks` to end a node's tasks the moment the node is freed, including tasks
/// suspended on something other than a frame, such as another object's signal.
@_spi(SwiftGodotRuntimePrivate)
public enum ObjectFreeObservers {
    private static let lock = NIOLock()
    nonisolated(unsafe) private static var nextToken: UInt64 = 0
    nonisolated(unsafe) private static var observers: [GodotNativeObjectPointer: [UInt64: () -> Void]] = [:]

    /// Calls `handler` once `object` is freed, unless the returned observation is cancelled
    /// first.  Returns `nil` if the object is already gone.
    public static func observe(_ object: Wrapped, _ handler: @escaping () -> Void) -> ObjectFreeObservation? {
        guard let handle = object.handle else { return nil }
        let token = lock.withLock { () -> UInt64 in
            nextToken += 1
            observers[handle, default: [:]][nextToken] = handler
            return nextToken
        }
        return ObjectFreeObservation(handle: handle, token: token)
    }

    static func remove(handle: GodotNativeObjectPointer, token: UInt64) {
        lock.withLockVoid {
            observers[handle]?.removeValue(forKey: token)
            if observers[handle]?.isEmpty == true {
                observers.removeValue(forKey: handle)
            }
        }
    }

    /// Called from every instance binding free callback.
    static func objectFreed(_ instance: UnsafeMutableRawPointer?) {
        guard let instance else { return }
        let handlers = lock.withLock { observers.removeValue(forKey: instance) }
        guard let handlers else { return }
        for handler in handlers.values {
            handler()
        }
    }
}

/// An observation from ``ObjectFreeObservers/observe(_:_:)``.
@_spi(SwiftGodotRuntimePrivate)
public final class ObjectFreeObservation: @unchecked Sendable {
    private let handle: GodotNativeObjectPointer
    private let token: UInt64

    init(handle: GodotNativeObjectPointer, token: UInt64) {
        self.handle = handle
        self.token = token
    }

    /// Stops observing.  Harmless after the handler ran.
    public func cancel() {
        ObjectFreeObservers.remove(handle: handle, token: token)
    }
}
