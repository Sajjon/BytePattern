//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation

struct Storage {
    var numberOfBytesHandled = 0
    internal private(set) var bools: Bools = .init()
    private(set) var lhs: FromEnd = .init()
    private(set) var rhs: FromEnd = .init()
}

extension Storage {
    
    struct FromEnd {
     
        struct IntGroup<I: Integer> {
         
            struct Bytes {
                struct Group {
                    private let isMSB: Bool
                    private(set) var bytes: [UInt8] = []
                    private(set) var integersBigEndian: [I] = []
                    private(set) var integersLittleEndian: [I] = []
                    init(isMSB: Bool) {
                        self.isMSB = isMSB
                    }
                }
                private let isMSB: Bool
                /// Non inverted
                private(set) var nonInverted: Group
                /// Inverted
                private(set) var inverted: Group
                
                init(isMSB: Bool) {
                    self.isMSB = isMSB
                    self.nonInverted = .init(isMSB: isMSB)
                    self.inverted = .init(isMSB: isMSB)
                }
              
            }
            private(set) var lsb: Bytes = .init(isMSB: false)
            private(set) var msb: Bytes = .init(isMSB: true)
        }
        private(set) var u16Group: IntGroup<UInt16> = .init()
        private(set) var u32Group: IntGroup<UInt32> = .init()
        private(set) var u64Group: IntGroup<UInt64> = .init()
    }
}

extension Storage.FromEnd.IntGroup {
    
    func __intInMiddle(keyPath: KeyPath<Bytes, Bytes.Group>, bigEndian: Bool) -> [I] {
        // inverted or nonInverted, depends in `keyPath`
        let lsbGroup: Bytes.Group = lsb[keyPath: keyPath]
        // inverted or nonInverted, depends in `keyPath`
        let msbGroup: Bytes.Group = msb[keyPath: keyPath]
        guard !lsbGroup.bytes.isEmpty else {
            assert(msbGroup.bytes.isEmpty)
            return []
        }
        assert(!msbGroup.bytes.isEmpty)
        assert(lsbGroup.bytes.count == msbGroup.bytes.count)
        var bytes = lsbGroup.bytes + msbGroup.bytes
        guard let integers = Bytes.Group.__integersBigAndLittleEndian(fromBytes: &bytes) else {
            return []
        }
        if bigEndian {
            return [integers.big]
        } else {
            return [integers.little]
        }
    }
    
    func _intInMiddleNonInverted(bigEndian: Bool) -> [I] {
        __intInMiddle(keyPath: \.nonInverted, bigEndian: bigEndian)
    }
    func _intInMiddleInverted(bigEndian: Bool) -> [I] {
        __intInMiddle(keyPath: \.inverted, bigEndian: bigEndian)
    }
    
    var invertedBE: [I]? {
        guard !lsb.inverted.integersBigEndian.isEmpty, !msb.inverted.integersBigEndian.isEmpty else {
            return nil
        }
        let maybeIntInMiddle = _intInMiddleInverted(bigEndian: true)
        return lsb.inverted.integersBigEndian + maybeIntInMiddle + msb.inverted.integersBigEndian
    }
   
    var invertedLE: [I]? {
        guard !lsb.inverted.integersLittleEndian.isEmpty, !msb.inverted.integersLittleEndian.isEmpty else {
            return nil
        }
        let maybeIntInMiddle = _intInMiddleInverted(bigEndian: false)
        return lsb.inverted.integersLittleEndian + maybeIntInMiddle + msb.inverted.integersLittleEndian
    }
   
    var nonInvertedBE: [I]? {
        guard !lsb.nonInverted.integersBigEndian.isEmpty, !msb.nonInverted.integersBigEndian.isEmpty else {
            return nil
        }
        let maybeIntInMiddle = _intInMiddleNonInverted(bigEndian: true)
        return lsb.nonInverted.integersBigEndian + maybeIntInMiddle + msb.nonInverted.integersBigEndian
    }
    
