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
/// - Parameters:
///   - lhs: Some sequence of bytes to compare with `RHS`.
///   - rhs: Some sequence of bytes to compare with`LHS`.
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
public func XCTAssertBytesEqual(
    _ lhs: some ContiguousBytes,
    _ rhs: some ContiguousBytes,
    _ message: String? = nil,
    passOnPatternNonIdentical: Bool? = nil,
    haltOnPatternNonIdentical: Bool? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> BytePattern? {
   
    let passOnPatternNonIdentical = passOnPatternNonIdentical ?? DefaultXCTAssertBytesEqualParameters.passOnPatternNonIdentical
    let haltOnPatternNonIdentical = haltOnPatternNonIdentical ?? DefaultXCTAssertBytesEqualParameters.haltOnPatternNonIdentical
   
    let bytePatternFinder = BytePatternFinder()
    if let pattern = bytePatternFinder.find(lhs: lhs, rhs:  rhs) {
        if pattern == .identical {
            // All good
        } else {
            let msg = "Expected bytes in LHS to equal RHS, but they are not, however, they resemble each other with according to byte pattern: \(String(describing: pattern)).\(message.map { " \($0)." } ?? "")"
            if haltOnPatternNonIdentical {
                debugPrint(msg)
                raise(SIGINT)
            }
            if !passOnPatternNonIdentical {
                XCTFail(
                    msg,
                    file: file,
                    line: line
                )
            }
        }
        return pattern
    } else {
        XCTFail(
            "Expected bytes in LHS to equal RHS, but they are different.\(message.map { " \($0)." } ?? "")",
            file: file,
            line: line
        )
        return nil
    }
}
