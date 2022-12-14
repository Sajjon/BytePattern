import Algorithms
import Foundation

/// A **linear time** byte pattern finder, useful to discover that two bytes seqences
/// are almost identical, probably they are but during construction of one of
/// them the developer has accidently either reversed the sequence, or
/// they originate from integers, which might accidently use the wrong
/// endianess, or a combination of both.
///
/// All examples below assume that the bytes sequences `LHS` and `RHS`
/// have the same length.
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `dead beef 1234 5678 abba 0912 deed fade`
/// ) => `.identical`
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `edaf deed 2190 abba 8765 4321 feeb daed`
/// ) => `.sameIf([.entireReveresed(.entireSequenceAsHex)])`
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `defa edde 1209 baab 7856 3412 efbe adde`
/// ) => `.sameIf([.reversed(.entireSequenceAsBytes)])`
///
/// (
///     `dead beef 1234`,
///     `1234 beef dead`
/// ) => `.sameIf([.reversed(.orderOfIntegers(.uint16)))`
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `adde efbe 3412 7856 baab 1209 edde defa`
/// ) => `.sameIf([.endianessSwapped(for: .uint16)])`
///
/// (
///     `deadbeef 12345678 abba0912 deedfade`, // grouped 4 bytes together
///     `efbeadde 78563412 1209baab defaedde`
/// ) => `.sameIf([.endianessSwapped(for: .uint32)])`
///
/// (
///     `deadbeef12345678 abba0912deedfade`, // grouped 8 bytes together
///     `78563412efbeadde defaedde1209baab`
/// ) => `.sameIf([.endianessSwapped(for: .uint64)])`
///
///
/// (
///     `dead beef 1234`,
///     `edda ebfe 2143`
/// ) => `.sameIf([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsHex)])`
///
/// One thing to note is that these mutations:
/// `.sameIf([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers)])``
/// is the same as `.sameIf([reversed(entireSequenceAsBytes)]))`.
///
/// Another thing to note is that these mutations:
/// `.sameIf([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsBytes)])
/// would result in the `identity`, i.e. `identical`, and does not work for just `uint16` but for any int.
///
public struct BytePatternFinder {
    public init() {}
}

public extension BytePatternFinder {
    func find(
        lhs lhsContiguousBytes: some ContiguousBytes,
        rhs rhsContiguousBytes: some ContiguousBytes
    ) -> BytePattern? {
        var s = Storage()

        // time complexity scoped: `O(n/2)`
        // time complexity so far: `O(n/2)`
        return lhsContiguousBytes.withUnsafeBytes { lhs -> BytePattern? in
            rhsContiguousBytes.withUnsafeBytes { rhs -> BytePattern? in
                guard lhs.count == rhs.count else {
                    return BytePattern?.none
                }

                guard
                    lhs.count.isMultiple(of: 2),
                    rhs.count.isMultiple(of: 2)
                else {
                    // Odd byte count not supported yet.
                    return nil
                }

                for byteOffsetLSB in 0 ..< (lhs.count) / 2 {
                    let byteOffsetMSB = lhs.count - byteOffsetLSB - 1 // -1 because zero indexed...
                    let lhsLSB = lhs.load(fromByteOffset: byteOffsetLSB, as: UInt8.self)
                    let lhsMBS = lhs.load(fromByteOffset: byteOffsetMSB, as: UInt8.self)
                    let rhsLSB = rhs.load(fromByteOffset: byteOffsetLSB, as: UInt8.self)
                    let rhsMSB = rhs.load(fromByteOffset: byteOffsetMSB, as: UInt8.self)

                    s.update(
                        lhsLSB: lhsLSB,
                        lhsMSB: lhsMBS,
                        rhsLSB: rhsLSB,
                        rhsMSB: rhsMSB
                    )
                }

                s.assertCorrectness()

                // time complexity scoped: `O(1)`
                // time complexity so far: `O(n/2) + O(1)` <=> `O(n/2)`
                if s.bools.sequenceIsIdentical {
                    return .identical
                }

                // time complexity scoped: `O(1)`
                // time complexity so far: `O(n/2) + O(1)` <=> `O(n/2)`
                if s.bools.sequenceIsReversedIdenticalBytes {
                    return .sameIf([.reversed])
                }

                // time complexity scoped: `O(1)`
                // time complexity so far: `O(n/2) + O(1)` <=> `O(n/2)`
                if s.bools.sequenceIsReversedIdenticalHex {
                    return .sameIf([.reversedHex])
                }

                if let sameIf = s.sameIf() {
                    return BytePattern.sameIf(sameIf)
                }

                return nil
            }
        }
    }
}

public extension FixedWidthInteger {
    static var byteCount: Int {
        bitWidth / 8
    }
}

extension Data {
    init<I>(integers: [I], bigEndian: Bool = false) where I: FixedWidthInteger {
        self = integers
            .map { bigEndian ? $0.bigEndian.data : $0.data }
            .reduce(Data()) { $0 + $1 }
    }
}

extension FixedWidthInteger {
    var hex: String {
        data.hex
    }
}
