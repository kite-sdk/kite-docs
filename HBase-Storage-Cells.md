---
layout: page
title: HBase Storage Cells
---
## HBase Storage Cells

HBase stores data as a group of values, or cells. HBase uniquely identifies each cell by a key. Using a key, you can look up the data for records stored in HBase very quickly. You can also insert, modify, or delete records in the middle of a dataset. HBase makes this possible by organizing data by storage key.

HDFS writes files into statically configured partitions. HBase, on the other hand, dynamically groups keys into files. When a group of records (called a __region__) grows too large, HBase splits it into two regions. As more data is added, regions grow more specific. The boundary between regions could fall between any two keys.

Data cells are organized first by column family, then by column qualifier. The cells form columns and groups of columns in a table structure. For example, a user's data can be stored using the e-mail address for a key, then as a &quot;name&quot; column family with &quot;first&quot; and &quot;last&quot; qualifiers. We end up with a view that looks like this:

```

|  key           | name family      |
| (e-mail)       | first|   last    |
| -------------- | -----| --------- |
| buzz@pixar.com | Buzz | Lightyear |
```

### HBase partitioning

Kite uses a dataset&apos;s partitioning strategy to make storage keys for records. In HDFS, the key identifies a directory where the record is stored along with others with the same key. For example, HDFS might use the same key for events that occur on the same day. In HBase, keys are unique, making it very fast to find a particular record. A key in HBase might be an ID number or an e-mail address, as in the example above.

When configuring a partitioning strategy for HBase, always include a field that uniquely identifies the record.

### Organizing data

Good performance comes from being able to ignore as much of a dataset as possible. HBase partitioning works just like HDFS, even though you don&apos;t know where the partition boundaries are. The same guidelines for performance still apply: your partitioning strategy should start with information that helps eliminate the most data.

For example, storing events in HDFS by year, then month, then day, allows Kite to ignore files that can&apos;t have data in a given time range. A similar partition strategy for HBase would include the entire timestamp, because the region boundaries are not statically set ahead of time and might be small.
