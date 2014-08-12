---
layout: page
title: Set Notation
---

The syntax for ranges of values follows this format.

```
([ _value1_ , _value2_ )]
```

The following table describes the meaning of each syntax element.

| Symbol | Meaning
| ----------------
| ( | value is greater than value1
| [ | value is greater than or equal to value1
| _value1_ | lower bounding value or empty if unbounded
| , | comma separates value1 and value2
| _value2_ | upper bounding value or empty if unbounded
| ) | value is less than value2
| ] | value is less than or equal to value2


## Examples

| Range | Defined Set
|-------------------
| [1,3] | 1 <= value <= 3
| (1,3] | 1 < value <= 3
| [1,3) | 1 <= value < 3
| (1,3) | 1 < value < 3
| (aardvark,zebu) | strings greater than _aardvark_ and less than _zebu_
| ( ,1] | value <= 1
| [3, ) | value >= 3

