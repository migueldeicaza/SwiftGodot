class Hi: Node {
    static var int: SimpleSignal {
        get {
            SimpleSignal(target: self, signalName: "int")
        }
    }
}
