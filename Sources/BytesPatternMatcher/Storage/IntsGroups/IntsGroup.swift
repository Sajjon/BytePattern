//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

extension Storage {
    
    /// Integers loaded from memory of different bitWidth grouped together by bitwidth,
    /// read from most significant and least signigicant ends simultaneously. Keeps
    /// temporary copy of read bytes until byte count equals bitWidth of the integer
    /// each group is generic over.
    struct IntsGroup {
        
        /// Memory loaded as `UInt16` integers read from most significant
        /// and least signigicant ends simultaneously. Keeps temporary copy
        /// of read bytes until byte count is `2` (byte count of `UInt16`)
        private(set) var u16Group: FromBothEnds<UInt16> = .init()
        
        /// Memory loaded as `UInt32` integers read from most significant
        /// and least signigicant ends simultaneously. Keeps temporary copy
        /// of read bytes until byte count is `4` (byte count of `UInt32`)
        private(set) var u32Group: FromBothEnds<UInt32> = .init()
        
        /// Memory loaded as `UInt64` integers read from most significant
        /// and least signigicant ends simultaneously. Keeps temporary copy
        /// of read bytes until byte count is `8` (byte count of `UInt64`)
        private(set) var u64Group: FromBothEnds<UInt64> = .init()
    }
}

extension Storage.IntsGroup {
    mutating func update(
        leastSignificantByte lsb: UInt8,
        mostSignificantByte msb: UInt8
    ) {
        u16Group.update(leastSignificantByte: lsb, mostSignificantByte: msb)
        u32Group.update(leastSignificantByte: lsb, mostSignificantByte: msb)
        u64Group.update(leastSignificantByte: lsb, mostSignificantByte: msb)
    }
}
