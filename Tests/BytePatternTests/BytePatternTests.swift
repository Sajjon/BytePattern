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

final class BytePatternTests: XCTestCase {
    fileprivate let sut = BytePatternFinder()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_reverse_bits_in_byte() {
        func s(_ uint8: UInt8) -> String {
            var bin = String(uint8, radix: 2)
            while bin.count < 8 {
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
                "rotated: \(s(rotated)) != \(s(expected)) (expected)",
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

    // Peaks at 20 mb memory used, for a debug build this test
    // takes ~20 seconds on 2021 MBP M1.
    func test_assert_linear_time_complexity() throws {
        var durationPerLength: [Int: TimeInterval] = [:]
        let lengths = (8 ... 17).map { exp in (pow(2, exp) as NSDecimalNumber).intValue }
        let iterationsPerLength = 10

        let expectedPattern = BytePattern.sameIfRHS([.asSegmentsOfUInt64ButEndianessSwapped, .asSegmentsOfUInt64ButReversedOrder, .reversedHex])


        let finder = BytePatternFinder()
        var timer = Timer()
        func measure(length: Int) -> TimeInterval {
            precondition(length.isMultiple(of: UInt64.byteCount))
           
            let lhs = [UInt8]([UInt64](repeating: 0xDEAD_BEEF_ABBA_DEAF, count: length / UInt64.byteCount).map { $0.data }.joined())
            let rhs = lhs
                .asSegmentsOfUInt64ButEndianessSwapped()
                .asSegmentsOfUInt64ButReversedOrder()
                .reversedHex()
            
            timer.start()
            var patternFound: BytePattern!
            for _ in 0 ..< iterationsPerLength {
                patternFound = finder.find(between: lhs, and: rhs)
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
        guard let pattern = sut.find(between: lhs, and: rhs) else {
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
