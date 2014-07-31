---
layout: page
title: Schema Evolution
---

Over time, you might want to add or remove fields in an existing schema. The precise rules for schema evolution are inherited from Avro, and are documented in the Avro specification as rules for [Schema Resolution](http://avro.apache.org/docs/1.7.6/spec.html#Schema+Resolution). For the purposes of working in Kite, here are a couple of important things to note.

## Writer Schemas and Reader Schemas

Writer schemas describe a dataset as it is being written for transfer. Reader schemas describe a dataset as it is being read into a datastore. Writer and reader schemas must be compatible, but they do not have to match exactly. See the [Schema Resolution](http://avro.apache.org/docs/1.7.6/spec.html#Schema+Resolution) specification for the exhaustive list of rules for matching one schema to another.

## Removing Fields from a Dataset

You can have a schema that reads fewer fields than are defined by the schema used to write a dataset, provided that the field definitions in the reader schema are compatible with the chosen fields in the writer schema. This is useful when the writer schema provides more fields than are needed for the business case supported by the reader schema.

## Adding Fields to a Dataset

You can also have a reader schema that defines fields not found in the writer schema. If you do so, you must define a default value for the fields that appear in the reader schema but not in the writer schema. As records are read into the datastore, Kite inserts the default values in the extended fields.
