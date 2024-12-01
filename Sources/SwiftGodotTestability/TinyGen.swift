#if canImport(Darwin)
import Darwin
#elseif os(Windows)
import ucrt
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
#error("Unable to identify your C library.")
#endif

/// A tiny implementation of QuickCheck-like combinators for making random values.
///
/// Shrinking is not implemented.
public struct TinyGen<Output: Sendable>: Sendable {
    private let _gen: @Sendable (_ rng: SipRNG) -> Output

    public init(_ gen: @escaping @Sendable (_ rng: SipRNG) -> Output) {
        _gen = gen
    }

    public func callAsFunction(_ rng: SipRNG) -> Output { return _gen(rng) }

    public static func build(@TinyGenBuilder _ build: () -> Self) -> Self {
        return build()
    }
}

@resultBuilder
public struct TinyGenBuilder {

    public init() { }

    public func callAsFunction<Output>(@TinyGenBuilder _ build: () -> TinyGen<Output>) -> TinyGen<Output> {
        return build()
    }

    public static func buildExpression<Output>(_ gen: TinyGen<Output>) -> TinyGen<Output> {
        return gen
    }

    // Variadic generics require macOS 14.
    @available(macOS 14, *)
    public static func buildBlock<each Output>(_ gen: repeat TinyGen<each Output>) -> TinyGen<(repeat each Output)> {
        // Copy gen to a local tuple to eliminate the following error as of Xcode 16.1:
        // Capture of 'gen' with non-sendable type 'repeat T<each V>' in a `@Sendable` closure
        let gen = (repeat each gen)

        return TinyGen { rng in
            var rng = rng

            func draw<T>(_ gen: TinyGen<T>) -> T {
                defer { rng = rng.right() }
                return gen(rng.left())
            }

            return (repeat draw(each gen))
        }
    }

}

extension TinyGen {
    /// - parameter transform: A function that transforms my output into something new.
    /// - returns: A `TinyGen` that takes my output and applies `transform` to it.
    public func map<New>(_ transform: @Sendable @escaping (Output) -> New) -> TinyGen<New> {
        return TinyGen<New> { rng in
            let old = self(rng)
            return transform(old)
        }
    }

    /// - parameter transform: A function that transforms my output into a generator of something new.
    /// - returns: A `TinyGen` that takes my output, applies `transform` to it, and then returns the output of the new generator.
    public func flatMap<New>(_ transform: @Sendable @escaping (Output) -> TinyGen<New>) -> TinyGen<New> {
        return TinyGen<New> { rng in
            return transform(self(rng.left()))(rng.right())
        }
    }
}

extension TinyGen {
    /// - parameter output: The output to be returned.
    /// - returns: A `TinyGen` that always returns `output`.
    public static func const(_ output: Output) -> Self {
        return TinyGen { rng in output }
    }

    /// - parameter max: The maximum value to return. This value can actually be returned.
    /// - returns: A `TinyGen` that returns a random value in the range `0 ... max`.
    public static func primitive(max: UInt64) -> Self where Output == UInt64{
        guard max != .max else {
            return TinyGen { rng in rng.draw() }
        }

        let upperBound = max &+ 1

        return TinyGen { rng in
            // https://github.com/swiftlang/swift/pull/39143/commits/87b3f607042e653a42b505442cc803ec20319c1c
            let (result, fraction) = upperBound.multipliedFullWidth(by: rng.left().draw())
            guard fraction > 0 &- upperBound else { return result }
            let pHi = upperBound.multipliedFullWidth(by: rng.right().draw()).high
            let carry = fraction.addingReportingOverflow(pHi).overflow
            return result + (carry ? 1 : 0)
        }
    }

    /// - parameter values: An array of possible outputs.
    /// - returns: A `TinyGen` that returns a random element of `values`.
    public static func oneOf(values: [Output]) -> Self {
        precondition(!values.isEmpty)
        return TinyGen<UInt64>.primitive(max: UInt64(values.count - 1))
            .map { values[Int($0)] }
    }

    /// - parameter gens: An array of generators.
    /// - returns: A `TinyGen` that picks of one of `gens` at random and returns the output of that generator.
    public static func oneOf(gens: [TinyGen<Output>]) -> Self {
        precondition(!gens.isEmpty)
        return TinyGen<UInt64>.primitive(max: UInt64(gens.count - 1)).flatMap { gens[Int($0)] }
    }

    /// - parameter values: An array of possible outputs, each with an associated frequency. An output with frequency `10` is chosen twice as often as an output with frequency `5`.
    /// - returns: One of the outputs in `values`, randomly chosen according to the associated frequencies.
    public static func biasedOneOf(values: [(Int, Output)]) -> Self {
        precondition(!values.isEmpty)
        precondition(values.allSatisfy { $0.0 >= 0 })
        let totalFrequency = values.reduce(0) { $0 + $1.0 }
        return TinyGen<UInt64>.primitive(max: UInt64(totalFrequency - 1)).map {
            var i = $0
            for (frequency, value) in values {
                if i < frequency {
                    return value
                }
                i -= UInt64(frequency)
            }
            fatalError("unreachable")
        }
    }

