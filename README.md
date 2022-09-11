# BytePatternFinder


A **linear time** byte pattern finder, useful to discover that two bytes seqences are almost identical, probably they are but during construction of one of them the developer has accidently either reversed the sequence, or they originate from integers, which might accidently use the wrong endianess, or a combination of both.

**All examples below assume that the bytes sequences `LHS` and `RHS`
have the same length.**

## `identical`

```swift
let finder = BytePatternFinder()

finder.find(
    lhs: try Data(hex: "dead beef 1234 5678 abba 0912 deed fade"),
    rhs: try Data(hex: "dead beef 1234 5678 abba 0912 deed fade")
) // `.identical`
```

## `reversed`

```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "34cd 12ab"
) // `.sameIfRHS([.reversed])`

finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "defa edde 1209 baab 7856 3412 efbe adde"
) // `.sameIfRHS([.reversed])`
```

## `reversedHex`

```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "43dc 21ba"
) // `.sameIfRHS([.reversedHex])`

finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "edaf deed 2190 abba 8765 4321 feeb daed"
) // `.sameIfRHS([.reversedHex])`
```

## `asSegmentsOfUInt64ButReversedOrder`
And analogous `asSegmentsOfUInt32ButReversedOrder` and `asSegmentsOfUInt16ButReversedOrder`

```swift
finder.find(
    lhs: "dead beef 1234 5678",
    rhs: "5678 1234 beef dead"
) // `.sameIfRHS([.asSegmentsOfUInt16ButReversedOrder])`

finder.find(
    lhs: "dead beef 1234",
    rhs: "1234 beef dead"
) // `.sameIfRHS([.asSegmentsOfUInt16ButReversedOrder])`
```

## `asSegmentsOfUInt64ButEndianessSwapped`
And analogous `asSegmentsOfUInt32ButEndianessSwapped` and `asSegmentsOfUInt16ButEndianessSwapped`


```swift
finder.find(
    lhs: "ab12 cd34",
    rhs: "12ab 34cd"
) // `.sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped])`


finder.find(
    lhs: "dead beef 1234 5678 abba 0912 deed fade",
    rhs: "adde efbe 3412 7856 baab 1209 edde defa"
) // `.sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped])`


finder.find(
    lhs: "deadbeef 12345678 abba0912 deedfade",
    rhs: "efbeadde 78563412 1209baab defaedde"
) // `.sameIfRHS([.asSegmentsOfUInt32ButEndianessSwapped])`

finder.find(
    lhs: "deadbeef12345678 abba0912deedfade",
    rhs: "78563412efbeadde defaedde1209baab"
) // `.sameIfRHS([.asSegmentsOfUInt64ButEndianessSwapped])`
```

## Combined

```swift
finder.find(
    lhs: "dead beef 1234",
    rhs: "edda ebfe 2143",
) // `sameIfRHS([.asSegmentsOfUInt16ButEndianessSwapped, .asSegmentsOfUInt16ButReversedOrder, .reversedHex])`
```
