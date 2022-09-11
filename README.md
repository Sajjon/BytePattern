# BytePattern


A **linear time** byte pattern finder, useful to discover that two bytes seqences are almost identical, probably they are but during construction of one of them the developer has accidently either reversed the sequence, or they originate from integers, which might accidently use the wrong endianess, or a combination of both.

**All examples below assume that the bytes sequences `LHS` and `RHS`
have the same length.**

## `identical`
Two byte sequences are identical, i.e. equal to each other.

```swift
let finder = BytePatternFinder()

finder.find(
    lhs: try Data(hex: "dead beef 1234 5678 abba 0912 deed fade"),
    rhs: try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
) // `.identical`
```

## `reversed`
Two byte sequences would be identical if one of them where reversed in its entirety.

```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "34cd 12ab"
) // `.sameIf([.reversed])`

finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "defa edde 1209 baab 7856 3412 efbe adde"
) // `.sameIf([.reversed])`
```

## `reversedHex`
 Two byte sequences would be identical if one of them where initialized from a hex string that was revered before passed to byte sequence init.
 
 Or in otherwords, if every byte in one of the sequences were [rotated (ciruclar shifted)](https://en.wikipedia.org/wiki/Bitwise_operation#Rotate) by 4 bits. This operator is not part of the standard library but is implemented by: `(input >> 4) | (input << 4)`.

```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "43dc 21ba"
) // `.sameIf([.reversedHex])`

finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "edaf deed 2190 abba 8765 4321 feeb daed"
) // `.sameIf([.reversedHex])`
```

## `reverseOrderOfUInt16/32/64sFromBytes`

Two byte sequences would be identical if one of them were "chunked" into segments of length 2/4/8, i.e. as if loaded `UInt16`/`UInt32`/`UInt64` at start of each segment, and then this list of integers were reversed, for `reverseOrderOfUInt16sFromBytes`/`reverseOrderOfUInt32sFromBytes`/`reverseOrderOfUInt64sFromBytes`.

```swift
finder.find(
    lhs: "dead beef 1234 5678",
    rhs: "5678 1234 beef dead"
) // `.sameIf([.reverseOrderOfUInt16sFromBytes])`

finder.find(
    lhs: "dead beef 1234",
    rhs: "1234 beef dead"
) // `.sameIf([.reverseOrderOfUInt16sFromBytes])`
```

## `swapEndianessOfUInt16/32/64sFromBytes`

 Two byte sequences would be identical if one of them were "chunked" into segments of length 2/4/8, i.e. as if loaded `UInt16`/`UInt32`/`UInt64` and we were to swap endianness of each integer in this list, for `swapEndianessOfUInt16sFromBytes`/`swapEndianessOfUInt32sFromBytes`/`swapEndianessOfUInt64sFromBytes`.

```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "12ab 34cd"
) // `.sameIf([.swapEndianessOfUInt16sFromBytes])`


finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "adde efbe 3412 7856 baab 1209 edde defa"
) // `.sameIf([.swapEndianessOfUInt16sFromBytes])`


finder.find(
    lhs: "deadbeef 12345678 abba0912 deedfade",
    rhs: "efbeadde 78563412 1209baab defaedde"
) // `.sameIf([.swapEndianessOfUInt32sFromBytes])`

finder.find(
    lhs: "deadbeef12345678 abba0912deedfade",
    rhs: "78563412efbeadde defaedde1209baab"
) // `.sameIf([.swapEndianessOfUInt64sFromBytes])`
```

## Combined

```swift
finder.find(
    lhs: "dead beef 1234",
    rhs: "edda ebfe 2143",
) // `sameIf([.swapEndianessOfUInt16sFromBytes, .reverseOrderOfUInt16sFromBytes, .reversedHex])`
```

# XCTAssertBytesEqual
A small test util package which enables you to conveniently compare byte sequences using the `BytePatternFinder`. It contains some `XCTAssert` like methods, but specially tailored for byte sequence comparision.


## XCTAssertBytesEqual


```swift
// This test will fail.
// Assertion failure message is:
// "Expected bytes in LHS to equal RHS, but they are not, however, they resemble each other with according to byte pattern: sameIf([swapEndianessOfUInt16sFromBytes])."
func test_data_failing() throws {
    try XCTAssertBytesEqual(
        Data(hex: "ab12 cd34"),
        Data(hex: "12ab 34cd"),
        "An optional message goes here."
    )
}
```

You can change the behaviour of the test to pass for non-`identical` patterns found - but will still fail for no pattern found of course, by passing `passOnPatternNonIdentical: true`.

```swift
func test_data_passing() throws {
    try XCTAssertBytesEqual(
        Data(hex: "ab12 cd34"),
        Data(hex: "12ab 34cd"),
        "An optional message goes here.",
        passOnPatternNonIdentical: true
    )
}
```

You can also opt in to interrupt on non-identical patterns found by passing `haltOnPatternNonIdentical: true`:

```swift
func test_data_passing_halting() throws {
    try XCTAssertBytesEqual(
        Data(hex: "ab12 cd34"),
        Data(hex: "12ab 34cd"),
        "An optional message goes here.",
        passOnPatternNonIdentical: true,
        haltOnPatternNonIdentical: true
    )
}
```

You can also globally change default value of `passOnPatternNonIdentical` and `haltOnPatternNonIdentical` by setting these properties on global type `DefaultXCTAssertBytesEqualParameters`. A good place to do this is in the `setUp()` method of your test class.


```swift
override func setUp() {
    super.setUp()
    DefaultXCTAssertBytesEqualParameters.passOnPatternNonIdentical = true
    DefaultXCTAssertBytesEqualParameters.haltOnPatternNonIdentical = true
}

func test_data_passing_halting_defaulParamsUsed() throws {
    try XCTAssertBytesEqual(
        Data(hex: "ab12 cd34"),
        Data(hex: "12ab 34cd")
    )
}
```


## XCTAssertBytesFromHexEqual

The examples above can be simplified by used of `XCTAssertBytesFromHexEqual`, which will fail with error if you're passing in invalid hexadecimal strings.


```swift
func test_nonIdentical_but_passing() {
    XCTAssertBytesFromHexEqual(
        "ab12 cd34",
        "12ab 34cd",
        passOnPatternNonIdentical: true
    )
}
```

# BytesMutation

This small package allows you to perform mutation on any byte sequence conforming to `ContiguousBytes` and which names mirror those of `BytePattern`.

```swift
public extension ContiguousBytes {
    func reversed() -> [UInt8]

    func reversedHex() -> [UInt8]

    func reverseOrderOfUInt16sFromBytes() -> [UInt8]

    func reverseOrderOfUInt32sFromBytes() -> [UInt8]

    func reverseOrderOfUInt64sFromBytes() -> [UInt8]

    func swapEndianessOfUInt16sFromBytes() -> [UInt8]

    func swapEndianessOfUInt32sFromBytes() -> [UInt8]

    func swapEndianessOfUInt64sFromBytes() -> [UInt8]
}
```
