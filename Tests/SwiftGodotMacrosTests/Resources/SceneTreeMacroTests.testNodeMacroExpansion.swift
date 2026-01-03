class MyNode: Node {
    var character: CharacterBody2D {
        get {
            getNodeOrNull(path: NodePath(stringLiteral: "Entities/CharacterBody2D")) as! CharacterBody2D
        }
    }
}
