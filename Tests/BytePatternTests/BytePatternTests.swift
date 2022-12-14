//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-08.
//
import BytePattern
import BytesMutation
import Foundation
import XCTest
import XCTAssertBytesEqual

final class BytePatternTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    fileprivate let sut = BytePatternFinder()
    
    func test_all_zero() throws {
        let pattern = try sut.find(lhs: Data(hex: "0000"), rhs: Data(hex: "0000"))
        XCTAssertEqual(pattern, .identical)
    }
    
    func test_reverse_bits_in_byte() {
        func s(_ uint8: UInt8, radix: Int = 2) -> String {
            var bin = String(uint8, radix: radix)
            while bin.count < ((8/radix)*2) {
                bin.insert("0", at: bin.startIndex)
            }
            
            return bin
        }
        
        func doTestMagic(
            rotate toRotate: UInt8,
            expected: UInt8,
            line: UInt = #line
        ) {
            let rotated = rotateBits(of: toRotate)
            XCTAssertEqual(
                rotated,
                expected,
                "rotated: 0b: \(s(rotated)) != \(s(expected)) (expected), 0x \(s(rotated, radix: 16)) != \(s(expected, radix: 16)) (expected)",
                line: line
            )
        }
        /// `0x34` = `0d52` = `00110100`
        /// `0x43` = `0d67` = `01000011`
        doTestMagic(rotate: 0x34, expected: 0x43)
        
    }
    
    func test_identical() throws {
        let lhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        let rhs = try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
        XCTAssertEqual(
            sut.find(lhs: lhs, rhs: rhs),
            .identical
        )
    }
    
    func test_sameIf_reversed_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "34cd 12ab",
            expectedPattern: .sameIf([.reversed])
        ) { rhs in
            rhs.reversed()
        }
    }
    
    func test_sameIf_reversed() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "defa edde 1209 baab 7856 3412 efbe adde",
            expectedPattern: .sameIf([.reversed])
        ) { rhs in
            rhs.reversed()
        }
    }
    
    func test_sameIf_reversedHex_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "43dc 21ba",
            expectedPattern: .sameIf([.reversedHex])
        ) { rhs in
            rhs.reversedHex()
        }
    }
    
    func test_sameIf_reversedHex() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "edaf deed 2190 abba 8765 4321 feeb daed",
            expectedPattern: .sameIf([.reversedHex])
        ) { rhs in
            rhs.reversedHex()
        }
    }
    
    func test_sameIf_reverseOrderOfUInt16sFromBytes_even_number_of_uint16() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678",
            rhs: "5678 1234 beef dead",
            expectedPattern: .sameIf([.reverseOrderOfUInt16sFromBytes])
        ) { rhs in
            rhs.reverseOrderOfUInt16sFromBytes()
        }
    }
    
    func test_sameIf_reverseOrderOfUInt16sFromBytes_odd_number_of_uint16() throws {
        try doTestHex(
            lhs: "dead beef 1234",
            rhs: "1234 beef dead",
            expectedPattern: .sameIf([.reverseOrderOfUInt16sFromBytes])
        ) { rhs in
            rhs.reverseOrderOfUInt16sFromBytes()
        }
    }
    
    func test_sameIf_swapEndianessOfUInt16sFromBytes_short() throws {
        try doTestHex(
            lhs: "ab12 cd34",
            rhs: "12ab 34cd",
            expectedPattern: .sameIf([.swapEndianessOfUInt16sFromBytes])
        ) { rhs in
            rhs.swapEndianessOfUInt16sFromBytes()
        }
    }
    
    func test_sameIf_swapEndianessOfUInt16sFromBytes() throws {
        try doTestHex(
            lhs: "dead beef 1234 5678 abba 0912 deed fade",
            rhs: "adde efbe 3412 7856 baab 1209 edde defa",
            expectedPattern: .sameIf([.swapEndianessOfUInt16sFromBytes])
        ) { rhs in
            rhs.swapEndianessOfUInt16sFromBytes()
        }
    }
    
    func test_sameIf_swapEndianessOfUInt32sFromBytes() throws {
        try doTestHex(
            lhs: "deadbeef 12345678 abba0912 deedfade",
            rhs: "efbeadde 78563412 1209baab defaedde",
            expectedPattern: .sameIf([.swapEndianessOfUInt32sFromBytes])
        ) { rhs in
            rhs.swapEndianessOfUInt32sFromBytes()
        }
    }
    
    func test_sameIf__swapEndianessOfUInt64sFromBytes() throws {
        try doTestHex(
            lhs: "deadbeef12345678 abba0912deedfade",
            rhs: "78563412efbeadde defaedde1209baab",
            expectedPattern: .sameIf([.swapEndianessOfUInt64sFromBytes])
        ) { rhs in
            rhs.swapEndianessOfUInt64sFromBytes()
        }
    }
    
    func test_sameIf_swapEndianessOfUInt16sFromBytes_reverseOrderOfUInt16sFromBytes_reversedHex() throws {
        try doTestHex(
            lhs: "dead beef 1234",
            rhs: "edda ebfe 2143",
            expectedPattern: .sameIf([.swapEndianessOfUInt16sFromBytes, .reverseOrderOfUInt16sFromBytes, .reversedHex])
        ) { rhs in
            rhs
                .swapEndianessOfUInt16sFromBytes()
                .reverseOrderOfUInt16sFromBytes()
                .reversedHex()
        }
    }
    
    func test_odd_byte_count_of_both_lhs_and_rhs_returns_nil() throws {
        try doTestHex(
            lhs: "deadbe",
            rhs: "deadbe",
            expectedPattern: nil
        )
    }
        
    func test_odd_byte_count_of_lhs_returns_nil() throws {
        try doTestHex(
            lhs: "deadbe",
            rhs: "dead",
            expectedPattern: nil
        )
    }
    
    func test_odd_byte_count_of_rhs_returns_nil() throws {
        try doTestHex(
            lhs: "dead",
            rhs: "deadbe",
            expectedPattern: nil
        )
    }
    
    func test_rhs_and_lhs_different_byte_count_returns_nil() throws {
        try doTestHex(
            lhs: "dead",
            rhs: "deadbeef",
            expectedPattern: nil
        )
    }
    
 
    func test_data_passing() throws {
        try XCTAssertBytesEqual(
            Data(hex: "ab12 cd34"),
            Data(hex: "12ab 34cd"),
            passOnPatternNonIdentical: true
        )
    }

    func test_hex_passing() {
        XCTAssertBytesFromHexEqual(
            "ab12 cd34",
            "12ab 34cd",
            passOnPatternNonIdentical: true
        )
    }
    
    func test_sparse_hex_string() throws {
        let finder = BytePatternFinder()
        let pattern = try finder.find(
            lhs: Data(hex: "050d000000000000000000000000000000000000000000000000000000000000"),
            rhs: Data(hex: "000000000000000000000000000000000000000000000000050d000000000000")
        )
        print(pattern)
    }
    
    // Peaks at 20 mb memory used, for a debug build this test
    // takes ~20 seconds on 2021 MBP M1.
    func skip_test_assert_linear_time_complexity() throws {
        var durationPerLength: [Int: TimeInterval] = [:]
        let lengths = (8 ... 17).map { exp in (pow(2, exp) as NSDecimalNumber).intValue }
        let iterationsPerLength = 10
        
        let expectedPattern = BytePattern.sameIf([.swapEndianessOfUInt64sFromBytes, .reverseOrderOfUInt64sFromBytes, .reversedHex])
        
        
        let finder = BytePatternFinder()
        var timer = Timer()
        func measure(length: Int) -> TimeInterval {
            precondition(length.isMultiple(of: UInt64.byteCount))
            
            let lhs = [UInt8]([UInt64](repeating: 0xDEAD_BEEF_ABBA_DEAF, count: length / UInt64.byteCount).map { $0.data }.joined())
            let rhs = lhs
                .swapEndianessOfUInt64sFromBytes()
                .reverseOrderOfUInt64sFromBytes()
                .reversedHex()
            
            timer.start()
            var patternFound: BytePattern!
            for _ in 0 ..< iterationsPerLength {
                patternFound = finder.find(lhs: lhs, rhs: rhs)
            }
            XCTAssertEqual(patternFound, expectedPattern)
            let totalTime = timer.stop()
            let averageTime = totalTime / TimeInterval(iterationsPerLength)
            return averageTime
        }
        
        var durationLast: TimeInterval?
        var lengthLast: Int?
        
        // Measure for each length
        lengths.forEach { length in
            let durationForLength = measure(length: length)
            durationPerLength[length] = durationForLength
            if let durationLast {
                // Assert linear
                let lengthFactor = Double(length) / Double(lengthLast!)
                let timeFactor = durationForLength / durationLast
                let timeFactorAdjustedForLength = timeFactor / lengthFactor
                XCTAssertLessThanOrEqual(timeFactorAdjustedForLength, 1.3) // Out to be 1.0, but we give some leeway.
            }
            durationLast = durationForLength
            lengthLast = length
        }
    }
}

