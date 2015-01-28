---
layout: page
title: Read-only Formats
---

In addition to Avro and Parquet, Kite can read from some other common data formats. This enables you to use Kite with existing datasets. You can also import and convert existing data to one of Kite's recommended formats.

## CSV

Kite can read CSV files that contain well-formed CSV.

Well-formed CSV:

* Must not contain the newline or delimiter characters in unquoted data fields.
* Can contain newline and delimiter characters in a data field if the field is quoted
* Can contain the quote and escape characters in a data field if they are escaped

You can configure the delimiter, quote, and escape characters. Your CSV can contain a header that is used to determine the field order, and can start with non-data comment lines. Non-data lines are skipped before the header, if it is present, or the data.

Kite does not support nested structures within CSV data. Kite will handle nested structures as strings.

* The Kite CLI can infer an Avro schema from a CSV data sample. See [`csv-schema`][cli-csv-schema].
* The Kite CLI can import CSV data into an existing dataset. See [`csv-import`][cli-csv-import].

[cli-csv-schema]: {{site.baseurl}}/cli-reference.html#csv-schema
[cli-csv-import]: {{site.baseurl}}/cli-reference.html#csv-import

## JSON

Kite can read JSON files that contain concatenated or whitespace-separated JSON objects that conform to the [JSON specification][json-spec].

See Wikipedia's [JSON streaming article][json-streaming] for more background on concatenated JSON.

Kite does not implement special support for [Avro's JSON encoding][avro-json].

* The Kite CLI can infer an Avro Schema from a JSON data sample. See [`json-schema`][cli-json-schema].
* The Kite CLI can import concatenated JSON data into an existing dataset. See [`json-import`][cli-json-import].

[json-spec]: http://json.org/
[cli-json-schema]: {{site.baseurl}}/cli-reference.html#json-schema
[cli-json-import]: {{site.baseurl}}/cli-reference.html#json-import
[avro-json]: https://avro.apache.org/docs/current/spec.html#json_encoding
[json-streaming]: https://en.wikipedia.org/wiki/JSON_Streaming
