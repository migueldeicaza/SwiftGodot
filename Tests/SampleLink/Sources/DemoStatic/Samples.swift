// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftGodot
import Foundation

@main
struct Samples {
    static func main() {
        print("Hello, world, the type for \(StringName.self)")
	let result = NSClassFromString("10SwiftGodot4NodeC")
	print("Got \(String(describing: result))")
    }
}
