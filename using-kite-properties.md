---
layout: page
title: Using Kite Properties
---

In Kite, you can change settings of existing system properties to enhance performance. You can also create custom properties for additional control over how Kite reads or writes your data.

## Setting Kite Properties

Several dataset properties affect how files are written. These settings are especially relevant for Parquet, because it buffers records in memory. 

You set properties on your datasets with [`DatasetDescriptor.Builder.property`][dataset-descriptor-builder] when using the API, or with the `--set` option from the Kite CLI.

### kite.writer.cache-size

`kite.writer.cache-size` controls the number of files kept open by an HDFS or Hive dataset writer. The default cache size is 10.

Writers open one file per partition to which they write records. When the writer receives a record that goes in a new partition (one for which there isn't an open file), it creates a new file in that partition. If the number of open files exceeds the cache size, Kite closes the file with the oldest timestamp (the file that was used _least_ recently).

Adjusting the writer cache size can improve performance for some applications. For example, you might have an application writing a year's worth of data to year/month partitions. There are 12 partitions, but, by default, only 10 files can be open at the same time. The application must constantly close and open files, which slows down your writes. If you increase the writer cache to 12, files for all 12 months are open at once. To increase the writer cache size, use the CLI `update` command.

```
kite-dataset update dataset:hdfs:/user/me/datasets/annual_earnings --set kite.writer.cache-size=12
```

### parquet.block.size

Kite passes descriptor properties to the underlying file formats. For example, Parquet defines `parquet.block.size`, which is approximately the amount of data that is buffered before writing a group of records (a _row group_). `parquet.block.size` defaults to 128 MB.

#### Avoiding Parquet OutOfMemory Exceptions

The amount of data kept in memory for each file can be up to the Parquet block size. So, the upper bound for a writer's memory consumption is `parquet.block.size` multiplied by the `kite.writer.cache-size`. If this number  exceeds a reasonable portion of the heap memory allocated to the process, the write could fail with an `OutOfMemoryException`.

You can avoid out-of-memory exceptions by writing to fewer files. When working with Crunch, use [CrunchDatasets.partition][cd-partition] methods to restructure data so that all of the records stored in a given partition are processed by the same writer.

[cd-partition]:{{site.baseurl}}/apidocs/org/kitesdk/data/crunch/CrunchDatasets.html#partition(org.apache.crunch.PCollection,%20org.kitesdk.data.Dataset)

## Creating Custom Properties

In addition to setting existing system properties, you can create your own key-value pairs to use as custom properties in your application.

When using the  CLI [`create`][cli-reference-create] or [`update`][cli-reference-update] commands, add custom properties with the option `--set prop.name=value`.

When using the Kite API, add properties using [DatasetDescriptor.Builder.property][dataset-descriptor-builder].

[cli-reference-create]:{{site.baseurl}}/cli-reference.html#create
[cli-reference-update]:{{site.baseurl}}/cli-reference.html#update
[dataset-descriptor-builder]:{{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#property(java.lang.String,%20java.lang.String)