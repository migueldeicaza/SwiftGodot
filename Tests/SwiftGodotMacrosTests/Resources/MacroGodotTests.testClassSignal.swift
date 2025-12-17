class Hi: Node {
    class var int: SimpleSignal {
        get {
            SimpleSignal(target: self, signalName: "int")
        }
    }
}
