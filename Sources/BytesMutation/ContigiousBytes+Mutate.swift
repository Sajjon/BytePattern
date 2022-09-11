//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Algorithms
import BytePattern
import Foundation

private extension ContiguousBytes {
    func into<I: FixedWidthInteger>(
        _: I.Type,
        bigEndian: Bool = false
    ) -> [I]? {
        withUnsafeBytes { bytes in
            guard bytes.count >= I.byteCount else { return nil }
            guard bytes.count.isMultiple(of: I.byteCount) else { return nil }
            return bytes.chunks(ofCount: I.byteCount).map { chunk in
                chunk.withUnsafeBytes {
                    $0.load(as: I.self)
                }
            }
            .map { bigEndian ? $0.bigEndian : $0 }
        }
    }

    func _reverseOrderOfUInt<I: FixedWidthInteger>(type _: I.Type) -> [UInt8] {
        into(I.self)!
            .reversed()
            .flatMap { $0.bigEndian.bytes }
    }

    func _swapEndianessOfUInt<I: FixedWidthInteger>(type _: I.Type) -> [UInt8] {
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

    func reverseOrderOfUInt16sFromBytes() -> [UInt8] {
        _reverseOrderOfUInt(type: UInt16.self)
    }

    func reverseOrderOfUInt32sFromBytes() -> [UInt8] {
        _reverseOrderOfUInt(type: UInt32.self)
    }

    func reverseOrderOfUInt64sFromBytes() -> [UInt8] {
        _reverseOrderOfUInt(type: UInt64.self)
    }

    func swapEndianessOfUInt16sFromBytes() -> [UInt8] {
        _swapEndianessOfUInt(type: UInt16.self)
    }

    func swapEndianessOfUInt32sFromBytes() -> [UInt8] {
        _swapEndianessOfUInt(type: UInt32.self)
    }

    func swapEndianessOfUInt64sFromBytes() -> [UInt8] {
        _swapEndianessOfUInt(type: UInt64.self)
    }
}
