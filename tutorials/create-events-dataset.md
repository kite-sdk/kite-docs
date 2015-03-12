---
layout: page
title: Creating the Events Dataset
---
## Purpose

This lesson shows you how to create a dataset suitable for storing standard event records, as defined in [The Unified Logging Infrastructure for Data Analytics at Twitter][paper]. You define a dataset schema, a partition strategy, and a URI that specifies the storage scheme.

[paper]:http://vldb.org/pvldb/vol5/p1771_georgelee_vldb2012.pdf

### Prerequisites

A VM or cluster with CDH installed.

### Result

You create `dataset:hive:events`, where you can store standard event objects. You can use the dataset with several Kite tutorials that demonstrate data capture, storage, and analysis.

## Defining the Schema

The `standard_event.avsc` schema is self-describing, with a _doc_ property for each field. StandardEvent records store the `user_id` for the person who initiates an event, the user's IP address, and a timestamp for when the event occurred.

### standard_event.avsc

```JSON
{
  "name": "StandardEvent",
  "namespace": "org.kitesdk.data.event",
  "type": "record",
  "doc": "A standard event type for logging, based on the paper 'The Unified Logging Infrastructure for Data Analytics at Twitter' by Lee et al, http://vldb.org/pvldb/vol5/p1771_georgelee_vldb2012.pdf",
  "fields": [
    {
      "name": "event_initiator",
      "type": "string",
      "doc": "Source of the event in the format {client,server}_{user,app}; for example, 'client_user'. Required."
    },
    {
      "name": "event_name",
      "type": "string",
      "doc": "A hierarchical name for the event, with parts separated by ':'. Required."
    },
    {
      "name": "user_id",
      "type": "long",
      "doc": "A unique identifier for the user. Required."
    },
    {
      "name": "session_id",
      "type": "string",
      "doc": "A unique identifier for the session. Required."
    },
    {
      "name": "ip",
      "type": "string",
      "doc": "The IP address of the host where the event originated. Required."
    },
    {
      "name": "timestamp",
      "type": "long",
      "doc": "The point in time when the event occurred, represented as the number of milliseconds since January 1, 1970, 00:00:00 GMT. Required."
    }
  ]
}
```

## Defining the Partition Strategy

Analytics for the `events` dataset are time-based. Partitioning the dataset on the `timestamp` field allows Kite to go directly to the files for a particular day, ignoring files outside the time period. Partition strategies are defined in JSON format. See [Partition Strategy JSON Format][partition-strategies].

The following sample defines a strategy that partitions a dataset by _year_, _month_, and _day_, based on a _timestamp_ field.

### partition_year_month_day.json

```
[ {
  "source" : "timestamp",
  "type" : "year",
  "name" : "year"
}, {
  "source" : "timestamp",
  "type" : "month",
  "name" : "month"
}, {
  "source" : "timestamp",
  "type" : "day",
  "name" : "day"
} ]
```

[partition-strategies]:{{site.baseurl}}/Partition-Strategy-Format.html

## Creating the Events Dataset Using the Kite CLI

Create the _events_ dataset using the default Hive scheme.

To create the _events_ dataset:

1. Open a terminal window.
1. Use the `create` command to create the dataset. This example assumes that you stored the schema and partition definitions in your home directory. Substitute the correct path if you stored them in a different location.

```
kite-dataset create events \
             --schema ~/standard_event.avsc \
             --partition-by ~/partition_year_month_day.json
```

Use [Hue][hue] to confirm that the dataset appears in your table list and is ready to use.

[hue]:http://quickstart.cloudera:8888/beeswax/execute#query
