//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

extension Storage {
    
    /// Set of booleans to check if `LHS` and `RHS` byte sequences are identical,
    /// identical if one is reversed, or reversed as hex string.
    struct Bools {
        
        /// A boolean indicating if `LHS` and `RHS` byte sequences equals each other, identical.
        internal private(set) var sequenceIsIdentical = true
        internal private(set) var sequenceIsReversedIdenticalBytes = true
        internal private(set) var sequenceIsReversedIdenticalHex = true
    }
}

// MARK: Update
extension Storage.Bools {
    mutating func update(lhsLSB: UInt8, rhsLSB: UInt8, rhsMSB: UInt8) {
        guard sequenceIsIdentical || sequenceIsReversedIdenticalBytes || sequenceIsReversedIdenticalHex else {
            return // already proved to not be identical/reversed/hex/bytes
        }
        sequenceIsIdentical &&= (lhsLSB == rhsLSB)
        sequenceIsReversedIdenticalBytes &&= lhsLSB == rhsMSB
        sequenceIsReversedIdenticalHex &&= lhsLSB == rotateBits(of: rhsMSB)
    }
}

// MARK: Query
extension Storage.Bools {
    func assertCorrectness() {
        switch (sequenceIsIdentical, sequenceIsReversedIdenticalHex, sequenceIsReversedIdenticalBytes) {
        case (true, true, true): break // valid, e.g. `0000` compared to `0000`
        case (true, false, false): break // valid
        case (false, true, false): break // valid
        case (false, false, true): break // valid
        case (false, false, false): break // valid
        default:
            fatalError("Invalid detection, sequenceIsIdentical: \(sequenceIsIdentical), sequenceIsReversedIdenticalHex: \(sequenceIsReversedIdenticalHex), sequenceIsReversedIdenticalBytes: \(sequenceIsReversedIdenticalBytes)")
        }
        // All good
    }
}
