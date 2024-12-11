@_spi(SwiftCovers) import SwiftGodot

extension GD {

    public static func signf(x: Double) -> Double {
        return x > 0 ? 1 : x < 0 ? -1 : 0
    }

    public static func signi(x: Int64) -> Int64 {
        return x.signum()
    }

    public static func snappedi(x: Double, step: Int64) -> Int64 {
        let answer: Double
        if step == 0 {
            answer = x
        } else {
            let step = Double(step)
            answer = (x / step + 0.5).rounded(.down) * step;
        }
        return cCastToInt64(answer)
    }

}
