---
layout: page
title: Dataset URIs
---

Datasets are identified by URI. As a general rule, you can use a URI any time you would specify a dataset or view. If you attempt to perform an action on a view that is not allowed, the action fails. For example, if you try to delete a view, the command will fail, because you can only delete datasets, not views into the dataset. You can, however, insert records in a view, and the changes are reflected in the source dataset tables.

## Dataset URIs

You construct a dataset URI using variations on the following pattern.

```
dataset:<scheme>:/<path>/<namespace>/<dataset-name>
```
The _scheme_ is the storage format (for example, _hdfs_, _hive_).

_Namespaces_ let you work with multiple datasets as one logical group.

The _dataset-name_ is...well, you know, the name of the dataset.

### HDFS

The URI for a dataset in HDFS uses the following pattern.

```
dataset:hdfs:/<path>/<namespace>/<dataset-name>
```

While it is not a typical use case, there might be times where it is useful to reference a dataset on a separate host machine. You can insert the host and port before the path in the URI.

The host and port are required if your Hadoop configuration files aren't on your classpath. This can happen if your application is running outside the cluster and you haven't taken the step of deploying client configuration files to the server running the application. The host is the hostname for the namenode; the port is the port for the namenode (typically 8020). If you have an HA configuration, you always need client configuration files, as the there is no single hostname for the namenode.

HDFS URIs can also be used to select between HDFS instances.

```
dataset:hdfs://<host>[:port]/<path>/<namespace>/<dataset-name>
```

### Local File System Datasets

The local file system dataset URI follows a similar pattern, with the `file:` prefix.

```
dataset:file:/<path>/<namespace>/<dataset-name>
```

### Hive

Hive manages your datatables for you, you only have to provide the dataset name.

```
dataset:hive:?dataset=<name>[&namespace=<namespace>]
```

If you are managing Hive datatables externally, the format is similar to HDFS and filesystem.

```
dataset:hive:/<path>/<namespace>/<dataset-name>
```

If you don't explicitly set a namespace, Kite uses the default namespace. For Hive dataset, a Kite namespace maps one-to-one to a Hive database.

### HBase

```
hbase:<zookeeper>/<dataset-name>
```

Kite uses the default namespace for the HBase scheme.

The <zookeeper> argument is a comma separated list of hosts.  For example

```
hbase:host1,host2:9999,host3/myDataset
```

## View URIs

A view URI is constructed by changing the prefix of from `dataset:` to `view:`. You then add query arguments as name/value pairs, similar to query arguments in an HTML URL. 
The query arguments place constraints on the information returned in the view.

```
view:_dataset-specific_?_field_=_constraint_
```

For example, you can restrict values returned from a table of _users_ to users whose favorite color is pink.

```
view:hdfs:/default/cloudera/users?favoriteColor=pink
```

You can also set constraints based on dataset partitions. For example, if a dataset were partitioned by date, you might create the view URI this way, constraining the values returned to March, 2014.

```
view:hdfs:/default/cloudera/bontemps?year=2014&month=3
```

There are three formats used to set constraint values. The values can be numbers or strings, but the values you specify must match the schema definition for the field.

| Format | Constraint Type| Example
| ------------------------
| empty | Exists (value is not null) | `favoriteColor=` (has a favorite color)
| comma-separated list | In (any of the specified values) | `genre=comedy,animation` (genre is _comedy_ or _animation_)
| interval | Range of values | `month=[1,3]` (January to March)

See [Interval Notation](../Interval-Notation/) for more examples of defining ranges of values.


