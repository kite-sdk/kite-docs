---
layout: page
title: Kite Dataset API
---

Most of the time, you can create datasets and system prototypes using the [Kite command line interface][cli-intro] (CLI). When you want to perform these tasks using a Java program, you can use the Kite API. With the Kite API, you can perform tasks such as reading a dataset, defining and reading views of a dataset, and using MapReduce to process a dataset.

[cli-intro]: {{site.baseurl}}/Using-the-Kite-CLI-to-Create-a-Dataset.html

## Dataset

A dataset is a collection of records, like a relational table. Records are similar to table rows, but the columns can contain strings, numbers, or nested data structures such as lists, maps, and other records.

The `Dataset` interface provides methods to work with the collection of records it represents. A `Dataset` is [immutable][def-immutable].

### Dataset URIs

Datasets are identified by URI. The dataset URI determines how Kite stores your dataset and its configuration metadata.

For example, if you want to create the `products` dataset in Hive, you can use this URI.

```
dataset:hive:products
```

Common dataset URI patterns are Hive, HDFS, Local FileSystem, and HBase. See [Dataset and View URIs][uris].

[uris]: {{site.baseurl}}/URIs.html

### DatasetDescriptors

A `DatasetDescriptor` provides the structural definition of a dataset. It encapsulates all of the configuration needed to read and write data.

When you create a `Dataset`, you supply a `DatasetDescriptor`. That descriptor is saved and used by Kite when you interact with the dataset.

