---
layout: page
title: Using Kite Properties
---

Kite gives you the option of changing settings of existing system properties to enhance performance. You also have the option of creating custom properties.

## Setting Kite Properties

There are several dataset properties that affect how files are written. These settings are especially relevant for Parquet because it buffers records in memory. 

You can set properties on your datasets with [`DatasetDescriptor.Builder.property`][dataset-descriptor-builder] when using the API, or with the `--set` option from the command line.

### kite.write.cache-size

`kite.write.cache-size` controls the number of files kept open by an HDFS or Hive dataset writer.

Writers open one file per partition to which they write records. When the writer receives a record that goes in a new partition (one for which there isn't an open file) it creates a new file in that partition. If the number of open files exceeds the cache size, Kite closes the file that was used least recently.

### parquet.block.size

Kite passes descriptor properties to the underlying file formats. For example, Parquet defines `parquet.block.size`, which is approximately the amount of data that is buffered before writing a group of records (a "row group"). `parquet.block.size` defaults to 128MB.

#### Avoiding Parquet OutOfMemory Exceptions

The amount of data kept in memory for each file could be up to the Parquet block size in bytes. That means that the upper bound for a writer's memory consumption is `parquet.block.size` * `kite.writer.cache-size`. It is important that this number doesn't exceed a reasonable portion of the heap memory allocated to the process, or else the write could fail with an `OutOfMemoryException`. 

```
kite-dataset update <uri> --set kite.writer.cache-size=2
```

Note that Cloudera does not recommend decreasing the `parquet.block.size`.

## Creating Custom Properties

In addition to setting existing system properties, you can create your own key-value pairs to use as custom properties in your application. When using the  CLI [`create`][cli-reference-create] or [`update`][cli-reference-update] command, you add custom properties with the option `--set prop.name=value`.

When using the Kite API, you can add properties using [DatasetDescriptor.Builder.property][dataset-descriptor-builder].

[cli-reference-create]:{{site.baseurl}}/cli-reference.html#create
[cli-reference-update]:{{site.baseurl}}/cli-reference.html#update
[dataset-descriptor-builder]:{{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#property(java.lang.String,%20java.lang.String)