#if !SWIFT_GODOT_TRAIT_MEDIUM
extension GD {
    private static func makeMessage(from items: [Any], separator: String) -> String {
        items.map { String(describing: $0) }.joined(separator: separator)
    }

    public static func print(_ items: Any..., separator: String = " ") {
        Swift.print(makeMessage(from: items, separator: separator))
    }

    public static func printErr(_ items: Any..., separator: String = " ") {
        Swift.print(makeMessage(from: items, separator: separator))
    }

    public static func pushError(_ items: Any..., separator: String = " ") {
        Swift.print(makeMessage(from: items, separator: separator))
    }

    public static func pushWarning(_ items: Any..., separator: String = " ") {
        Swift.print(makeMessage(from: items, separator: separator))
    }
}
#endif
