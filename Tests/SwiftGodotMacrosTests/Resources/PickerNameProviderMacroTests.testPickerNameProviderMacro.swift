enum Character: Int64 {
    case chelsea
    case sky
}
enum Character2: Int {
    case chelsea
    case sky
}

extension Character: CaseIterable {
}

extension Character: Nameable {
    var name: String {
        switch self {
        case .chelsea:
            return "Chelsea"
        case .sky:
            return "Sky"
        }
    }
}

extension Character2: CaseIterable {
}

extension Character2: Nameable {
    var name: String {
        switch self {
        case .chelsea:
            return "Chelsea"
        case .sky:
            return "Sky"
        }
    }
}