extension BytePatternTests {
    func doTest<RHS: ContiguousBytes>(
        lhs: some ContiguousBytes,
        rhs: RHS,
        expectedPattern: BytePattern?,
        mutateRHS: ((RHS) -> [UInt8])? = nil,
        line: UInt = #line
    ) throws {
        guard let pattern = sut.find(lhs: lhs, rhs: rhs) else {
            XCTAssertNil(
                expectedPattern,
                "No pattern found, expected `expectedPattern` to be nil, but it was not.",
                line: line
            )
            XCTAssertNil(
                mutateRHS,
                "No pattern found, expected `mutateRHS` closure to be nil, but it was not.",
                line: line
            )
            return
        }
        
        guard let expectedPattern else {
            XCTFail("Expected to not find any pattern, since `expectedPattern` is nil, but found pattern: \(String(describing: pattern))")
            return
        }
        
        XCTAssertEqual(
            pattern,
            expectedPattern,
            "Found pattern does not match expected, found: \(String(describing: pattern)), expected: \(expectedPattern)",
            line: line
        )
        guard pattern != .identical else {
            XCTAssertNil(
                mutateRHS,
                "LHS and RHS is identical, expected `mutateRHS` closure to be nil, but it was not.",
                line: line
            )
            return
        }
        guard let mutateRHS else {
            XCTFail(
                "LHS and RHS are not identical, expected `mutateRHS` to be present.",
                line: line
            )
            return
        }
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
        expectedPattern: BytePattern?,
        mutateRHS: ((any ContiguousBytes) -> [UInt8])? = nil,
        line: UInt = #line
    ) throws {
        try doTest(
            lhs: Data(hex: lhs),
            rhs: Data(hex: rhs),
            expectedPattern: expectedPattern,
            mutateRHS: mutateRHS,
            line: line
        )
    }
}
