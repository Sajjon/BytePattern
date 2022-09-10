//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation
import BytesPatternMatcher
import Algorithms

private extension ContiguousBytes {
   
    func into<U: FixedWidthInteger>(
        _ intType: U.Type,
        bigEndian: Bool = false
    ) -> [U]? {
        withUnsafeBytes { bytes in
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
    
    func _asSegmentsOfUIntButReversedOrder<I: FixedWidthInteger>(uIntType: I.Type) -> [UInt8] {
        into(I.self)!
            .reversed()
            .flatMap { $0.bigEndian.bytes }
    }
   
    func _asSegmentsOfUIntButEndianessSwapped<I: FixedWidthInteger>(uIntType: I.Type) -> [UInt8] {
        into(I.self)!
        .flatMap { $0.littleEndian.bytes }
    }
}

public extension ContiguousBytes {

    func reversed() -> [UInt8] {
        var bytesCopy = bytes
        bytesCopy.reverse()
        return bytesCopy
    }
    
    func reversedHex() -> [UInt8] {
        reversed()
            .compactMap {
                UInt8(
                    String(String($0, radix: 16).reversed()),
                    radix: 16
                )
            }
    }

    func asSegmentsOfUInt16ButReversedOrder() -> [UInt8] {
        _asSegmentsOfUIntButReversedOrder(uIntType: UInt16.self)
    }
    
    func asSegmentsOfUInt32ButReversedOrder() -> [UInt8] {
        _asSegmentsOfUIntButReversedOrder(uIntType: UInt32.self)
    }
    
    func asSegmentsOfUInt64ButReversedOrder() -> [UInt8] {
        _asSegmentsOfUIntButReversedOrder(uIntType: UInt64.self)
    }
    
 
    func asSegmentsOfUInt16ButEndianessSwapped() -> [UInt8] {
        _asSegmentsOfUIntButEndianessSwapped(uIntType: UInt16.self)
    }
    
    func asSegmentsOfUInt32ButEndianessSwapped() -> [UInt8] {
        _asSegmentsOfUIntButEndianessSwapped(uIntType: UInt32.self)
    }
    
    func asSegmentsOfUInt64ButEndianessSwapped() -> [UInt8] {
        _asSegmentsOfUIntButEndianessSwapped(uIntType: UInt64.self)
    }
}
