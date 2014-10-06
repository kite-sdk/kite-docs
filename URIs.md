---
layout: page
title: Dataset and View URIs
---

Datasets are identified by URI. As a general rule, you can use a URI any time you would specify a dataset or view. If you attempt to perform an action on a view that is not allowed, the action fails. For example, if you try to delete a view using `Datasets.delete()`, the command fails, because you can only delete datasets, not views of the dataset, when using the Datasets API. 

## Dataset URIs

You construct a dataset URI using one of the following patterns, depending on your chosen dataset scheme.

| Scheme | Pattern
---------|--------
| <a href="#hive">*Hive*</a> |`dataset:hive:<namespace>/<dataset>`
| <a href="#hdfs">*HDFS*</a> | `dataset:hdfs:/<path>/<namespace>/<dataset-name>`
| <a href="#local">*Local FS*</a> | `dataset:file:/<path>/<namespace>/<dataset-name>`
| <a href="#hbase">*HBase*</a> | `dataset:hbase:<zookeeper>/<dataset-name>`

Dataset patterns always begin with the `dataset:` prefix. Any of these patterns can be modified to create a <a href="#view">View URI</a>.

<a name="hive" />

### Hive

Hive manages your datatables for you. You only have to provide the dataset name. You also have the option of providing a namespace.

```
dataset:hive:<namespace>/<dataset>
```

If you want to use external Hive datatables, you must also provide a path to the dataset. If you don't explicitly set a namespace, Kite uses the default namespace. For a Hive dataset, a Kite namespace maps one-to-one to a Hive database.

```
dataset:hive:/<path>/<namespace>/<dataset-name>
```

In earlier versions of Kite, `dataset:hive:a/b` meant directory ./a/b  Now, it has changed to _namespace_=a _dataset_=b.

To create an external table, add `location=/path/to/data/dir` to the dataset URI. 

```
dataset:hive:namespace/dataset?location=/path/to/data/dir
```

<a name="hdfs" />

### HDFS

The URI for a dataset in HDFS uses the following pattern. You provide a path to the dataset.
```
dataset:hdfs:/<path>/<namespace>/<dataset-name>
```

While it is not a typical use case, there might be times where it is useful to specify the HDFS host and port. You can insert the host and port before the path in the URI. You can use these URIs to select between HDFS instances.

The host and port are required if your Hadoop configuration files aren't on your classpath. This can happen if your application is running outside the cluster and you haven't taken the step of deploying client configuration files to the server running the application. The host is the hostname for the namenode; the port is the port for the namenode (typically 8020). If you have an HA configuration, you always need client configuration files, and the host should be the NameService ID.

```
dataset:hdfs://<host>[:port]/<path>/<namespace>/<dataset-name>
```

<a name="local" />

### Local File System Datasets

The local file system dataset URI follows a pattern similar to the HDFS URI, with the `file:` scheme.

```
dataset:file:/<path>/<namespace>/<dataset-name>
```

<a name="#hbase" />

### HBase

```
hbase:<zookeeper>/<dataset-name>
```

The _zookeeper_ argument is a comma separated list of hosts.  For example

```
hbase:host1,host2:9999,host3/myDataset
```

<a name="view" />

## View URIs

A view URI is constructed by changing the prefix of a dataset URI from `dataset:` to `view:`. You then add query arguments as name/value pairs, similar to query arguments in an HTTP URL. Query arguments place constraints on the information returned in the view. 

```
view:<scheme-specific-URI>?<field>=<constraint>
```

For example, you can restrict values returned from a table of _users_ to users whose favorite color is pink.

```
view:hdfs:/default/cloudera/users?favoriteColor=pink
```
You can insert records in a view, and the changes are reflected in the source dataset. 

You can also set constraints based on dataset partitions. For example, if a dataset of movie ratings were partitioned by date, you might create the view URI this way, constraining the ratings returned to March, 2014.

```
view:hdfs:/default/cloudera/ratings?year=2014&month=3
```

If the URI begins with `dataset:`, any constraints are ignored.

There are three formats used to set constraint values. The values can be numbers or strings, but the values you specify must match the schema definition for the field.

| Format | Constraint Type| Example | Meaning
| ------------------------
| empty | Exists (value is not null) | `favoriteColor=` | Field _favoriteColor_ is populated.
| comma-separated list | In (any of the specified values) | `genre=comedy,animation` | Field _genre_ is _comedy_ or _animation_. |
| interval | Range of values | `month=[1,4]` | Date is from January 1 through April 30. |

See [Interval Notation](../Interval-Notation/) for more examples of defining ranges of values.


