---
layout: page
title: Read-only Formats
---

In addition to Avro and Parquet, Kite can read from some other common data formats. This enables you to use Kite with existing datasets and makes it possible to import and convert that data to Kite's recommended formats.

## CSV

Kite can read CSV files that contain well-formed CSV.

Well-formed CSV:
* Must not contain the newline or delimiter characters in unquoted data fields.
* Can contain newline and delimiter characters in a data field if the field is quoted
* Can contain the quote and escape characters in a data field if they are escaped

The delimiter, quote character, and escape character are configurable. CSV can contain a header field that is used to determine the field order, and can start with non-data comment lines that are skipped before reading data or the header, if it is present.

Kite does not support nested structures within CSV data and will handle it as a string.

See also:
* [`csv-schema`][cli-csv-schema] for inferring an Avro Schema from a CSV data sample
* [`csv-import`][cli-csv-import] for importing CSV data into an Avro or Parquet dataset

[cli-csv-schema]: {{site.baseurl}}/cli-reference.html#csv-schema
[cli-csv-import]: {{site.baseurl}}/cli-reference.html#csv-import

## JSON

Kite can read JSON files that contain concatenated or whitespace-separated JSON objects that conform to the [JSON specification][json-spec].

Kite does not implement special support for [Avro's JSON encoding][avro-json].

<!-- Uncomment when json-schema and json-import are added.
See also:
* [`json-schema`][cli-json-schema] for inferring an Avro Schema from a JSON data sample
* [`json-import`][cli-json-import] for importing JSON data into an Avro or Parquet dataset
-->

[json-spec]: http://json.org/
[cli-json-schema]: {{site.baseurl}}/cli-reference.html#json-schema
[cli-json-import]: {{site.baseurl}}/cli-reference.html#json-import
[avro-json]: https://avro.apache.org/docs/current/spec.html#json_encoding

