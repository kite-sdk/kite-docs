---
layout: page
title: Partition Strategy JSON Format
---

A partition strategy is made up of a list of partition fields. Each field defines how to take source data from an entity and produce a value that is used to store the entity. For example, a field can produce the year an event happened from its timestamp. Another field in the strategy can be the month from the timestamp.

Partition strategies are defined in [JSON][json] format. The strategy must be a list of objects---name/value pairs---each of which defines a field in the partition strategy. All field definitions require at least two attributes:

* `source` -- a source field on the entity, such as "created_at"
* `type` -- the type of partition derived from the source data, such as "year"

Each definition can be thought of as a function run on the entity's source to produce the partition field's data. The order of the partition fields is preserved and used when the strategy is applied.

The available types are:

| Type       | Source               | Produces                    | Requirements |
| ----       | ------               | --------                    | ------------ |
| `year`     | a timestamp          | year, like 2014             | must be a long[<sup>1</sup>](#notes) |
| `month`    | a timestamp          | month, 1-12                 | must be a long |
| `day`      | a timestamp          | day of the month, 1-31      | must be a long |
| `hour`     | a timestamp          | hour in the day, 0-23       | must be a long |
| `minute`   | a timestamp          | minute in the hour, 0-59    | must be a long |
| `identity` | any string or number | the source value, unchanged | must be a string or numeric |
| `hash`     | any object           | int hash of the value, 0-B  | requires B, `buckets` integer attribute[<sup>2</sup>](#notes) |
|`record` | any object | object with nested values| |

A field definition can optionally provide a `name` attribute, which is used to reference the partition field. HDFS datasets use this name when creating partition paths. If the name attribute is missing, it is defaulted based on the partition type and source field name.

Requirements for the source data are validated when schemas and partition strategies are used together. 

## Examples

This strategy uses the year, month, and day from the "received_at" timestamp field on an event.

```json
[
  {"type": "year", "source": "received_at"},
  {"type": "month", "source": "received_at"},
  {"type": "day", "source": "received_at"}
]
```

This strategy hashes and embeds the "email" field from a user record.

```json
[
  {"type": "hash", "source": "email", "buckets": 16},
  {"type": "identity", "source": "email"}
]
```

This strategy defines the record `location` with the nested values `latitude` and `longitude`.

```json
[
   {
      "type": "record", 
      "name": "location",
      "fields" : [
         {"name": "latitude", "type": "long"},
         {"name": "longitude", "type": "string"}
      ]
   }
]
```

You access record values using dot notation. For example, `myentity.location.latitude`.

### Notes:
1. Source timestamps must be [long][avro-types] fields. The value encodes the number of milliseconds since unix epoch, as in Joda Time's [Instant][timestamp] and Java's Date.
2. The `buckets` attribute is required for `hash` partitions and controls the number of partitions into which the entities should be pseudo-randomly distributed.

[json]: http://www.json.org/
[avro-types]: http://avro.apache.org/docs/1.7.6/spec.html#schema_primitive
[timestamp]: http://www.joda.org/joda-time/apidocs/org/joda/time/Instant.html#getMillis()
