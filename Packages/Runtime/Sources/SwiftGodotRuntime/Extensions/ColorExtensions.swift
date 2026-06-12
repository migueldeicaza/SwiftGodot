//
//  ColorExtensions.swift
//  
//
//  Created by Mikhail Tishin on 29.01.2024.
//

public extension Color {
    
    /// The HSV hue of this color, on the range 0 to 1.
    var hue: Float {
        let min: Float = min (min (red, green), blue)
        let max: Float = max (max (red, green), blue)
        let delta: Float = max - min
        guard delta != 0 else {
            return 0
        }
        
        var hue: Float
        if red == max {
            hue = (green - blue) / delta // between yellow & magenta
        } else if green == max {
            hue = 2 + (blue - red) / delta // between cyan & yellow
        } else {
            hue = 4 + (red - green) / delta // between magenta & cyan
        }
        hue /= 6.0
        if hue < 0 {
            hue += 1.0
        }
        return hue
    }
    
    /// The HSV saturation of this color, on the range 0 to 1.
    var saturation: Float {
        let min: Float = min (min (red, green), blue)
        let max: Float = max (max (red, green), blue)
        let delta: Float = max - min
        return max != 0 ? delta / max : 0
    }
    
    /// The HSV value (brightness) of this color, on the range 0 to 1.
    var value: Float {
        return max (max (red, green), blue)        
    }
    
}
