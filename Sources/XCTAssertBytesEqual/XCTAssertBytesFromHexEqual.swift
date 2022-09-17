//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation
import XCTest
import BytePattern

/// A comprehensive compare of LHS and RHS byte sequences
/// which uses BytePatternFinder to find any byte pattern between
/// them. The sequences might be identical, completely different
/// or would have been identical if some mutation would be done,
/// or in other words, you might have accidently done a mutation
/// or otherwise incorrect initialization of the data, this comparission
/// will help inform you of this.
///
/// The `LHS` and `RHS` parameters are passed in as hexadecimal
/// strings, and the test will immedialtely fail if these are invalid
/// hex strings.
///
/// - Parameters:
///   - lhs: Some sequence of bytes to compare with `RHS` represented as a hexadecimal string.
///   - rhs: Some sequence of bytes to compare with`LHS` represented as a hexadecimal string.
///   - message: An optional description of the assertion, for inclusion in test results.
///   - passOnPatternNonIdentical: An optional boolean value indicating that
///   this test assertion should count as "pass"/"success" even if `LHS` and `RHS`
///   are not identical, but similar according to a `BytePattern`. If `nil`
///   is passed in, the static `passOnPatternNonIdentical` value in the global
///   type `DefaultXCTAssertBytesEqualParameters` will be used, this bool
///   has both getter and a setter, so you can override this default value if you want to
///   have the same behaviour across many tests, and thus omit this parameter when
///   calling this function.
///   - haltOnPatternNonIdentical: An optional boolean value indicating that
///   when a non `identical`byte pattern was found when for `LHS` and `RHS`
///   the test should halt execution and debug print the pattern This is useful when you
///   want to highlight any non-identical pattern for a specifc test you care about. If `nil`
///   is passed in, the static `haltOnPatternNonIdentical` value in the global
///   type `DefaultXCTAssertBytesEqualParameters` will be used, this bool
///   has both getter and a setter, so you can override this default value if you want to
///   have the same behaviour across many tests, and thus omit this parameter when
///   calling this function.
///   - file: The file where the failure occurs. The default is the filename of the
///   test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line
///   number where you call this function.
/// - Returns: A pattern of bytes found when comparing `LHS` with `RHS`.
@discardableResult
public func XCTAssertBytesFromHexEqual(
    _ lhsHex: String,
    _ rhsHex: String,
    _ maybeMessage: String? = nil,
    passOnPatternNonIdentical: Bool? = nil,
    haltOnPatternNonIdentical: Bool? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> BytePattern? {
    let lhs: Data
    let rhs: Data
    
    func failureMessage(_ msg: String, error: Swift.Error) -> String {
        "Failed to init \(msg) as data from hex, underlying error: \(String(describing: error))"
    }
    
    do {
        lhs = try .init(hex: lhsHex)
    } catch {
        XCTFail(failureMessage("LHS", error: error))
        return nil
    }
    
    do {
        rhs = try .init(hex: rhsHex)
    } catch {
        XCTFail(failureMessage("RHS", error: error))
        return nil
    }
    
    return XCTAssertBytesEqual(
        lhs,
        rhs,
        maybeMessage,
        passOnPatternNonIdentical: passOnPatternNonIdentical,
        haltOnPatternNonIdentical: haltOnPatternNonIdentical,
        file: file,
        line: line
    )
}
