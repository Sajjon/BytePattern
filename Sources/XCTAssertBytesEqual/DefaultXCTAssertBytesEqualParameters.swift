//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-11.
//

import Foundation

/// A global set of values that will be used in the abscense of arguments passed to
/// `XCTAssertBytesEqual` and `XCTAssertBytesFromHexEqual`. These
/// bools can be set by you  if you want to have the same behaviour across many
/// tests, and thus omit this parameter when calling this function.
public enum DefaultXCTAssertBytesEqualParameters {
    
    /// Used in the abscenve of the `passOnPatternNonIdentical` parameter
    /// passed to test assert function `XCTAssertBytesEqual` or
    /// `XCTAssertBytesFromHexEqual`.
    public static var passOnPatternNonIdentical = false
    
    /// Used in the abscenve of the `haltOnPatternNonIdentical` parameter
    /// passed to test assert function `XCTAssertBytesEqual` or
    /// `XCTAssertBytesFromHexEqual`.
    public static var haltOnPatternNonIdentical = false
}
