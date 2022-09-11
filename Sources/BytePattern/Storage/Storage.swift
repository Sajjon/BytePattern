//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation

/// Storage for bytes pattern finder algorithm. Primarily integer groups are stored which
/// load bytes as integers after sufficiently many bytes have been parsed. This storage
/// modelled to be traversing input LHS and RHS Contigious bytes in both ends
/// simultaneously, i.e. the BytePatternFinder ought to look at the most signigicant and
/// the least significant byte of LHS and RHS simultaneously.
struct Storage {
    var numberOfBytesHandled = 0
    internal private(set) var bools: Bools = .init()
    private(set) var lhs: IntsGroup = .init()
    private(set) var rhs: IntsGroup = .init()
}

// MARK: Update

extension Storage {
    mutating func update(
        lhsLSB: UInt8,
        lhsMSB: UInt8,
        rhsLSB: UInt8,
        rhsMSB: UInt8
    ) {
        numberOfBytesHandled += 2
        bools.update(lhsLSB: lhsLSB, rhsLSB: rhsLSB, rhsMSB: rhsMSB)
        lhs.update(leastSignificantByte: lhsLSB, mostSignificantByte: lhsMSB)
        rhs.update(leastSignificantByte: rhsLSB, mostSignificantByte: rhsMSB)
    }
}

// MARK: Query

extension Storage {
    func assertCorrectness() {
        bools.assertCorrectness()
    }

    func sameIfRHS() -> BytePattern.AlmostSame? {
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
