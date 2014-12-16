---
layout: page
title: Kite Dataset API
---

Most of the time, you can create sophisticated datasets and system prototypes using the Kite Command Line Interface (CLI). However, there are other use cases where you require the additional control offered by working directly with the Kite Dataset API. For example, if you are a creating a Hadoop dataset for a client, you can use the API to provide a distributable application that installs automatically from the Maven command line. You have the flexibility to use the CLI to quickly generate the application components you require, then use the API to create distributable applications of greater autonomy and complexity.

## Dataset

A dataset is essentially the same as a table in a database. It stores rows of information divided into logical columns.

A Kite `Dataset` object defines the fields for a single row in a dataset. However, you don't edit a `Dataset` object directly. The only methods defined by the `Dataset` class have to do with accessing information after the `Dataset` is created.

Instead, you use methods from the `Datasets` class to interact with your Kite `Dataset` instance.
## Datasets

The `Datasets` class is the workhorse of the Kite Data API. It provides methods to create, load, update, and delete `Dataset` objects.

### create()

To create a dataset using the Kite API, you need two things:

* A URI to where the dataset and metadata are stored
* A `DatasetDescriptor` object

#### Dataset URI

Datasets are identified by URI. The dataset URI determines where Kite creates and stores the metadata and data for your dataset.

For example, if you want to create the `products` dataset in Hive, you can use this URI.

```
dataset:hive?dataset=products
```

Common dataset URI schemes are Hive, HDFS, Local FileSystem, and HBase. See [Dataset and View URIs](../URIs/).

#### DatasetDescriptor

A `DatasetDescriptor` provides the structural definition of a dataset.

When you create a `Dataset`, you specify the associated `Schema` object and an optional `PartitionStrategy`. The `DatasetDescriptor` object stores this information.

You create a `DatasetDescriptor` object using the fluent `DatasetDescriptor.Builder()`.

At a minimum, you must specify an Avro schema definition for your dataset.

##### Avro Schema

A schema defines the field names and datatypes for a dataset. For example, this is the schema definition for the products dataset. It defines a _name_ field as a string and an _id_ field as an integer.

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
      "type": "int"
    }
  ]
}
```
Store the schema file in the `src/main/resources` directory in your Maven project. Maven looks in this directory for URIs with the prefix `resource:` by default.

Once you have defined a schema, you can use `DatasetDescriptor.Builder()` to create a descriptor instance.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();
```

##### DatasetDescriptor options

There are several options available to you in addition to the mandatory schema when creating a DatasetDescriptor, including setting a partition strategy, specifying column mapping, and choosing formats for storage and compression.

###### Partition Strategy

You can build a `DatasetDescriptor` that includes a partition strategy, which gives hints to the system for optimal storage of information by logical categories on which to search and retrieve. See [Partitioned Datasets](../Partitioned-Datasets/) for a conceptual introduction. 

###### Column Mapping

If you are creating an HBase dataset, you can create logical mapping of your data into columns. See [Column Mapping](../column-mapping/) for a conceptual introduction.

###### Storage Format

The default storage format is Avro, which is best for datasets where you typically query all of the columns in the dataset. You have the option using the Parquet format, which is more performant when you typically query a subset of the available columns. You can also choose CSV format, which stores your data in less performant, but human-readable, comma-separated values.

###### Compression Format

Kite uses _Snappy_ compression by default. You have the option of using _Deflate_, _Bzip2_, _Lzo_, or _Uncompressed_ formats.

You can `DatasetDescriptor.Builder` to include some or all of these settings when you create your dataset. See [DatasetDescriptor.Builder](http://kitesdk.org/docs/current/apidocs/org/kitesdk/data/DatasetDescriptor.Builder.html).

#### Create the Dataset

With a storage URI and a DatasetDescriptor, you can create a dataset instance.

```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
  .schemaUri("resource:product.avsc")
  .build();

Datasets.create("dataset:hive?dataset=products", descriptor);
```
The `create` command creates an empty dataset. To populate the dataset, you can invoke a DatasetWriter instance.

##### DatasetWriter

The DatasetWriter class stores data in your Hadoop dataset in the format you choose when creating the dataset.

This example creates a generic record builder, reads in each item and assign an ID number, then writes each record to the dataset.

```Java
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
    }
  }
. . .
```

### load

You can retrieve the records from your dataset using `DatasetReader`. It has methods that support iterating through the records in a dataset one at a time. 

This code snippet shows the code you use to load a dataset, then print the records one at a time to the console.

```Java
Dataset<Record> products = Datasets.load(
    "dataset:hive?dataset=products", Record.class);

DatasetReader<Record> reader = null;

try {

  reader = products.newReader();

  for (GenericRecord product : products.newReader()) {
      System.out.println(product);

}
```

### update

Over time, your dataset requirements might change. You can add, remove, or change the datatype of columns in your dataset, provided you don't attempt a change that would result in the loss or corruption of data. Kite follows the guidelines in the [Avro schema](http://avro.apache.org/docs/current/spec.html#Schema+Resolution). See [Schema Evolution](../Schema-Evolution/) for more detail and examples.

```Java
    Dataset<Record> products = Datasets.load(
        "dataset:hive?dataset=products", Record.class);

    DatasetDescriptor descriptor2 = new DatasetDescriptor.Builder()
        .schemaUri("resource:partitionedProduct2.avsc")
        .build(); 
    
     Dataset<Record> products2 = Datasets.create("dataset:hive?dataset=products2",
      descriptor2, Record.class);

    products2 = Datasets.<Record, Dataset<Record>>
		update("dataset:hive?dataset=products2", descriptor2, Record.class);
```

### delete

Delete the dataset, based on its URI. Kite takes care of any housekeeping, such as deleting metadata stored separately from the records themselves.

```Java
boolean success = Datasets.delete("dataset:hive?dataset=products");
```

## Avro Objects
Kite stores your dataset as an Avro object in the datastore by default. Files are compressed using Google's Snappy codec by default, and are not human readable. You can use the Hue data browser to view the information when it is stored in Hadoop.

See the [Avro specification](http://avro.apache.org/docs/1.7.5/spec.html#Object+Container+Files) for details on how Avro object files are constructed.

### Avro Object Model

Object models are in-memory representations of data. Avro, Hive, and Pig are examples of object models. Object model converters prepare your data for storage in your chosen format.
## Kite Dependencies

Kite dependencies are handled via Maven. If you reference the Project Object Model file `kite/kite-app-parent/pom.xml` in your own `pom.xml` file, all of the latest dependencies are downloaded automatically at run time.

To include the Kite dependencies, add the parent element to your `pom.xml` file. This example references version 0.18.0-SNAPSHOT. You should use the most recent version, or the most recent one that is compatible with your application.

```XML
  <parent>
    <groupId>org.kitesdk</groupId>
    <artifactId>kite-parent</artifactId>
    <version>0.18.0-SNAPSHOT</version>
  </parent>
```

