---
layout: page
title: Schema Evolution
---

Over time, you might want to add or remove fields in an existing schema. The precise rules for schema evolution are inherited from Avro, and are documented in the Avro specification as rules for [Avro schema resolution][]. For the purposes of working in Kite, here are some important things to note.

## Writer Schemas and Reader Schemas

Writer schemas describe a dataset as it is being written. Reader schemas describe a dataset as it is being read from a datastore. Writer and reader schemas must be compatible, but they do not have to match exactly. See the [Avro schema resolution][] specification for the exhaustive list of rules for matching one schema to another.

## Changing Field Types

You can use schema resolution to change the type used to store a value. For example, you can change an `int` to a `long` to handle values that grow larger than initially anticipated.

## Removing Fields from a Dataset


When you remove fields from a dataset schema, the data already written remains unchanged. The fields you remove are not required when records are written going forward. The field must not be added back, unless it is identical to the existing field (since the data isn't actually removed from the dataset).

Removing unnecessary fields allows Kite to read data more efficiently. The performance gain can be significant when using Parquet format, in particular.

## Adding Fields to a Dataset

You can add fields to a dataset's schema, provided the the schema is compatible with the existing data. If you do so, you must define a default value for the fields you add to the dataset schema. New data that includes the field will be populated normally. Records that do not include the field are populated with the default you provide.


## Reading with Different Schemas

You can have a schema that reads fewer fields than are defined by the schema used to write a dataset, provided that the field definitions in the reader schema are compatible with the chosen fields in the writer schema. This is useful when the writer schema provides more fields than are needed for the business case supported by the reader schema.

Kite ensures that each change to a schema is compatible with the last version of the schema. Older data can always be read by the current schema.

[Avro Schema resolution]: http://avro.apache.org/docs/current/spec.html#Schema+Resolution "schemaSpec"
