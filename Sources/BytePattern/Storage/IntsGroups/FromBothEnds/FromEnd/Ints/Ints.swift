//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

extension Storage.IntsGroup.FromBothEnds.FromEnd {
    
    /// Integers from bytes read at `least signigicant byte` or at
    /// `most signigicant byte` end.
    struct Ints {
       
        private let isMostSignificantByteEnd: Bool
        
        private(set) var bytes: [UInt8] = []
        private(set) var integersBigEndian: [I] = []
        private(set) var integersLittleEndian: [I] = []
      
        init(isMostSignificantByteEnd: Bool) {
            self.isMostSignificantByteEnd = isMostSignificantByteEnd
        }
    }
}

// MARK: Update
extension Storage.IntsGroup.FromBothEnds.FromEnd.Ints {
    /// Append or prepend bytes, depending on MSB or LSB.
    mutating func concatenate(byte: UInt8) {
        if isMostSignificantByteEnd {
            bytes.insert(byte, at: 0)
        } else {
            bytes.append(byte)
        }
        guard let (big, little) = _integersBigAndLittleEndian() else {
            return
        }
        
        bytes.removeAll()
        
        if isMostSignificantByteEnd {
            self.integersBigEndian.insert(big, at: 0)
            self.integersLittleEndian.insert(little, at: 0)
        } else {
            self.integersBigEndian.append(big)
            self.integersLittleEndian.append(little)
        }
    }
}

private extension Storage.IntsGroup.FromBothEnds.FromEnd.Ints {
    
    static func _integer(fromBytes bytes: inout [UInt8]) -> I? {
        guard bytes.count == I.byteCount else { return nil }
        return bytes.withUnsafeMutableBytes {
            $0.load(as: I.self)
        }
    }
    
    mutating func _integersBigAndLittleEndian() -> (big: I, little: I)? {
        Self.__integersBigAndLittleEndian(fromBytes: &self.bytes)
    }
    
  
}

// MARK: Query
extension Storage.IntsGroup.FromBothEnds.FromEnd.Ints {
    func integers(bigEndian: Bool) -> [I] {
        bigEndian ? integersBigEndian : integersLittleEndian
    }
    
    static func __integersBigAndLittleEndian(fromBytes bytes: inout [UInt8]) -> (big: I, little: I)? {
        guard let magnitude = _integer(fromBytes: &bytes) else {
            return nil
        }
        precondition(magnitude.littleEndian == magnitude)
        return (big: magnitude.bigEndian, little: magnitude)
    }
}
