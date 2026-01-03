let spriteTexture = {
    guard let texture: Texture2D = GD.load(path: "res://assets/icon.png") else {
        GD.pushError("Texture could not be loaded.", "TestModule/test.swift", 1)
        preconditionFailure(
            "Texture could not be loaded.",
            file: "TestModule/test.swift",
            line: 1)
    }
    return texture
}()