    var nonInvertedLE: [I]? {
        guard !lsb.nonInverted.integersLittleEndian.isEmpty, !msb.nonInverted.integersLittleEndian.isEmpty else {
            return nil
        }
        let maybeIntInMiddle = _intInMiddleNonInverted(bigEndian: false)
        return lsb.nonInverted.integersLittleEndian + maybeIntInMiddle + msb.nonInverted.integersLittleEndian
    }
    
    
    fileprivate func sameIfRHS(`as` other: Self, expectedByteCountOfAllInts: Int) -> BytesPattern.AlmostSame? {
        Self._almostSame(self, as: other, expectedByteCountOfAllInts: expectedByteCountOfAllInts)
    }
    
    fileprivate static func _almostSame(_ lhs: Self, `as` rhs: Self, expectedByteCountOfAllInts: Int) -> BytesPattern.AlmostSame? {

        let lhsNonInvertedBE = lhs.nonInvertedBE
        let rhsNonInvertedLE = rhs.nonInvertedLE
        let lhsNonInvertedLE = lhs.nonInvertedLE
        let rhsNonInvertedBE = rhs.nonInvertedBE
        let lhsInvertedBE = lhs.invertedBE
        let lhsInvertedLE = lhs.invertedLE
        let rhsInvertedBE = rhs.invertedBE
        let rhsInvertedLE = rhs.invertedLE
        
        if let lhsNonInvertedBE {
            print("lhsNonInvertedBE: " + lhsNonInvertedBE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let rhsNonInvertedLE {
            print("rhsNonInvertedLE: " + rhsNonInvertedLE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let lhsNonInvertedLE {
            print("lhsNonInvertedLE: " + lhsNonInvertedLE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let rhsNonInvertedBE {
            print("rhsNonInvertedBE: " + rhsNonInvertedBE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let lhsInvertedBE {
            print("lhsInvertedBE: " + lhsInvertedBE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let lhsInvertedLE {
            print("lhsInvertedLE: " + lhsInvertedLE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        if let rhsInvertedBE {
            print("rhsInvertedBE: " + rhsInvertedBE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        
        if let rhsInvertedLE {
            print("rhsInvertedLE: " + rhsInvertedLE.map { String($0, radix: 16) }.joined(separator: ", "))
        }
        
        if let lhsNonInvertedLE, let rhsNonInvertedLE, lhsNonInvertedLE == .init(rhsNonInvertedLE.reversed()) {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount)]
        }
        
        if let lhsNonInvertedBE, let rhsNonInvertedLE, lhsNonInvertedBE == rhsNonInvertedLE {
            assert(lhsNonInvertedBE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount)]
        }
        
      
        if let lhsNonInvertedLE, let rhsNonInvertedBE, lhsNonInvertedLE == rhsNonInvertedBE {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount)]
        }
        
        if let lhsNonInvertedLE, let rhsNonInvertedBE, lhsNonInvertedLE == .init(rhsNonInvertedBE.reversed()) {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount), .asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount)]
        }
        
        if let lhsNonInvertedLE, let rhsInvertedLE, lhsNonInvertedLE == rhsInvertedLE {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.asSegmentsOfUIntButEndianessSwapped(uintByteCount: I.byteCount), .asSegmentsOfUIntButReversedOrder(uintByteCount: I.byteCount), .reversedHex]
        }
        
        return nil
    }
}

extension Storage {
    func sameIfRHS() -> BytesPattern.AlmostSame? {
        if let mutation = lhs.u64Group.sameIfRHS(as: rhs.u64Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
            return mutation
        }
        
        if let mutation = lhs.u32Group.sameIfRHS(as: rhs.u32Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
            return mutation
        }
        
        if let mutation = lhs.u16Group.sameIfRHS(as: rhs.u16Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
            return mutation
        }

        return nil
    }
}

extension Storage.FromEnd.IntGroup.Bytes.Group {

    static func _integer(fromBytes bytes: inout [UInt8]) -> I? {
        guard bytes.count == I.byteCount else { return nil }
        return bytes.withUnsafeMutableBytes {
            $0.load(as: I.self)
        }
    }
   
    mutating func _integersBigAndLittleEndian() -> (big: I, little: I)? {
        Self.__integersBigAndLittleEndian(fromBytes: &self.bytes)
    }
   
    static func __integersBigAndLittleEndian(fromBytes bytes: inout [UInt8]) -> (big: I, little: I)? {
        guard let magnitude = _integer(fromBytes: &bytes) else {
            return nil
        }
        precondition(magnitude.littleEndian == magnitude)
        return (big: magnitude.bigEndian, little: magnitude)
    }
    
    /// Append or prepend bytes, depending on MSB or LSB.
    mutating func concatenate(byte: UInt8) {
        if isMSB {
            bytes.insert(byte, at: 0)
        } else {
            bytes.append(byte)
        }
        guard let (big, little) = _integersBigAndLittleEndian() else {
            return
        }
        bytes.removeAll()

        
        if isMSB {
            self.integersBigEndian.insert(big, at: 0)
            self.integersLittleEndian.insert(little, at: 0)
        } else {
            self.integersBigEndian.append(big)
            self.integersLittleEndian.append(little)
        }
    }
}

extension Storage.FromEnd {
    mutating func update(
        lsb: UInt8,
        msb: UInt8
    ) {
        u16Group.update(lsb: lsb, msb: msb)
        u32Group.update(lsb: lsb, msb: msb)
        u64Group.update(lsb: lsb, msb: msb)
    }
}

extension Storage.FromEnd.IntGroup {
    mutating func update(
        lsb lsbByte: UInt8,
        msb msbByte: UInt8
    ) {
        lsb.update(nonInvertedByte: lsbByte)
        msb.update(nonInvertedByte: msbByte)
        
    }
}

extension Storage.FromEnd.IntGroup.Bytes {
    mutating func update(
        nonInvertedByte: UInt8
    ) {
        nonInverted.concatenate(byte: nonInvertedByte)
        inverted.concatenate(byte: inverseBits(of: nonInvertedByte))
    }
}
 
extension Storage {
    mutating func update(
        lhsLSB: UInt8,
        lhsMSB: UInt8,
        rhsLSB: UInt8,
        rhsMSB: UInt8
    ) {
        numberOfBytesHandled += 2
        bools.update(lhsLSB: lhsLSB, rhsLSB: rhsLSB, rhsMSB: rhsMSB)
        lhs.update(lsb: lhsLSB, msb: lhsMSB)
        rhs.update(lsb: rhsLSB, msb: rhsMSB)
    }
    
    func assertCorrectness() {
        bools.assertCorrectness()
    }
    
}

extension Storage {
    struct Bools {
        internal private(set) var sequenceIsIdentical = true
        internal private(set) var sequenceIsReversedIdenticalBytes = true
        internal private(set) var sequenceIsReversedIdenticalHex = true
    }
}

extension Storage.Bools {
    mutating func update(lhsLSB: UInt8, rhsLSB: UInt8, rhsMSB: UInt8) {
        guard sequenceIsIdentical || sequenceIsReversedIdenticalBytes || sequenceIsReversedIdenticalHex else {
            return // already proved to not be identical/reversed/hex/bytes
        }
        sequenceIsIdentical &&= (lhsLSB == rhsLSB)
        sequenceIsReversedIdenticalBytes &&= lhsLSB == rhsMSB
        sequenceIsReversedIdenticalHex &&= lhsLSB == inverseBits(of: rhsMSB)
    }
    
    func assertCorrectness() {
        switch (sequenceIsIdentical, sequenceIsReversedIdenticalHex, sequenceIsReversedIdenticalBytes) {
        case (true, false, false): break // valid
        case (false, true, false): break // valid
        case (false, false, true): break // valid
        case (false, false, false): break // valid
        default:
            assertionFailure("Invalid detection, sequenceIsIdentical: \(sequenceIsIdentical), sequenceIsReversedIdenticalHex: \(sequenceIsReversedIdenticalHex), sequenceIsReversedIdenticalBytes: \(sequenceIsReversedIdenticalBytes)")
        }
        // All good
    }
}