    /// - parameter values: An array of generators, each with an associated frequency. A generator with frequency `10` is chosen twice as often as a generator with frequency `5`.
    /// - returns: The output of one of the generators in `values`, randomly chosen according to the associated frequencies.
    public static func biasedOneOf(gens: [(Int, TinyGen<Output>)]) -> Self {
        precondition(!gens.isEmpty)
        precondition(gens.allSatisfy { $0.0 >= 0 })
        let totalFrequency = gens.reduce(0) { $0 + $1.0 }
        return TinyGen<UInt64>
            .primitive(max: UInt64(totalFrequency - 1))
            .flatMap {
            var i = $0
            for (frequency, gen) in gens {
                if i < frequency {
                    return gen
                }
                i -= UInt64(frequency)
            }
            fatalError("unreachable")
        }
    }
}

extension TinyGen where Output == Int32 {

    /// A generator of `Int32`s, unbiased.
    public static let allInt32s: TinyGen<Int32> = TinyGen<UInt64>.primitive(max: .max)
        .map { Int32(truncatingIfNeeded: $0) }

    /// A generator of `Int32`s that are near the min and max possible values.
    public static let extremeInt32s: TinyGen<Int32> = oneOf(values: [
        Int32.min,
        Int32.min + 1,
        Int32.max - 1,
        Int32.max,
    ])

    /// A generator of `Int32`s, capable of generating any value but extra likely to generate values that cause overflow.
    public static let edgyInt32s: TinyGen<Int32> = biasedOneOf(gens: [
        (1, extremeInt32s),
        (9, allInt32s),
    ])

    /// A generator of “safe” `Int32`s, where any two can be added, subtracted, multiplied, or divided without risk of overflow.
    public static let safeInt32s: TinyGen<Int32> = TinyGen<UInt64>.primitive(max: 2 * 46340)
        .map { Int32(truncatingIfNeeded: $0) - 46340}
    // 46340² < Int32.max; 46341² > Int32.max.
}

extension TinyGen where Output == Int64 {
    /// A generator of `Int64`s, unbiased.
    public static let allInt64s: TinyGen<Int64> = TinyGen<UInt64>.primitive(max: .max)
        .map { Int64(bitPattern: $0) }

    /// A generator of `Int64`s that are near the min and max possible values.
    public static let extremeInt64s: TinyGen<Int64> = oneOf(values: [
        Int64.min,
        Int64.min + 1,
        Int64.max - 1,
        Int64.max,
    ])

    public static let int64sNearInt32Bounds: TinyGen<Int64> = oneOf(values: [
        Int64(Int32.min) - 1,
        Int64(Int32.min),
        Int64(Int32.min) + 1,
        Int64(Int32.max) - 1,
        Int64(Int32.max),
        Int64(Int32.max) + 1,
    ])

    /// A generator of `Int64`s, capable of generating any value but extra likely to generate values that cause overflow.
    public static let edgyInt64s: TinyGen<Int64> = biasedOneOf(gens: [
        (1, int64sNearInt32Bounds),
        (1, extremeInt64s),
        (9, allInt64s),
    ])
}

extension TinyGen where Output == Double {
    /// A generator of `Double`s in the range 0.0 ... 1.0 inclusive.
    public static let closedUnitRangeDoubles: TinyGen<Double> = TinyGen { rng in
        // https://mumble.net/~campbell/2014/04/28/uniform-random-float
        // https://mumble.net/~campbell/2014/04/28/random_real.c
        var rng = rng
        var exponent = -64
        var significand: UInt64
        while true {
            significand = rng.left().draw()
            rng = rng.right()
            guard significand == 0 else { break }
            exponent -= 64
            guard exponent >= -1074 else { return 0 }
        }
        let lzs = significand.leadingZeroBitCount
        if lzs != 0 {
            exponent -= lzs
            significand &<<= lzs
            let moreBits = rng.draw()
            significand |= (moreBits &>> (64 - lzs))
        }
        significand |= 1
        return Double(sign: .plus, exponent: exponent, significand: Double(significand))
    }

    /// - returns: A “random” `Double` drawn from a Gaussian distribution.
    @available(macOS 14, *)
    public static let gaussianDoubles: TinyGen<Double> = TinyGenBuilder {
        TinyGen.closedUnitRangeDoubles
        TinyGen.closedUnitRangeDoubles
    }.map { x1, x2 in
        // Box-Muller transform.
        let f = (-2.0 * log(x1)).squareRoot()
        return f * cos(2.0 * .pi * x2)
    }

    /// A generator of “weird” `Double`s.
    public static let weirdDoubles: TinyGen<Double> = oneOf(values: [
        -.infinity,
        -1e100,
        -0.0, // negative zero is an unusual value
        1e100,
         .infinity,
         .nan,
    ])

    /// A generator of “reasonable” `Double`s (in the range `-5000.0 ... 5000.0`).
    @available(macOS 14, *)
    public static let reasonableDoubles: TinyGen<Double> = TinyGen.gaussianDoubles.map { 1000.0 * $0 }

