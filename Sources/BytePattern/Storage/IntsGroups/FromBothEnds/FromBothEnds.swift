//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

extension Storage.IntsGroup {
    /// Memory loaded as `I` (`FixedWidthInteger`) integers read from most significant
    /// and least signigicant ends simultaneously. Keeps temporary copy of read bytes until
    /// byte count is `I.byteCount` (`I.bitWidth / 8`).
    struct FromBothEnds<I: FixedWidthInteger> {
        /// Integers from bytes read at `least signigicant byte` end. Keeps
        /// temporary copy of bytes read from LSB side, until byteCount is `I.byteCount`
        /// then an integer will be loaded and bytes array emptied.
        private(set) var leastSignificantByteEnd: FromEnd = .init(isMostSignificantByteEnd: false)

        /// Integers from bytes read at `most signigicant byte` end. Keeps
        /// temporary copy of bytes read from LSB side, until byteCount is `I.byteCount`
        /// then an integer will be loaded and bytes array emptied.
        private(set) var mostSignificantByteEnd: FromEnd = .init(isMostSignificantByteEnd: true)
    }
}

// MARK: Update

extension Storage.IntsGroup.FromBothEnds {
    mutating func update(
        leastSignificantByte lsb: UInt8,
        mostSignificantByte msb: UInt8
    ) {
        leastSignificantByteEnd.update(nonRotatedByte: lsb)
        mostSignificantByteEnd.update(nonRotatedByte: msb)
    }
}

// MARK: Query

extension Storage.IntsGroup.FromBothEnds {
    func __intInMiddle(keyPath: KeyPath<FromEnd, FromEnd.Ints>, bigEndian: Bool) -> [I] {
        // rotated or nonRotated, depends in `keyPath`
        let lsbIntegers = leastSignificantByteEnd[keyPath: keyPath]
        // rotated or nonRotated, depends in `keyPath`
        let msbIntegers = mostSignificantByteEnd[keyPath: keyPath]
        guard !lsbIntegers.bytes.isEmpty else {
            assert(msbIntegers.bytes.isEmpty)
            return []
        }
        assert(!msbIntegers.bytes.isEmpty)
        assert(lsbIntegers.bytes.count == msbIntegers.bytes.count)
        var bytes = lsbIntegers.bytes + msbIntegers.bytes
        guard let integers = FromEnd.Ints.__integersBigAndLittleEndian(fromBytes: &bytes) else {
            return []
        }
        if bigEndian {
            return [integers.big]
        } else {
            return [integers.little]
        }
    }

    func lsbConcatMSB(
        _ rotatedOrNotKeyPath: KeyPath<FromEnd, FromEnd.Ints>,
        bigEndian: Bool
    ) -> [I]? {
        let lsbEndInts = leastSignificantByteEnd[keyPath: rotatedOrNotKeyPath]
        let msbEndInts = mostSignificantByteEnd[keyPath: rotatedOrNotKeyPath]
        let lsbIntegers = lsbEndInts.integers(bigEndian: bigEndian)
        let msbIntegers = msbEndInts.integers(bigEndian: bigEndian)

        guard !lsbIntegers.isEmpty, !msbIntegers.isEmpty else {
            return nil
        }
        let maybeIntInMiddle = __intInMiddle(keyPath: rotatedOrNotKeyPath, bigEndian: bigEndian)
        return lsbIntegers + maybeIntInMiddle + msbIntegers
    }

    var rotatedBE: [I]? {
        lsbConcatMSB(\.rotated, bigEndian: true)
    }

    var rotatedLE: [I]? {
        lsbConcatMSB(\.rotated, bigEndian: false)
    }

    var nonRotatedBE: [I]? {
        lsbConcatMSB(\.nonRotated, bigEndian: true)
    }

    var nonRotatedLE: [I]? {
        lsbConcatMSB(\.nonRotated, bigEndian: false)
    }

    func sameIfRHS(as other: Self, expectedByteCountOfAllInts: Int) -> BytePattern.AlmostSame? {
        Self._almostSame(self, as: other, expectedByteCountOfAllInts: expectedByteCountOfAllInts)
    }

    fileprivate static func _almostSame(_ lhs: Self, as rhs: Self, expectedByteCountOfAllInts: Int) -> BytePattern.AlmostSame? {
        let lhsNonRotatedBE = lhs.nonRotatedBE
        let rhsNonRotatedLE = rhs.nonRotatedLE
        let lhsNonRotatedLE = lhs.nonRotatedLE
        let rhsNonRotatedBE = rhs.nonRotatedBE
//        let lhsRotatedBE = lhs.rotatedBE
//        let lhsRotatedLE = lhs.rotatedLE
//        let rhsRotatedBE = rhs.rotatedBE
        let rhsRotatedLE = rhs.rotatedLE

//        if let lhsNonRotatedBE {
//            print("lhsNonRotatedBE: " + lhsNonRotatedBE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let rhsNonRotatedLE {
//            print("rhsNonRotatedLE: " + rhsNonRotatedLE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let lhsNonRotatedLE {
//            print("lhsNonRotatedLE: " + lhsNonRotatedLE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let rhsNonRotatedBE {
//            print("rhsNonRotatedBE: " + rhsNonRotatedBE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let lhsRotatedBE {
//            print("lhsRotatedBE: " + lhsRotatedBE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let lhsRotatedLE {
//            print("lhsRotatedLE: " + lhsRotatedLE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let rhsRotatedBE {
//            print("rhsRotatedBE: " + rhsRotatedBE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }
//
//        if let rhsRotatedLE {
//            print("rhsRotatedLE: " + rhsRotatedLE.map { String($0, radix: 16) }.joined(separator: ", "))
//        }

        if let lhsNonRotatedLE, let rhsNonRotatedLE, lhsNonRotatedLE == .init(rhsNonRotatedLE.reversed()) {
            assert(lhsNonRotatedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount)]
        }

        if let lhsNonRotatedBE, let rhsNonRotatedLE, lhsNonRotatedBE == rhsNonRotatedLE {
            assert(lhsNonRotatedBE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount)]
        }

        if let lhsNonRotatedLE, let rhsNonRotatedBE, lhsNonRotatedLE == rhsNonRotatedBE {
            assert(lhsNonRotatedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount)]
        }

        if let lhsNonRotatedLE, let rhsNonRotatedBE, lhsNonRotatedLE == .init(rhsNonRotatedBE.reversed()) {
            assert(lhsNonRotatedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount), .asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount)]
        }

        if let lhsNonRotatedLE, let rhsRotatedLE, lhsNonRotatedLE == rhsRotatedLE {
            assert(lhsNonRotatedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount), .asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount), .reversedHex]
        }

        return nil
    }
}
