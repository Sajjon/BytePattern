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
/// is the same as `.almostSame([reversed(entireSequenceAsBytes)]))`.
///
/// Another thing to note is that these mutations:
/// `.almostIdentical([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsBytes)])
/// would result in the `identity`, i.e. `identical`, and does not work for just `uint16` but for any int.
///
public struct PatternMatcher {
    public init() {}
}

public enum Pattern: Equatable, CustomStringConvertible {
    case identical
    case almostSame(AlmostSame)
    
    public var description: String {
        switch self {
        case .identical: return "identical"
        case .almostSame(let value): return "almostSame(\(value))"
        }
    }
}

public extension Pattern {
    struct AlmostSame: Equatable, ExpressibleByArrayLiteral, CustomStringConvertible {
        init(mutations: [Mutation]) {
            self.mutations = mutations
        }
        public typealias ArrayLiteralElement = Mutation
        public init(arrayLiteral mutations: ArrayLiteralElement...) {
            self.init(mutations: mutations)
        }
        private let mutations: [Mutation]
        public var description: String {
            "[" + mutations.map { String(describing: $0) }.joined(separator: ", ") + "]"
        }
    }
}

public extension Pattern {
    enum Mutation: Equatable, CustomStringConvertible {
        case endianessSwapped(for: IntegerType)
        case reversed(Reversed)
        
        public var description: String {
            switch self {
            case .endianessSwapped(let value): return "endianessSwapped(\(value))"
            case .reversed(let value): return "reversed(\(value))"
            }
        }
    }
}
public extension Pattern.Mutation {
    enum IntegerType: Equatable, CustomStringConvertible {
        case uint16, uint32, uint64
        init(byteCount: Int) {
            switch byteCount {
            case 2:
                self = .uint16
            case 4:
                self = .uint32
            case 8:
                self = .uint64
            default:
                fatalError("Invalid bytecount: \(byteCount)")
            }
        }
        public var description: String {
        switch self {
        case .uint16: return "uint16"
        case .uint32: return "uint32"
        case .uint64: return "uint64"
        }
        }
    }
    enum Reversed: Equatable, CustomStringConvertible {
        case orderOfIntegers(IntegerType)
        case entireSequenceAsBytes
        case entireSequenceAsHex
        public var description: String {
            switch self {
            case .orderOfIntegers(let value): return "orderOfIntegers(\(value))"
            case .entireSequenceAsBytes: return "entireSequenceAsBytes"
            case .entireSequenceAsHex: return "entireSequenceAsHex"
            }
        }
    }
}
precedencegroup BooleanCompoundAssigmentPrededence {
    lowerThan: ComparisonPrecedence
}
infix operator &&=: BooleanCompoundAssigmentPrededence
func &&=(lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}

public func circularRightShift(_ input: UInt8, _ amount: UInt8) -> UInt8 {
    let amount = amount % 8 // Reduce to the range 0...7
    return (input >> amount) | (input << (8 - amount))
}
public func inverseBits(of byte: UInt8) -> UInt8 {
    circularRightShift(byte, 4)
}

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
    
    fileprivate static var integerType: Pattern.Mutation.IntegerType {
        .init(byteCount: I.byteCount)
    }
    
    fileprivate func almostSame(`as` other: Self, expectedByteCountOfAllInts: Int) -> Pattern.AlmostSame? {
        Self._almostSame(self, as: other, expectedByteCountOfAllInts: expectedByteCountOfAllInts)
    }
    
    fileprivate static func _almostSame(_ lhs: Self, `as` rhs: Self, expectedByteCountOfAllInts: Int) -> Pattern.AlmostSame? {

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
       
        
        /// (
        ///     `dead beef 1234`,
        ///     `1234 beef dead`
        /// ) => `.almostIdentical([.reversed(.orderOfIntegers(.uint16)))`
        if let lhsNonInvertedLE, let rhsNonInvertedLE, lhsNonInvertedLE == .init(rhsNonInvertedLE.reversed()) {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.reversed(.orderOfIntegers(Self.integerType))]
        }
        
        if let lhsNonInvertedBE, let rhsNonInvertedLE, lhsNonInvertedBE == rhsNonInvertedLE {
            assert(lhsNonInvertedBE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.endianessSwapped(for: Self.integerType)]
        }
        
      
        if let lhsNonInvertedLE, let rhsNonInvertedBE, lhsNonInvertedLE == rhsNonInvertedBE {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.endianessSwapped(for: Self.integerType)]
        }
        
        if let lhsNonInvertedLE, let rhsNonInvertedBE, lhsNonInvertedLE == .init(rhsNonInvertedBE.reversed()) {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.endianessSwapped(for: Self.integerType), .reversed(.orderOfIntegers(Self.integerType))]
        }
        
        if let lhsNonInvertedLE, let rhsInvertedLE, lhsNonInvertedLE == rhsInvertedLE {
            assert(lhsNonInvertedLE.count * I.byteCount == expectedByteCountOfAllInts, "Too few integers inspected")
            return [.endianessSwapped(for: Self.integerType), .reversed(.orderOfIntegers(Self.integerType)), .reversed(.entireSequenceAsHex)]
        }
        
        return nil
    }
}

