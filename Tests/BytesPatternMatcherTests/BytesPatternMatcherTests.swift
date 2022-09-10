//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-08.
//
import XCTest
import Foundation
@testable import BytesPatternMatcher

final class BytesPatternMatcherTests: XCTestCase {
    fileprivate let sut = PatternMatcher()
    
    func testIdentical() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .identical
        )
    }
    
    func atestAlmostSameReversedSequenceAsBytesShort() throws {
        let lhs = try Data(hex: "ab12 cd34")
        let rhs = try Data(hex: "34cd 12ab")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.entireSequenceAsBytes)])
        )
    }
   
    func atestAlmostSameReversedSequenceAsBytes() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "defa edde 1209 baab 7856 3412 efbe adde")
        
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.entireSequenceAsBytes)])
        )
    }
    
    func test_reverse_bits_in_byte() {
        func invert(_ byte: UInt8) -> UInt8 {
            circularRightShift(byte, 4)
        }
        func s(_ uint8: UInt8) -> String {
            
            var bin = String(uint8, radix: 2)
            while bin.count < 8 {
                bin.insert("0", at: bin.startIndex)
            }
            
            return bin
        }
        func p(label: String, _ uint8: UInt8) {
            print("\(label)\t: \(s(uint8)) (0d\(uint8), 0x\(String(uint8, radix: 16)))")
        }
        func doTestMagic(invert toInvert: UInt8, expected: UInt8, line: UInt = #line) {
            let inverted = invert(toInvert)
            p(label: "toInvert", toInvert)
            p(label: "inverted", inverted)
            p(label: "expected", expected)
            XCTAssertEqual(
                inverted,
                expected,
                "inverted: \(s(inverted)) != \(s(expected)) (expected)",
                line: line
            )
        }
        /// `0x34` = `0d52` = `00110100`
        /// `0x43` = `0d67` = `01000011`
        doTestMagic(invert: 0x34, expected: 0x43)
    }
    
    func atestAlmostSameReversedSequenceAsHexShort() throws {
        let lhs = try Data(hex: "ab12 cd34")
        let rhs = try Data(hex: "43dc 21ba")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.entireSequenceAsHex)])
        )
    }
    
    func atestAlmostSameReversedSequenceAsHex() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "edaf deed 2190 abba 8765 4321 feeb daed")
        
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.entireSequenceAsHex)])
        )
    }
    
    func testAlmostSameReversedOrderOfIntegersUInt16EvenIntegerAmount() throws {
        let lhs = try Data(hex: "dead beef 1234 5678")
        let rhs = try Data(hex: "5678 1234 beef dead")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.orderOfIntegers(.uint16))])
        )
    }
    
    func testAlmostSameReversedOrderOfIntegersUInt16OddIntegerAmount() throws {
        let lhs = try Data(hex: "dead beef 1234")
        let rhs = try Data(hex: "1234 beef dead")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.reversed(.orderOfIntegers(.uint16))])
        )
    }
    
    func atestAlmostSameEndianessSwappedForUInt16Short() throws {
        let lhs = try Data(hex: "ab12 cd34")
        let rhs = try Data(hex: "12ab 34cd")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.endianessSwapped(for: .uint16)])
        )
    }
    func testAlmostSameEndianessSwappedForUInt16() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "adde efbe 3412 7856 baab 1209 edde defa")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.endianessSwapped(for: .uint16)])
        )
    }
    
    func testAlmostSameEndianessSwappedForUInt32() throws {
        let lhs = try Data(hex: "deadbeef 12345678 abba0912 deedfade")
        let rhs = try Data(hex: "efbeadde 78563412 1209baab defaedde")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.endianessSwapped(for: .uint32)])
        )
    }
    
    func testAlmostSameEndianessSwappedForUInt64() throws {
        let lhs = try Data(hex: "deadbeef12345678 abba0912deedfade")
        let rhs = try Data(hex: "78563412efbeadde defaedde1209baab")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.endianessSwapped(for: .uint64)])
        )
    }
    
    func testAlmostSameEndianessSwappedUInt16ReversedOrderOfIntegersReveresEntireSequenceAsHex() throws {
        let lhs = try Data(hex: "dead beef 1234")
        let rhs = try Data(hex: "edda ebfe 2143")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .almostSame([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers(.uint16)), .reversed(.entireSequenceAsHex)])
        )
    }
}
