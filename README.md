# BytesPatternMatcher


A pattern matcher for bytes, useful to discover that two bytes seqences
are almost identical, probably they are but during construction of one of
them the developer has accidently either reversed the sequence, or
they originate from integers, which might accidently use the wrong
endianess, or a combination of both.

All examples below assume that the bytes sequences `LHS` and `RHS`
have the same length.

```
(
    `dead beef 1234 5678 abba 0912 deed fade`,
    `dead beef 1234 5678 abba 0912 deed fade`
) => `.identical`

(
    `dead beef 1234 5678 abba 0912 deed fade`,
    `edaf deed 2190 abba 8765 4321 feeb daed`
) => `.almostSame([.entireReveresed(.entireSequenceAsHex)])`

(
    `dead beef 1234 5678 abba 0912 deed fade`,
    `defa edde 1209 baab 7856 3412 efbe adde`
) => `.almostSame([.reversed(.entireSequenceAsBytes)])`

(
    `dead beef 1234`,
    `1234 beef dead`
) => `.almostSame([.reversed(.orderOfIntegers(.uint16)))`

(
    `dead beef 1234 5678 abba 0912 deed fade`,
    `adde efbe 3412 7856 baab 1209 edde defa`
) => `.almostSame([.endianessSwapped(for: .uint16)])`

(
    `deadbeef 12345678 abba0912 deedfade`, // grouped 4 bytes together
    `efbeadde 78563412 1209baab defaedde`
) => `.almostSame([.endianessSwapped(for: .uint32)])`

(
    `deadbeef12345678 abba0912deedfade`, // grouped 8 bytes together
    `78563412efbeadde defaedde1209baab`
) => `.almostSame([.endianessSwapped(for: .uint64)])`


(
    `dead beef 1234`,
    `edda ebfe 2143`
) => `.almostSame([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsHex)])`
```

One thing to note is that these mutations:
`.almostSame([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers)])``
is the same as `.almostSame([reversed(entireSequenceAsBytes)]))`.

Another thing to note is that these mutations:
`.almostSame([.endianessSwapped(for: .uint16), .reversed(.orderOfIntegers), .reversed(.entireSequenceAsBytes)])
would result in the `identity`, i.e. `identical`, and does not work for just `uint16` but for any int.

