---
layout: page
title: Related Work and Systems
---

## HDFS APIs

The HDFS APIs are used by the Data module. This seems safe as the FileSystem API is relatively stable. This API, however, is much higher level than the
typical HDFS streams so users aren't worried about bytes.

## Avro, Protocol Buffers, Thrift
The Data APIs standardize on Avro's in-memory representation of a schema, but make no promise about the underlying storage format. That said, Avro satisfies the set of criteria for optimally storing data in HDFS, and the platform team has already done a bunch of work to make it work with all components. In this way, the Data APIs are a layer above the file format.

## Kiji

WibiData's Kiji schema is an HBase-only library that overlaps with the Data module's schema tracking, but is much more prescriptive about how a user interacts with its readers and writers all the way up the stack. That is, Kiji entities are not simple Avro entities that are already supported by platform components. Special input / output formats are required in order to be able to use the Kiji-ified records. Further, Kiji only supports HBase for data, and assumes HBase is available for storage of schemas. Since we have different requirements and a different use case, we see this as a separate concern.

## HCatalog

See the Dataset Repositories and Metadata Providers section for information about integration plans and compatibility with HCatalog.