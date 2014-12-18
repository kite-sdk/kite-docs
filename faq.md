---
layout: page
title: Frequently Asked Questions
---

#### What license is this library made available under?

This software is licensed under the Apache Software License 2.0. A file named LICENSE.txt should have been included with the software.

#### What format is my data stored in?

Data is stored using either Avro, for record-oriented storage, or Parquet, for column-oriented storage.

Avro files are snappy-compressed and encoded using Avro's binary encoder, according to Avro's [object container file spec][avro-cf]. Avro meets the criteria for sane storage and operation of data. Specifically, Avro:

* has a binary representation that is compact.
* is language agnostic.
* supports compression of data.
* is splittable by MapReduce jobs, including when compressed.
* is self-describing.
* is fast to serialize/deserialize.
* is well-supported within the Hadoop ecosystem.
* is open source under a permissive license.

Parquet files are also compressed, binary-encoded files for efficient column-oriented data patterns, defined by the [parquet file specification][parquet-spec].

#### Why not store data as protocol buffers?

Protos do not define a standard for storing a set of protocol buffer encoded records in a file that supports compression and is also splittable by MapReduce.

#### Why not store data as thrift?

See _Why not protocol buffers?_

#### Why not store data as Java serialization?

See <https://github.com/eishay/jvm-serializers/wiki>. In other words, because it's terrible.

#### Can I contribute code/docs/examples?

Absolutely! To get started, you're encouraged to read [How to Contribute][how-to-contribute]. In short, you must:

* Be able to (legally) complete, sign, and return a contributor license agreement.
* Follow the existing style and standards.

#### What happened to CDK?

CDK has been renamed to Kite, this project. The main goal of Kite is to increase the accessibility of Apache Hadoop as a platform. This isn't specific to Cloudera, so we updated the name to correctly represent the project as an open, community-driven set of tools. 

[avro-cf]: http://avro.apache.org/docs/current/spec.html#Object+Container+Files "Apache Avro - Object container files"
[parquet-spec]: https://github.com/Parquet/parquet-format#file-format
[how-to-contribute]: https://github.com/kite-sdk/kite/wiki/How-to-contribute
