# BytePatternFinder


A **linear time** byte pattern finder, useful to discover that two bytes seqences are almost identical, probably they are but during construction of one of them the developer has accidently either reversed the sequence, or they originate from integers, which might accidently use the wrong endianess, or a combination of both.

**All examples below assume that the bytes sequences `LHS` and `RHS`
have the same length.**

Best visualized with tests actually:

```swift
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
```

