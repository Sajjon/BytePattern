import Foundation
import Algorithms

/// A pattern matcher for bytes, useful to discover that two bytes seqences
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
/// ) => `.almostIdentical([.entireReveresed(.entireSequenceAsHex)])`
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `defa edde 1209 baab 7856 3412 efbe adde`
/// ) => `.almostIdentical([.reversed(.entireSequenceAsBytes)])`
///
/// (
///     `dead beef 1234`,
///     `1234 beef dead`
/// ) => `.almostIdentical([.reversed(.orderOfIntegers(.uint16)))`
///
/// (
///     `dead beef 1234 5678 abba 0912 deed fade`,
///     `adde efbe 3412 7856 baab 1209 edde defa`
/// ) => `.almostIdentical([.endianessSwapped(for: .uint16)])`
///
/// (
///     `deadbeef 12345678 abba0912 deedfade`, // grouped 4 bytes together
///     `efbeadde 78563412 1209baab defaedde`
/// ) => `.almostIdentical([.endianessSwapped(for: .uint32)])`
///
/// (
///     `deadbeef12345678 abba0912deedfade`, // grouped 8 bytes together
///     `78563412efbeadde defaedde1209baab`
/// ) => `.almostIdentical([.endianessSwapped(for: .uint64)])`
///
///
/// (
///     `dead beef 1234`,
///     `edda ebfe 2143`
/// ) => `.almostIdentical([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsHex)])`
///
/// One thing to note is that these mutations:
/// `.almostIdentical([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers)])``
/// is the same as `.sameIfRHS([reversed(entireSequenceAsBytes)]))`.
///
/// Another thing to note is that these mutations:
/// `.almostIdentical([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsBytes)])
/// would result in the `identity`, i.e. `identical`, and does not work for just `uint16` but for any int.
///
public struct BytesPatternMatcher {
    public init() {}
}

public extension BytesPatternMatcher {
    func find(
        between lhsContiguousBytes: some ContiguousBytes,
        and rhsContiguousBytes: some ContiguousBytes
    ) -> BytesPattern? {
        var s = Storage()
        
        // time complexity scoped: `O(n/2)`
        // time complexity so far: `O(n/2)`
        return lhsContiguousBytes.withUnsafeBytes { lhs -> BytesPattern? in
            rhsContiguousBytes.withUnsafeBytes { rhs -> BytesPattern? in
                guard lhs.count == rhs.count else {
                    return BytesPattern?.none
                }
                
                precondition(lhs.count.isMultiple(of: 2), "TODO handle odd length...")

                for byteOffsetLSB in 0..<(lhs.count)/2 {
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
                    return .sameIfRHS([.reversed])
                }
                
                // time complexity scoped: `O(1)`
                // time complexity so far: `O(n/2) + O(1)` <=> `O(n/2)`
                if s.bools.sequenceIsReversedIdenticalHex {
                    return .sameIfRHS([.reversedHex])
                }
                
                if let sameIfRHS = s.sameIfRHS() {
                    return BytesPattern.sameIfRHS(sameIfRHS)
                }
                
                return nil
            }
        }
    }
}


extension FixedWidthInteger {
    public static var byteCount: Int {
        bitWidth / 8
    }
}

extension Data {
    init<I>(integers: [I], bigEndian: Bool = false) where I: FixedWidthInteger {
        self = integers
            .map({ bigEndian ? $0.bigEndian.data : $0.data })
            .reduce(Data()) { $0 + $1 }
    }
}

extension FixedWidthInteger {
    
    var hex: String {
        data.hex
    }
}
