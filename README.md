# BytePatternFinder


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

## `reverseOrderOfUInt64sFromBytes`
And analogous `reverseOrderOfUInt32sFromBytes` and `reverseOrderOfUInt16sFromBytes`

Two byte sequences would be identical if one of them were "chunked" into segments of length two, i.e. as if loaded `UInt16` at start of each segment, and then this list of integers were reversed.

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

## `swapEndianessOfUInt64sFromBytes`
And analogous `swapEndianessOfUInt32sFromBytes` and `swapEndianessOfUInt16sFromBytes`

 Two byte sequences would be identical if one of them were "chunked" into segments of length two, i.e. as if loaded `UInt16` and we were to swap endianness of each integer in this list.

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
