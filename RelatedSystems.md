---
layout: page
title: Related Work and Systems
---

## HDFS APIs

The Kite Data Module uses HDFS APIs. The difference between using the HDFS API and Kite's API is that Kite is deliberately a high-level API, in terms of records, views, and datasets. Kite's internal classes handle file management tasks so you don't have to. Kite provides a single API that works with HDFS, HBase, and potentially others.

## Avro, Protocol Buffers, Thrift
The Data APIs standardize on Avro's in-memory representation of a schema. Avro satisfies the set of criteria for optimally storing data in HDFS. Avro is relieable and provides features for a variety of uses (generic, specific, reflect). In this way, the Data APIs are handled in a layer above the file format. In addition, there are there are Protcol Buffer and Thrift libraries that work with Avro that might be supported in the future.

## Kiji

WibiData's Kiji schema is an HBase-only library that overlaps with the Data module's schema tracking, but is much more prescriptive about how a user interacts with its readers and writers all the way up the stack. That is, Kiji entities are not simple Avro entities that are already supported by platform components. Special input / output formats are required in order to be able to use the Kiji-ified records. Further, Kiji only supports HBase for data, and assumes HBase is available for storage of schemas. Since we have different requirements and a different use case, we see this as a separate concern.

## HCatalog

HCatalog takes advantage of the large number of formats that Hive can read and write. HCatalog should be able to read a Hive table, but this comes at a performance price because Hive copies and translates records. Because Kite supports a small set of formats, it can integrate with them directly without the need for layers of abstraction.
