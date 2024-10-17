# iOS Platform Integration

This page contains some examples of code that might be useful to combine Godot
with iOS APIs.

## Converting a Viewport into an Image

If you happen to have a viewport, you can create a screenshot of it like this:

```swift
func getImage (from: SceneTree) -> SwiftGodot.Image? {
	from.root?.getViewport()?.getTexture()?.getImage()
}
```

## Converting a SwiftGodot.image into a UIImage

This function will attempt to convert a SwiftGodot image into a UIImage:

```swift
extension SwiftGodot.Image {
    func toUIImage() -> UIImage? {
        let width = Int(getWidth())
        let height = Int(getHeight())
        
        // Ensure the image format is compatible (RGBA8)
        if getFormat() != Image.Format.rgba8 {
            convert(format: Image.Format.rgba8)
        }
        
        guard let pixelData = getData().asData() else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let provider = CGDataProvider(data: pixelData as CFData) else { return nil }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
```

## Converting a SwiftGodot.Color into a SwiftUI.Color

```swift
extension SwiftGodot.Color {
    /// Creates a SwiftUI.Color from a SwiftGodot.Color
    public func asSwiftUI() -> SwiftUI.Color {
        SwiftUI.Color(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            opacity: Double(alpha)
        )
    }
}
```

### Converting PackedByteArray into a Swift Data 

```swift
extension PackedByteArray {
    public func asData() -> Data? {
        return withUnsafeAccessToData { ptr, count in Data (bytes: ptr, count: count) }
    }
}
```


### Making GodotError conform to LocalizedError

This is convenient if you want to easily bubble up GodotError messages in
SwiftUI:

```swift

// The @retroactive is to avoid the warning on LocalizedError, which is not on SwiftGodot,
// because SwiftGodot avoids taking a dependency on Foundation
extension GodotError: @retroactive LocalizedError {
    public var failureReason: String? {
        return localizedDescription
    }
    public var errorDescription: String? {
        return localizedDescription
    }
}
```