At a minimum, a `DatasetDescriptor` requires the record [schema](#avro-schema), which describes the records. You create a `DatasetDescriptor` object using the fluent [`DatasetDescriptor.Builder`][javadoc-descriptor-builder] to set the schema and other configuration. See [DatasetDescriptor Options](#datasetdescriptor-options) for more configuration options.

[javadoc-descriptor-builder]: {{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html

## Datasets

The `Datasets` class is the starting point when working with the Kite Data API. It provides operations around datasets, such as creating or deleting a dataset.

### create

With a storage URI and a DatasetDescriptor, you can use `Datasets.create` to create a dataset instance. This example creates a dataset named _products_ in the Hive metastore.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();

Dataset<Record> products = Datasets.create("dataset:hive:products", descriptor);
```

The `create` command creates an empty dataset. You can use a [`DatasetWriter`](#datasetwriter) to populate your dataset.

### load

Load an existing dataset for processing using the `load` method. The load method verifies that the dataset exists, retrieves the dataset's metadata, and verifies that you can communicate with its services. 

```Java
Dataset<Record> products = Datasets.load("dataset:hive:products");
```

Once you load the dataset, you can retrieve and view the dataset records using [`DatasetReader`](#datasetreader).

### update

Over time, your dataset requirements might change. You can use `update` to change a dataset's configuration by replacing its `DatasetDescriptor`.

You can add, remove, or change the datatype of columns in your dataset, provided you don't attempt a change that would corrupt the data. Kite follows the guidelines in the [Avro schema](http://avro.apache.org/docs/current/spec.html#Schema+Resolution). See [Schema Evolution](../Schema-Evolution/) for more detail and examples.

This example updates the schema for the existing _products_ dataset. First, it creates a new descriptor builder from the existing descriptor, to copy its settings, then adds `products_v2.avsc` as the schema and builds a new descriptor. Then it updates the dataset to use that new descriptor.

```Java
Dataset<Record> products = Datasets.load(
  "dataset:hive:products", Record.class);

DatasetDescriptor updatedDescriptor = new DatasetDescriptor.Builder(originalDescriptor)
  .schemaUri("resource:product_v2.avsc")
  .build(); 

Datasets.update("dataset:hive:products", updatedDescriptor);
```

### delete

Delete a dataset, based on its URI, with the `delete` method. Kite takes care of any housekeeping, such as deleting both data and any metadata stored separately.


```Java
Datasets.delete("dataset:hive:products");
```

## Working with Datasets

### Avro Objects

Regardless of the underlying storage format, Kite uses Avro's object models for its in-memory representations of data. This means you can write applications that use the same object classes and store the dataset in any of the available formats. To change the underlying storage format in your application, you only need to change its dataset URI.

In this introduction, Kite returns Avro's [generic][avro-generic] data classes. Kite also supports Avro's [specific][avro-specific] and [reflect][avro-reflect] object models.

[avro-generic]: https://avro.apache.org/docs/1.7.7/api/java/index.html?org/apache/avro/generic/package-summary.html
[avro-specific]: http://avro.apache.org/docs/1.7.7/api/java/index.html?org/apache/avro/specific/package-summary.html
[avro-reflect]: https://avro.apache.org/docs/1.7.7/api/java/index.html?org/apache/avro/reflect/package-summary.html

#### Avro Schema

A schema defines the field names and data types for records in a dataset. For example, this is the schema definition for the products dataset. It defines a _name_ field as a string and an _id_ field as an integer.

```json
{
  "type": "record",
  "name": "Product",
  "namespace": "org.kitesdk.examples.data.generic",
  "doc": "A product record",
  "fields": [
    {
      "name": "name",
      "type": "string"
    },
    {
      "name": "id",
      "type": "long"
    }
  ]
}
```

Once you have defined a schema, you can use `DatasetDescriptor.Builder` to create a descriptor instance and a dataset using that descriptor. Once a dataset is created, its schema is loaded automatically.


### DatasetDescriptor Options

A `DatasetDescriptor` encapsulates the configuration needed to read and write a dataset. A `DatasetDescriptor` is [immutable][def-immutable], and is created by [`DatasetDescriptor.Builder`][javadoc-descriptor-builder].

There are several options available when creating a descriptor:
* [Set the record schema](#schema) (**required**)
* [Add a partition strategy](#partition-strategy)
* [Choose the data format](#storage-format) and [compression](#compression-type)
* Add custom key-value properties

[def-immutable]: https://jsr-305.googlecode.com/svn/trunk/javadoc/javax/annotation/concurrent/Immutable.html

#### Schema

A key element of the dataset descriptor is the record schema. There are a number of ways to find and set the schema using the [`DatasetDescriptor.Builder#schema`][javadoc-descriptor-builder-schema] methods. For example, you can read a schema definition file from HDFS or the classpath, you can use the schema from an existing data file, or you can use the builder to inspect any Java class and build a schema for it.

This example reads a schema definition file, _product.avsc_, from a project's JAR that was built with the schema in `src/main/resources/`.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
    .schema("resource:product.avsc")
    .build();
```

[javadoc-descriptor-builder-schema]: {{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#schema(org.apache.avro.Schema)

#### Partition Strategy

Datasets commonly use a partition strategy to control the data layout for efficient storage and retrieval. You can pass both a [`PartitionStrategy`][javadoc-partition-strategy] object or a [partition strategy JSON definition][partition-strategy-json] to [`DatasetDescriptor.Builder#partitionStrategy`][javadoc-descriptor-builder-strategy]. See [Partitioned Datasets][partitioned-datasets] for a conceptual introduction. 

This example constructs a descriptor with its partition strategy created by [`PartitionStrategy.Builder`][javadoc-strategy-builder].

```Java
PartitionStrategy ymd = new PartitionStrategy.Builder()
    .year("timestamp")
    .month("timestamp")
    .day("timestamp")
    .build();

DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
    .schema("resource:event.avsc")
    .partitionStrategy(ymd)
    .build();
```

Note that a [schema](#schema) is always required to build a descriptor.

[javadoc-descriptor-builder-strategy]: {{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#partitionStrategy(org.kitesdk.data.PartitionStrategy)
[partitioned-datasets]: {{site.baseurl}}/Partitioned-Datasets.html
[javadoc-partition-strategy]: {{site.baseurl}}/apidocs/org/kitesdk/data/PartitionStrategy.html
[partition-strategy-json]: {{site.baseurl}}/Partition-Strategy-Format.html

#### Storage Format

Storage format is set when you create a dataset and cannot be changed. See [`DatasetDescriptor.Builder#format`][javadoc-descriptor-builder-format].

The default storage format is Avro, which is the recommended format for most use cases.

You can alternatively use the Parquet format, which can result in smaller files and better read performance when using a subset of the dataset's record fields (columns).

Both Avro and Parquet are efficient binary formats that are designed for Hadoop. You can use the Kite CLI or the Hue data browser to view the compressed binary data stored in these formats.

[javadoc-descriptor-builder-format]: {{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#format(java.lang.String)

#### Compression Type

Kite uses _Snappy_ compression by default. You also have the option of using _Deflate_, _Bzip2_, _Lzo_, or _Uncompressed_ compression. See [`DatasetDescriptor.Builder#compressionType`][javadoc-descriptor-builder-compression]

[javadoc-descriptor-builder-compression]: {{site.baseurl}}/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html#compressionType(java.lang.String)

### DatasetWriter

The `DatasetWriter` class stores data in your dataset, using the layout and format you choose when creating the dataset.

This code snippet uses an Avro generic record builder to create a product from a list of names, assigns an ID number, and writes each record to the dataset.

```Java
DatasetWriter<Record> writer = null;

Dataset<Record> products = Datasets.load("dataset:hive:products", Record.class);

try {
  int i = 0;

  writer = products.newWriter();

  for (String item : items) {

    Record product = builder
      .set("name", item)
      .set("id", i)
      .build();

    writer.write(product);

    i += 1;
  }
} finally {
  if (writer != null) {
    writer.close();
  }
}
```

### DatasetReader

`DatasetReader` retrieves records in a dataset for inspection and processing. It has methods that support iterating through the records as they are read.

This code snippet shows the code you use to load a dataset, then print each record to the console.

```Java
Dataset<Record> products = Datasets.load(
  "dataset:hive:products", Record.class);

DatasetReader<Record> reader = null;

try {
  reader = products.newReader();

  for (GenericRecord product : reader) {
    System.out.println(product);
  }
} finally {
  if (reader != null) {
    reader.close();
  }
}
```

## Kite Data Artifacts

You can use the Kite data API by adding dependencies for the artifacts described below.

* [`kite-data-core`][dep-kite-data-core] has the Kite data API, including all of the Kite classes used in this introduction. It also includes the Dataset implementation for both HDFS and local file systems.
* [`kite-data-hive`][dep-kite-data-hive] is a Dataset implementation that creates Datasets as Hive tables and stores metadata in the Hive MetaStore. Add a dependency on kite-data-hive if you want to interact with your data through Hive or Impala
* [`kite-data-hbase`][dep-kite-data-hbase] is an experimental Dataset implementation that creates datasets as HBase tables.
* [`kite-data-crunch`][dep-kite-data-crunch] provides helpers to use a Kite dataset as a source or target in a Crunch pipeline.
* [`kite-data-mapreduce`][dep-kite-data-mapreduce] provides MR input and output formats that read from or write to Kite datasets.

See the [dependencies][deps] article for more information.

[deps]: {{site.baseurl}}/dependencies/
[dep-kite-data-core]: {{site.baseurl}}/dependencies/kite-data-core.html
[dep-kite-data-hive]: {{site.baseurl}}/dependencies/kite-data-hive.html
[dep-kite-data-hbase]: {{site.baseurl}}/dependencies/kite-data-hbase.html
[dep-kite-data-crunch]: {{site.baseurl}}/dependencies/kite-data-crunch.html
[dep-kite-data-mapreduce]: {{site.baseurl}}/dependencies/kite-data-mapreduce.html
