---
layout: page
title: Interval Notation
---

The syntax for ranges of values follows this format.

| bound type | lower bound | (comma) | upper bound | bound type |
-------------|------------|------|-------|---------|
| `[` or `(` | _value1_ | `,` | _value2_ | `)` or `]` |

The following table describes the meaning of each syntax element.

| Symbol | Meaning
| ----------------
| `(` | value is greater than _value1_
| `[` | value is greater than or equal to _value1_
| _value1_ | lower bounding value or empty if unbounded
| `,` | comma separates _value1_ and _value2_
| _value2_ | upper bounding value or empty if unbounded
| `)` | value is less than _value2_
| `]` | value is less than or equal to _value2_


## Examples

| Range | Defined Set
|-------------------
| `[1,3]` | 1 <= value <= 3
| `(1,3]` | 1 < value <= 3
| `[1,3)` | 1 <= value < 3
| `(1,3)` | 1 < value < 3
| `(a,d)` | strings greater than a and less than d (for example, _aardvark_ and _czar_ would fit within these bounds)
| `( ,1]` | value <= 1 (empty means <i>unbounded</i>)
| `[3, )` | value >= 3 (empty means <i>unbounded</i>)

For more information on intervals see the article on <a href="http://en.wikipedia.org/wiki/Interval_(mathematics)">Wikipedia</a>.

