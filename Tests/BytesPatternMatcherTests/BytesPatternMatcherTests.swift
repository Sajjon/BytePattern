//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-08.
//
import XCTest
import Foundation
import BytesMutation
import BytesPatternMatcher

final class BytesPatternMatcherTests: XCTestCase {
  
    fileprivate let sut = BytesPatternMatcher()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
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
    
    func test_identical() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        XCTAssertEqual(
            sut.find(between: lhs, and: rhs),
            .identical
        )
    }
    
    func test_sameIfRHS_reversed_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "34cd 12ab",
            expectedPattern: .sameIfRHS([.reversed])
        ) { rhs in
            rhs.reversed()
        }
    }

    func test_sameIfRHS_reversed() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "defa edde 1209 baab 7856 3412 efbe adde",
            expectedPattern: .sameIfRHS([.reversed])
        ) { rhs in
            rhs.reversed()
        }
    }
 

    func test_sameIfRHS_reversedHex_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "43dc 21ba",
            expectedPattern: .sameIfRHS([.reversedHex])
        ) { rhs in
            rhs.reversedHex()
        }
    }

    func test_sameIfRHS_reversedHex() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "edaf deed 2190 abba 8765 4321 feeb daed",
            expectedPattern: .sameIfRHS([.reversedHex])
        ) { rhs in
            rhs.reversedHex()
        }
    }
 
    func test_sameIfRHS_asSegmentsOfUInt16ButReversedOrder_even_number_of_uint16() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678",
            rhs: "5678 1234 beef dead",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt16ButReversedOrder])
        ) { rhs in
            rhs.asSegmentsOfUInt16ButReversedOrder()
        }
    }

    func test_sameIfRHS_asSegmentsOfUInt16ButReversedOrder_odd_number_of_uint16() throws {
        try doTestHex(
            lhs: "dead beef 1234",
            rhs: "1234 beef dead",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt16ButReversedOrder])
        ) { rhs in
            rhs.asSegmentsOfUInt16ButReversedOrder()
        }
    }

    func test_sameIfRHS_asSegmentsOfUInt16ButEndianessSwapped_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "12ab 34cd",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped])
        ) { rhs in
            rhs.asSegmentsOfUInt16ButEndianessSwapped()
        }
    }
 
    func test_sameIfRHS_asSegmentsOfUInt16ButEndianessSwapped() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "adde efbe 3412 7856 baab 1209 edde defa",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped])
        ) { rhs in
            rhs.asSegmentsOfUInt16ButEndianessSwapped()
        }
    }
   
    func test_sameIfRHS_asSegmentsOfUInt32ButEndianessSwapped() throws {
        try doTestHex(
            lhs: "deadbeef 12345678 abba0912 deedfade",
            rhs: "efbeadde 78563412 1209baab defaedde",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt32ButEndianessSwapped])
        ) { rhs in
            rhs.asSegmentsOfUInt32ButEndianessSwapped()
        }
    }
    

    func test_sameIfRHS__asSegmentsOfUInt64ButEndianessSwapped() throws {

        try doTestHex(
            lhs: "deadbeef12345678 abba0912deedfade",
            rhs: "78563412efbeadde defaedde1209baab",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt64ButEndianessSwapped])
        ) { rhs in
            rhs.asSegmentsOfUInt64ButEndianessSwapped()
        }
    }
    
    func test_sameIfRHS_asSegmentsOfUInt16ButEndianessSwapped_asSegmentsOfUInt16ButReversedOrder_reversedHex() throws {
        try doTestHex(
            lhs: "dead beef 1234",
            rhs: "edda ebfe 2143",
            expectedPattern: .sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped, .asSegmentsOfUInt16ButReversedOrder, .reversedHex])
        ) { rhs in
            rhs
                .asSegmentsOfUInt16ButEndianessSwapped()
                .asSegmentsOfUInt16ButReversedOrder()
                .reversedHex()
        }
    }
}

extension BytesPatternMatcherTests {
    func doTest<RHS: ContiguousBytes>(
        lhs: some ContiguousBytes,
        rhs: RHS,
        expectedPattern: BytesPattern,
        line: UInt = #line,
        mutateRHS: (RHS) -> some ContiguousBytes
    ) throws {
        let pattern = sut.find(between: lhs, and: rhs)
        XCTAssertEqual(
           pattern,
           expectedPattern,
           "Found pattern does not match expected, found: \(String(describing: pattern)), expected: \(expectedPattern)",
           line: line
        )
        let mutatedRHS = mutateRHS(rhs)
        lhs.withUnsafeBytes { lhsBytes in
            mutatedRHS.withUnsafeBytes { mutatedRHSBytes in
                XCTAssertTrue(
                    safeCompare(lhsBytes, mutatedRHSBytes),
                    "expected LHS \(lhsBytes.hex) to equal \(mutatedRHSBytes.hex) but they are not equal.",
                    line: line
                )
            }
        }
    }
    
    
    func doTestHex(
        lhs: String,
        rhs: String,
        expectedPattern: BytesPattern,
        line: UInt = #line,
        mutateRHS: @escaping (any ContiguousBytes) -> some ContiguousBytes
    ) throws {
        try doTest(
            lhs: Data(hex: lhs),
            rhs: Data(hex: rhs),
            expectedPattern: expectedPattern,
            line: line,
            mutateRHS: mutateRHS
        )
    }
}
