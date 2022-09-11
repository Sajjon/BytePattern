//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation

/// An identified byte pattern shared between two sequences of bytes.
public enum BytePattern: Equatable, CustomStringConvertible {
    
    /// `LHS` and `RHS` byte sequences equal each other.
    case identical
    
    /// `LHS` and `RHS` byte sequences would equal each other if
    /// some mutations where made.
    case sameIf(AlmostSame)
}

public extension BytePattern {
    var description: String {
        switch self {
        case .identical: return "identical"
        case let .sameIf(value): return "sameIf(\(value))"
        }
    }
}

public extension BytePattern {
    
    /// An ordered list of mutations to be performed on one of the byte sequences for
    /// them to become identical (equal) to each other.
    struct AlmostSame: Equatable, ExpressibleByArrayLiteral, CustomStringConvertible {
        public let mutations: [Mutation]
       
        public init(mutations: [Mutation]) {
            self.mutations = mutations
        }
    }
}

public extension BytePattern.AlmostSame {
    
    typealias ArrayLiteralElement = BytePattern.Mutation
    
    init(arrayLiteral mutations: ArrayLiteralElement...) {
        self.init(mutations: mutations)
    }

    var description: String {
        "[" + mutations.map { String(describing: $0) }.joined(separator: ", ") + "]"
    }
}

public extension BytePattern {
    
    /// Different kind of mutations to be performed on one of the byte sequences for
    /// them to become identical (equal) to each other.
    enum Mutation: String, Equatable, CustomStringConvertible {
        
        /// Two byte sequences would be identical if one of them were reversed
        /// in its entirety.
        case reversed

        /// Two byte sequences would be identical if one of them were initialized
        /// from a hex string that was revered before passed to byte sequence init.
        ///
        /// Or in otherwords, if every byte in one of the sequences were
        /// [rotated (ciruclar shifted)][wiki] by 4 bits. This operator is not part of the
        /// standard library but is implemented by: `(input >> 4) | (input << 4)`.
        ///
        /// [wiki]: https://en.wikipedia.org/wiki/Bitwise_operation#Rotate
        case reversedHex
        
        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length two, i.e. as if loaded `UInt16` at start of each
        /// segment, and then this list of integers were reversed.
        case reverseOrderOfUInt16sFromBytes
        
        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length four, i.e. as if loaded `UInt32` at start of each
        /// segment, and then this list of integers were reversed.
        case reverseOrderOfUInt32sFromBytes
        
        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length eight, i.e. as if loaded `UInt64` at start of each
        /// segment, and then this list of integers were reversed.
        case reverseOrderOfUInt64sFromBytes

        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length two, i.e. as if loaded `UInt16` and we were
        /// to swap endianness of each integer in this list.
        case swapEndianessOfUInt16sFromBytes
        
        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length four, i.e. as if loaded `UInt32` and we were
        /// to swap endianness of each integer in this list.
        case swapEndianessOfUInt32sFromBytes
        
        /// Two byte sequences would be identical if one of them were "chunked"
        /// into segments of length eight, i.e. as if loaded `UInt64` and we were
        /// to swap endianness of each integer in this list.
        case swapEndianessOfUInt64sFromBytes
    }
}

public extension BytePattern.Mutation {
    
    var description: String {
        rawValue
    }
}

internal extension BytePattern.Mutation {
   
    static func asSegmentsOfUIntButReversedOrder(uintByteCount: Int) -> Self {
        switch uintByteCount {
        case 2:
            return .reverseOrderOfUInt16sFromBytes
        case 4:
            return .reverseOrderOfUInt32sFromBytes
        case 8:
            return .reverseOrderOfUInt64sFromBytes
        default:
            fatalError("Bad bytecount: \(uintByteCount)")
        }
    }

    static func asSegmentsOfUIntButEndianessSwapped(uintByteCount: Int) -> Self {
        switch uintByteCount {
        case 2:
            return .swapEndianessOfUInt16sFromBytes
        case 4:
            return .swapEndianessOfUInt32sFromBytes
        case 8:
            return .swapEndianessOfUInt64sFromBytes
        default:
            fatalError("Bad bytecount: \(uintByteCount)")
        }
    }
}
