---
layout: page
title: Kite Dataset API
---

Most of the time, you can create datasets and system prototypes using the Kite Command Line Interface (CLI). When you want to perform these tasks using a Java program, you can use the Kite API. With the Kite API, you can perform tasks such as reading a dataset, defining and reading views, and using MapReduce to process a dataset.

## Dataset

A dataset is a collection of records, similar to a table. Records are similar to table rows, but the columns can contain strings, numbers, or nested data structures such as lists, maps, and other records.

The `Dataset` interface provides methods to work with the collection of records it represents. A `Dataset` is [immutable](https://jsr-305.googlecode.com/svn/trunk/javadoc/javax/annotation/concurrent/Immutable.html).

### Dataset URIs

Datasets are identified by URI. The dataset URI determines where Kite creates and stores the metadata and data for your dataset.

For example, if you want to create the `products` dataset in Hive, you can use this URI.

```
dataset:hive:products
```

Common dataset URI schemes are Hive, HDFS, Local FileSystem, and HBase. See [Dataset and View URIs](../URIs/).

### DatasetDescriptors

A `DatasetDescriptor` provides the structural definition of a dataset.

When you create a `Dataset`, you specify the associated `Schema` object. The `DatasetDescriptor` object stores this information. You create a `DatasetDescriptor` object using the fluent `DatasetDescriptor.Builder()`.

See [DatasetDescriptor Options](#DatasetDescriptor) for additional settings.
## Datasets

The `Datasets` class is the starting point when working with the Kite Data API. It provides operations around datasets, such as creating or deleting a dataset.

### load

You can retrieve the records from an existing dataset using `DatasetReader`. It has methods that support iterating through the records in a dataset one at a time. 

This code snippet shows the code you use to load a dataset, then print the records one at a time to the console.

```Java
. . .

  Dataset<Record> products = Datasets.load(
    "dataset:hive:products", Record.class);

  DatasetReader<Record> reader = null;

  try {

    reader = products.newReader();

    for (GenericRecord product : reader) {
      System.out.println(product);
  } finally {
    if (reader != null) {
      reader.close();
    }
  }
}
```

### create

With a storage URI and a DatasetDescriptor, you can use Datasets.create to create a dataset instance. This example creates a dataset named _products_ in the Hive metastore.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();

Datasets.create("dataset:hive:products", descriptor);
```

The `create` command creates an empty dataset. You can use a [`DatasetWriter`](#DatasetWriter) to populate your dataset.

### update

Over time, your dataset requirements might change. You can add, remove, or change the datatype of columns in your dataset, provided you don't attempt a change that would result in the loss or corruption of data. Kite follows the guidelines in the [Avro schema](http://avro.apache.org/docs/current/spec.html#Schema+Resolution). See [Schema Evolution](../Schema-Evolution/) for more detail and examples.

This example copies all of the settings from the existing _products_ dataset into a new dataset named _products2_. The new dataset incorporates any changes in the products_v2.avsc Avro schema.

```Java
Dataset<Record> products = Datasets.load(
  "dataset:hive:products", Record.class);

DatasetDescriptor updatedDescriptor = new DatasetDescriptor.Builder(originalDescriptor)
  .schemaUri("resource:product_v2.avsc")
  .build(); 

Datasets.update("dataset:hive:products", descriptor2);
```

### delete

Delete the dataset, based on its URI. Kite takes care of any housekeeping, such as deleting metadata stored separately from the records themselves.


```Java
boolean success = Datasets.delete("dataset:hive:products");
```

## Working with Datasets


<a name="DatasetWriter" />

### DatasetWriter

The DatasetWriter class stores data in your Hadoop dataset in the format you choose when creating the dataset.

This code snippet creates a generic record builder, reads in each item, assigns an ID number, then writes each record to the dataset.

```Java
. . .

DatasetWriter<Record> writer = null;

DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();

int i = 0;
try {
  GenericRecordBuilder builder = new GenericRecordBuilder(descriptor.getSchema());

  for (String item : items) {

    Record product = builder
      .set("name", item)
      .set("id", i++)
      .build();

    writer.write(product);
  } finally {
    if (writer != null) {
      writer.close();
    }
  }
. . .

```

## Avro Objects

Kite stores your dataset as an Avro object in the datastore by default. Any program that works with Kite uses Avro's object model, even though the Avro format might not be (when storing to Parquet or HBase).

In this introduction, Kite returns record instances defined by Avro, specifically Avro's generic data classes. Regardless of the underlying storage format, Kite uses Avro's object model so that applications can be written once: changing the underlying storage format is as simple as switching the dataset's URI.

Object models are in-memory representations of data. Avro, Hive, and Pig are examples of object models. Object model converters prepare your data for storage in your chosen format.

Kite also supports Avro's [specific](http://avro.apache.org/docs/1.7.7/api/java/index.html?org/apache/avro/specific/package-summary.html) and [reflect](http://avro.apache.org/docs/1.7.7/api/java/org/apache/avro/reflect/package-summary.html) object models.

Files are compressed using Google's Snappy codec by default, and are not human readable. You can use the Hue data browser to view your information when it is stored in Hadoop.

### Avro Schema

A schema defines the field names and data types for a dataset. For example, this is the schema definition for the products dataset. It defines a _name_ field as a string and an _id_ field as an integer.

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
Store the schema file in the `src/main/resources` directory in your Maven project. A URI that references `resource:` instructs Kite to look in the class path for the file and it will find it in the JAR at runtime.

Once you have defined a schema, you can use `DatasetDescriptor.Builder()` to create a descriptor instance.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();
```

<a name="DatasetDescriptor" />

## DatasetDescriptor Options

There are several options available to you in addition to the setting the schema when creating a DatasetDescriptor, including setting a partition strategy, and choosing formats for storage and compression.

### Schema

A key element of the dataset descriptor is the dataset's schema. There are a number of ways to find and use a schema, including a straightforward method that inspects a Java class for you and creates the field descriptions.

You can also create a DatasetDescriptor using an Avro schema definition for your dataset.

### Partition Strategy

You can build a `DatasetDescriptor` that includes a partition strategy. A partition strategy gives hints to the system for optimal storage of information by logical categories on which to search and retrieve. See [Partitioned Datasets](../Partitioned-Datasets/) for a conceptual introduction. 

### Storage Format

The default storage format is Avro, which is best for datasets where you typically query all of the columns in the dataset. You have the option of using the Parquet format, which is more performant when you typically query a subset of the available columns.

### Compression Format

Kite uses _Snappy_ compression by default. You have the option of using _Deflate_, _Bzip2_, _Lzo_, or _Uncompressed_ formats.

You can use `DatasetDescriptor.Builder` to include some or all of these settings when you create your dataset. See [DatasetDescriptor.Builder](http://kitesdk.org/docs/current/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html).

## Other Kite Data Artifacts

The `kite-data` package has additional modules with utilities that help you to implement additional tools for your Hadoop datasets.

* `kite-data-core` has the Kite data API, including all of the Kite classes used in this introduction. It also includes the Dataset implementation for both HDFS and local file systems.
* `kite-data-hive` is a Dataset implementation that creates Datasets as Hive tables and stores metadata in the Hive MetaStore. Add a dependency on kite-data-hive if you want to interact with your data through Hive or Impala
* `kite-data-hbase` is an experimental Dataset implementation that creates datasets as HBase tables.
* `kite-data-mapreduce` provides MR input and output formats that read from or write to Kite datasets.
* `kite-data-crunch` provides helpers to use a Kite dataset as a source or target in a Crunch pipeline.


