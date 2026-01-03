class MyNode: Node {
    var character: CharacterBody2D? {
        get {
            getNodeOrNull(path: NodePath(stringLiteral: "character")) as? CharacterBody2D
        }
    }
}