    /// A generator that mostly generates “reasonable” `Double`s but generates some “weird” `Double`s.
    @available(macOS 14, *)
    public static let mixedDoubles: TinyGen<Double> = biasedOneOf(gens: [
        (1, weirdDoubles),
        (9, reasonableDoubles),
    ])
}

extension TinyGen where Output == Float {
    /// - returns: A “random” `Float` drawn from a Gaussian distribution.
    @available(macOS 14, *)
    public static let gaussianFloats: TinyGen<Float> = TinyGen<Double>.gaussianDoubles.map { Float($0) }

    /// A generator of “weird” `Float`s.
    public static let weirdFloats: TinyGen<Float> = oneOf(values: [
        -.infinity,
        -1e30,
        -0.0, // negative zero is an unusual value
        1e30,
         .infinity,
         .nan,
    ])

    /// A generator of “reasonable” `Float`s.
    @available(macOS 14, *)
    public static let reasonableFloats: TinyGen<Float> = TinyGen.gaussianFloats.map { 100.0 * $0 }

    /// A generator that mostly generates “reasonable” `Float`s but generates some “weird” `Float`s.
    @available(macOS 14, *)
    public static let mixedFloats: TinyGen<Float> = biasedOneOf(gens: [
        (9, reasonableFloats),
        (1, weirdFloats),
    ])
}

extension TinyGen where Output == Float {
}

/// A splittable random number generator based on the ideas of [*Splittable pseudorandom number generators using cryptographic hashing*](https://publications.lib.chalmers.se/records/fulltext/183348/local_183348.pdf but using SipHash-2-4 as the cryptographic hash.
public struct SipRNG {
    private var sipHash: SipHash_2_4

    public init(key0: UInt64, key1: UInt64) {
        sipHash = .init(key0: key0, key1: key1)
    }

    /// - returns: A “random” `UInt64` drawn from a uniform distribution. This can be any 64-bit value. I return the same value every time! If you want different values, you need to ask different `SipRNG` instances, by using my `left` and `right` methods to split me.
    public func draw() -> UInt64 {
        return sipHash.hash()
    }

    /// - returns: A new `SipRNG` which (probably) returns a different value from its `draw`, `left`, and `right` methods than either I or my `right()` child do.
    public func left() -> Self {
        var answer = self
        answer.sipHash.append(false)
        return answer
    }

    /// - returns: A new `SipRNG` which (probably) returns a different value from its `draw`, `left`, and `right` methods than either I or my `left()` child do.
    public func right() -> Self {
        var answer = self
        answer.sipHash.append(true)
        return answer
    }
}

/// A fast cryptographic hash algorithm. The Swift standard library also uses this algorithm for hashing.
/// https://github.com/veorq/SipHash
private struct SipHash_2_4 {
    /// SipHash state.
    private var v0, v1, v2, v3: UInt64

    /// Bits appended that haven't yet been “compressed” into the state. Bits are inserted from LSB to MSB.
    private var buffer: UInt64 = 0

    /// Bit mask of the next bit to insert into `buffer`.
    private var nextBit: UInt64 = 1

    /// Total number of bits inserted.
    private var totalBits: Int = 0

    init(key0: UInt64, key1: UInt64) {
        v0 = key0 ^ 0x736f6d6570736575
        v1 = key1 ^ 0x646f72616e646f6d
        v2 = key0 ^ 0x6c7967656e657261
        v3 = key1 ^ 0x7465646279746573
    }

    mutating func append(_ bit: Bool) {
        if bit { buffer |= nextBit }
        nextBit <<= 1
        totalBits += 1
        guard nextBit == 0 else { return }
        compressBuffer()
    }

    func hash() -> UInt64 {
        var copy = self
        return copy.finalize()
    }

    private mutating func compressBuffer() {
        nextBit = 1

        v3 ^= buffer
        sipRound()
        sipRound()
        v0 ^= buffer

        buffer = 0
    }

    private mutating func sipRound() {
        // Formatted to match the SipHash paper.

        v0 &+= v1      ; v2 &+= v3
        v1.rotLeft(13) ; v3.rotLeft(16)
        v1 ^= v0       ; v3 ^= v2
        v0.rotLeft(32)
        v2 &+= v1      ; v0 &+= v3
        v1.rotLeft(17) ; v3.rotLeft(21)
        v1 ^= v2       ; v3 ^= v0
        v2.rotLeft(32)
    }

    private mutating func finalize() -> UInt64 {
        // If buffer has less than 8 bits free, I need to start a new buffer to finalize, because I need to put the bit count mod 256 into the high byte of the buffer.
        if totalBits & 63 < 8 {
            compressBuffer()
        }

        // SipHash operates on a byte stream, and puts the total number of compressed bytes, mod 256, in the high byte of the last word. Since I operate on a bit stream, I put the total number of compressed bits mod 256.
        buffer |= (UInt64(totalBits) & 0xff) << 56
        compressBuffer()

        v2 ^= 0xff
        sipRound()
        sipRound()
        sipRound()
        sipRound()
        return v0 ^ v1 ^ v2 ^ v3
    }
}

extension UInt64 {
    fileprivate mutating func rotLeft(_ count: Int) {
        self = (self &<< count) | (self &>> (64 - count))
    }
}
