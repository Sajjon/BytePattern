//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-10.
//

import Foundation

precedencegroup BooleanCompoundAssigmentPrededence {
    lowerThan: ComparisonPrecedence
}

infix operator &&=: BooleanCompoundAssigmentPrededence

func &&=(lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}

public func circularRightShift(_ input: UInt8, _ amount: UInt8) -> UInt8 {
    let amount = amount % 8 // Reduce to the range 0...7
    return (input >> amount) | (input << (8 - amount))
}

public func rotateBits(of byte: UInt8) -> UInt8 {
    circularRightShift(byte, 4)
}
