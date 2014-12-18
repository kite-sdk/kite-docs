---
layout: page
title: Kite Data Module Overview
---

The Kite Data module is a set of APIs for interacting with data in Hadoop; specifically, direct reading and writing of datasets in storage subsystems such as the Hadoop Distributed FileSystem (HDFS).

These APIs do not replace or supersede any of the existing Hadoop APIs. Instead, the Data module streamlines application of those APIs. You still use HDFS and Avro APIs directly, when necessary. The Kite Data module reflects best practices for default choices, data organization, and metadata system integration.

Limiting your options is not the goal. The Kite Data module is designed to be immediately useful, obvious, and in line with what most users do most frequently. Whenever revealing an option creates complexity, or otherwise requires you to research and assess additional choices, the option is omitted.

The data module contains APIs and utilities for defining and performing actions on datasets.

* <a href="#entities">entities</a>
* <a href="#schemas">schemas</a>
* <a href="#datasets">datasets</a>
* <a href="#repositories">dataset repositories</a>
* <a href="#loading">loading data</a>
* <a href="#writers">dataset writers</a>
* <a href="#viewing">viewing data</a>

Many of these objects are interfaces, permitting multiple implementations, each with different functionality. The current release contains an implementation of each of these components for the Hadoop `FileSystem` abstraction, for Hive, and for HBase.

While, in theory, any implementation of Hadoop’s `FileSystem` abstract class is supported by the Kite Data module, only the local and HDFS filesystem implementations are tested and officially supported.


## Entities

An entity is a single record in a dataset. The name _entity_ is a better term than _record_, because _record_ sounds as if it is a simple list of primitives, while _entity_ sounds more like a Plain Old Java Object, or POJO, (see [POJO][pojo] in Wikipedia) that could contain maps, lists, or other POJOs. That said, _entity_ and _record_ are often used interchangeably when talking about datasets. 

Entities can be simple types, representing data structures with a few string attributes, or as complex as required.

Best practices are to define the output for your system, identifying all of the field values required to produce the report or analytics results you need. Once you identify your required fields, you define one or more related entities where you store the information you need to create your output. Define the format and structure for your entities using a schema.

[pojo]: http://en.wikipedia.org/wiki/Plain_Old_Java_Object

## Schemas

A schema defines the field names and datatypes for a dataset. Kite relies on an Apache Avro schema definition for each dataset. For example, this is the schema definition for a table listing movies from the `movies.csv` dataset.[<sup>1</sup>](#notes)

```json
{
  "type":"record",
  "name":"Movie",
  "namespace":"org.kitesdk.examples.data",
  "fields":[
    {"name":"id","type":"int"},
    {"name":"title","type":"string"},
    {"name":"releaseDate","type":"string"},
    {"name":"imdbUrl","type":"string"}
  ]
}
```

The goal is to get the schema into `.avsc` format and store it in the Hadoop file system. There are several ways to get the schema into the correct format. The following links provide examples for some of these approaches.

| Java API                                                      | Command Line Interface |
| --------                                                      | ---------------------- |
| [Inferring a schema from a Java Class][api-schema-from-class] | [Inferring a schema from a Java class][cli-schema-from-class] |
| [Using the schema of an Avro data file][api-schema-from-data] | [Inferring a schema from a CSV file][cli-schema-from-csv] |

[api-schema-from-class]: {{site.baseurl}}/Inferring-a-Schema-from-a-Java-Class.html
[api-schema-from-data]: {{site.baseurl}}Inferring-a-Schema-from-an-Avro-Data-File.html
[cli-schema-from-class]: {{site.baseurl}}Kite-Dataset-Command-Line-Interface.html#obj-schema
[cli-schema-from-csv]: {{site.baseurl}}/Kite-Dataset-Command-Line-Interface.html#csv-schema

## Datasets
A dataset is a collection of zero or more entities, represented by the interface `Dataset`. The relational database analog of a dataset is a table.

The HDFS implementation of a dataset is stored as Snappy-compressed Avro data files by default. The HDFS implementation is made up of zero or more files in a directory. You also have the option of storing your dataset in the column-oriented Parquet file format.

Performance can be enhanced by defining a [partition strategy][partition-strategy] for your dataset.

You can work with a subset of dataset entities using the Views API.

Datasets are identified by URIs. See [Dataset URIs][dataset-uris]. Dataset names cannot contain a period (.).

[partition-strategy]: {{site.baseurl}}/Partitioned-Datasets.html
[dataset-uris]: {{site.baseurl}}/URIs.html

<a name="repositories" />

## Dataset Repositories

A _dataset repository_ is a physical storage location for datasets. Keeping with the relational database analogy, a dataset repository is the equivalent of a database of tables.

You can organize datasets into different dataset repositories for reasons related to logical grouping, security and access control, backup policies, and so on.

A dataset repository is represented by instances of the `org.kitesdk.data.DatasetRepository` interface in the Kite Data module. An instance of `DatasetRepository` acts as a factory for datasets, supplying methods for creating, loading, and deleting datasets.

Each dataset belongs to exactly one dataset repository. Kite doesn&apos;t provide built-in support for moving or copying datasets between repositories. MapReduce and other execution engines provide copy functionality, if you need it.

<a name="loading" />

## Loading Data from CSV

You can load comma separated value data into a dataset repository using the command line interface function [csv-import][csv-import].

[csv-import]: {{site.baseurl}}/Kite-Dataset-Command-Line-Interface.html#csv-import

<a name="writers" />

## Dataset Writers

Dataset writers add entities to your datasets (that is, add rows to your data tables). 

The `DatasetWriter` lifecycle is as follows:

1. `Dataset#newWriter()` returns a DatasetWriter instance.
2. `DatasetWriter#write()` writes an entity to a dataset.
3. `DatasetWriter#flush()` attempts to push buffered data from the client to the remote hosts. Some dataset implementations might not implement this method, depending on the guarantees available to the underlying storage system. In particular, when using HDFS-backed datasets, the Parquet format does not implement `flush()` by default.
4. `DatasetWriter#sync()` executes a `flush()` and waits for the remote hosts to force their buffers to persistent storage (for example, hard disks). Like `flush()`, `sync()` depends on support of the underlying format: Parquet is not supported by default.
5. `DatasetWriter#close()` closes the writer. If it returns without throwing an exception, any entity that was successfully written with `DatasetWriter#write()` is safely stored to persistent storage in all locations.

<a name="viewing" />

## Viewing Your Data

Datasets you create Kite are no different than any other Hadoop dataset in your system, once created. You can query the data with Hive or view it using Impala.

For quick verification that your data has loaded properly, you can view the top _n_ records in your dataset using the command line interface function [show][cli-show].

[cli-show]: {{site.baseurl}}/Kite-Dataset-Command-Line-Interface.html#show


---

#### Notes:
1. The MovieLens data set was created by the GroupLens Research Group at the University of Minnesota and is available at [http://grouplens.org/datasets/movielens/](http://grouplens.org/datasets/movielens/).
