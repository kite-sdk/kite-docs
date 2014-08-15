---
layout: page
title: Interval Notation
---

The syntax for ranges of values follows this format.

| bound type | lower bound | (comma) | upper bound | bound type |
| [ or ( | a value | , | a value | ) or ] |

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
| (a,d) | strings greater than a and less than d
| ( ,1] | value <= 1 (empty means <i>unbounded</i>)
| [3, ) | value >= 3 (empty means <i>unbounded</i>)

For more information on intervals see <a href="http://en.wikipedia.org/wiki/Interval_(mathematics)">http://en.wikipedia.org/wiki/Interval_(mathematics)</a>.

