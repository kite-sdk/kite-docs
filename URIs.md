---
layout: page
title: URIs
---

You can reference datasets and views by URI. As a general rule, you can use a URI any time you would specify a dataset or view. If you attempt to perform an action on a view that is not allowed, the action fails. For example, if you try to delete a view, the command will fail, because you can only delete datasets, not views into the dataset. You can, however, update records in a view, and the changes are reflected in the source dataset tables.

## Dataset URIs

You construct a dataset URI using the following pattern.

```
dataset:<scheme>:/<path>/<namespace>/<dataset-name>
```
The scheme is the storage format (for example, _hdfs_, _hive_).

_Namespaces_ let you work with multiple datasets as one logical group.

The _dataset-name_ is...well, you know, the name of the dataset.

### HDFS
The URI for a dataset in HDFS uses the following pattern.

```
dataset:hdfs:/<path>/<namespace>/<dataset-name>
```
While it is not a typical use case, there might be times where it is useful to reference a dataset on a separate host machine. You can insert the host and port before the path in the URI.

```
dataset:hdfs://<host>[:port]/<path>/<namespace>/<dataset-name>
```

### File System

The file system URI follows the same pattern.

```
dataset:file:/<path>/<namespace>/<dataset-name>
```

### Hive

If you are managing Hive datatables externally, the format is similar to HDFS and filesystem.

```
dataset:hive:/<path>/<namespace>/<dataset-name>
```

If you are letting Hive manage your datatables for you, you only have to provide the dataset name.

```
dataset:hive:?dataset=<name>[&namespace=<namespace>]
```

If you don't explicitly set a namespace, Kite uses the default namespace.

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

A view URI starts the same as a dataset URI. You then add arguments as name/value pairs, similar to arguments in an HTML URI. 
The arguments place constraints on the information returned in the view.

```
view:<scheme>:/<path>/<namespace>/<dataset-name>?arg1=val1[&arg2=val2&...]
```

For example, you can restrict values returned from a table of _users_ to users with a particular email address.

```
view:hdfs:/default/cloudera/users?email=cloudera@cloudera.com
```

You can also set  constraints based on dataset partitions. For example, if a dataset were partitioned by date, you might create the view URI this way, constraining the values returned to March, 2014.

```
view:hdfs:/default/cloudera/bontemps?year=2014&month=03
```

There are three formats used to set constraint values. The values can be numbers or strings, but the values you specify must match the schema definition for the field.

| Format | Constraint Type| Example
| ------------------------
| empty | Exists (value is not null) | `id=`
| comma-separated list | In (any of the specified values) | `id=1,2,5`
| set notation | Range | `id=[1,5]`

See [Set Notation](../Set-Notation/) for more examples of defining ranges of values.


