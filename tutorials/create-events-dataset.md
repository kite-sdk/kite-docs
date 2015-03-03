---
layout: page
title: Creating the Events Dataset
---

This lesson shows you how to create a dataset suitable for storing standard event records. You define a dataset schema, a partition strategy, and a URI that specifies the storage scheme.

## Defining the Schema

The `standard_event.avsc` schema is self-describing, thanks to the _doc_ property for each of the fields. The fields store the `user_id` for the person who initiated the event, the user's IP address, and when the event occurred.

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

For convenience, save `standard_event.avsc` to the same directory where you installed the kite-dataset executable JAR.

## Defining the Partition Strategy

Analytics for the `events` dataset are time-based. Partitioning the dataset on the `timestamp` field allows Kite to go directly to the files for a particular day, ignoring files outside the chosen time period. Partition strategies are defined in JSON format. See [Partition Strategy JSON Format][partition-strategies].

The following code sample defines a strategy that partitions a dataset by _year_, _month_, and _day_, based on a _timestamp_ field.

### standard_event.json

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

For convenience, save `standard_event.json` to the same directory where you installed the `kite-dataset` executable JAR.

[partition-strategies]:{{site.baseurl}}/Partition-Strategy-Format.html

## Creating the Events Dataset Using the Kite CLI

Create the _events_ dataset using the default Hive scheme.

To create the _events_ dataset:

1. Open a terminal window and navigate to the directory where you saved the schema file.
1. Use the `create` command to create the dataset.

```
kite-dataset create events \
             --schema standard_event.avsc \
             --partition-by standard_event.json
```

Use Hue to look at the schema and confirm that the dataset is ready to use.

[http://quickstart.cloudera:8888/filebrowser/view//tmp/data/default/events/.metadata/schema.avsc](http://quickstart.cloudera:8888/filebrowser/view//tmp/data/default/events/.metadata/schema.avsc)

## Next Steps

You've created a dataset to store events captured as they happen. Now you can run a web application to create records in your new dataset. See [Capturing Events with Flume][capture-events].

[capture-events]:{{site.baseurl}}/tutorials/flume-capture-events.html