extension Storage {
    fileprivate func almostSame() -> Pattern.AlmostSame? {
        print("CHECKING U64 group:\n")
        if let mutation = lhs.u64Group.almostSame(as: rhs.u64Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
            return mutation
        }
        
        print("\n\nCHECKING U32 group:\n")
        if let mutation = lhs.u32Group.almostSame(as: rhs.u32Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
            return mutation
        }
        
        print("\n\nCHECKING U16 group:\n")
        if let mutation = lhs.u16Group.almostSame(as: rhs.u16Group, expectedByteCountOfAllInts: numberOfBytesHandled) {
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
}

public extension PatternMatcher {
    func find(
        between lhsContiguousBytes: some ContiguousBytes,
        and rhsContiguousBytes: some ContiguousBytes
    ) -> Pattern? {
        var s = Storage()
        
        // time complexity scoped: `O(n/2)`
        // time complexity so far: `O(n/2)`
        return lhsContiguousBytes.withUnsafeBytes { lhs -> Pattern? in
            rhsContiguousBytes.withUnsafeBytes { rhs -> Pattern? in
                print("pattern between:\nlhs:\(lhs.hex)\nrhs:\(rhs.hex)")
                guard lhs.count == rhs.count else {
                    return Pattern?.none
                }
                
                
                //.reduce(into: 0) { $0 |= $1.0 ^ $1.1 } == 0
                precondition(lhs.count.isMultiple(of: 2), "TODO handle odd length...")
                for byteOffsetLSB in 0..<(lhs.count)/2 {
                    let byteOffsetMSB = lhs.count - byteOffsetLSB - 1 // -1 because zero indexed...
                    let lhsLSB = lhs.load(fromByteOffset: byteOffsetLSB, as: UInt8.self)
                    let lhsMBS = lhs.load(fromByteOffset: byteOffsetMSB, as: UInt8.self)
                    let rhsLSB = rhs.load(fromByteOffset: byteOffsetLSB, as: UInt8.self)
                    let rhsMSB = rhs.load(fromByteOffset: byteOffsetMSB, as: UInt8.self)
                    print("byteOffsetLSB: \(byteOffsetLSB), byteOffsetMSB: \(byteOffsetMSB)\nlhsLSB: \(lhsLSB.hex)\nlhsMBS: \(lhsMBS.hex)\nrhsLSB: \(rhsLSB.hex)\nrhsMSB: \(rhsMSB.hex)")
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
                    return .almostSame([.reversed(.entireSequenceAsBytes)])
                }
                
                // time complexity scoped: `O(1)`
                // time complexity so far: `O(n/2) + O(1)` <=> `O(n/2)`
                if s.bools.sequenceIsReversedIdenticalHex {
                    return .almostSame([.reversed(.entireSequenceAsHex)])
                }
                
                if let almostSame = s.almostSame() {
                    return Pattern.almostSame(almostSame)
                }
             
                
               return nil
                
            }
        }
    }
}


extension FixedWidthInteger {
    static var byteCount: Int {
        bitWidth / 8
    }
}

func bytes<U: Integer>(
    _ contiguousBytes: some ContiguousBytes,
    into: U.Type,
    bigEndian: Bool = false
) -> [U]? {
    contiguousBytes.withUnsafeBytes { bytes in
        guard bytes.count >= U.byteCount else { return nil }
        guard bytes.count.isMultiple(of: U.byteCount) else { return nil }
        return bytes.chunks(ofCount: U.byteCount).map { chunk in
            chunk.withUnsafeBytes {
                $0.load(as: U.self)
            }
        }
        .map { bigEndian ? $0.bigEndian : $0 }
    }
    
}

extension Data {
    init<I>(integers: [I], bigEndian: Bool = false) where I: Integer {
        self = integers
            .map({ bigEndian ? $0.bigEndian.data : $0.data })
            .reduce(Data()) { $0 + $1 }
    }
}

public protocol Integer: FixedWidthInteger & Hashable { // & UnsignedInteger
    
}
extension UInt64: Integer {}
extension UInt32: Integer {}
extension UInt16: Integer {}

extension FixedWidthInteger {

    var hex: String {
        data.hex
    }
}
