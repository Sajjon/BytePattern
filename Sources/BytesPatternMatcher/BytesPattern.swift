//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation

public enum BytesPattern: Equatable, CustomStringConvertible {
    case identical
    case sameIfRHS(AlmostSame)
}

public extension BytesPattern {
    var description: String {
        switch self {
        case .identical: return "identical"
        case .sameIfRHS(let value): return "sameIfRHS(\(value))"
        }
    }
}

public extension BytesPattern {
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

public extension BytesPattern {
    enum Mutation: String, Equatable, CustomStringConvertible {
        case reversed
        case reversedHex
        case asSegmentsOfUInt16ButReversedOrder
        case asSegmentsOfUInt32ButReversedOrder
        case asSegmentsOfUInt64ButReversedOrder
        
        case asSegmentsOfUInt16ButEndianessSwapped
        case asSegmentsOfUInt32ButEndianessSwapped
        case asSegmentsOfUInt64ButEndianessSwapped
   
        
        public var description: String {
            rawValue
        }
        
        static func asSegmentsOfUIntButReversedOrder(uintByteCount: Int) -> Self {
            switch uintByteCount {
            case 2:
                return .asSegmentsOfUInt16ButReversedOrder
            case 4:
                return .asSegmentsOfUInt32ButReversedOrder
            case 8:
                return .asSegmentsOfUInt64ButReversedOrder
            default:
                fatalError("Bad bytecount: \(uintByteCount)")
            }
        }
        static func asSegmentsOfUIntButEndianessSwapped(uintByteCount: Int) -> Self {
            switch uintByteCount {
            case 2:
                return .asSegmentsOfUInt16ButEndianessSwapped
            case 4:
                return .asSegmentsOfUInt32ButEndianessSwapped
            case 8:
                return .asSegmentsOfUInt64ButEndianessSwapped
            default:
                fatalError("Bad bytecount: \(uintByteCount)")
            }
        }
    }
}
