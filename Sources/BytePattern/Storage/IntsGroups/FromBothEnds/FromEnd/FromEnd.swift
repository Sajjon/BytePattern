//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

extension Storage.IntsGroup.FromBothEnds {
    
    /// Integers from bytes read at `least signigicant byte` or at
    /// `most signigicant byte` end, stored both "as is", but also
    /// `rotated`, where each byte has been rotated (circular shifted) by
    /// 4 bits.
    struct FromEnd {
        private let isMostSignificantByteEnd: Bool
        /// Integers "as is", i.e. not rotated
        private(set) var nonRotated: Ints
        /// Integers "rotated",
        private(set) var rotated: Ints
        
        init(isMostSignificantByteEnd: Bool) {
            self.isMostSignificantByteEnd = isMostSignificantByteEnd
            self.nonRotated = .init(isMostSignificantByteEnd: isMostSignificantByteEnd)
            self.rotated = .init(isMostSignificantByteEnd: isMostSignificantByteEnd)
        }
        
    }
}

// MARK: Update
extension Storage.IntsGroup.FromBothEnds.FromEnd {
    mutating func update(
        nonRotatedByte: UInt8
    ) {
        nonRotated.concatenate(byte: nonRotatedByte)
        rotated.concatenate(byte: rotateBits(of: nonRotatedByte))
    }
}
