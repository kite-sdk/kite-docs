---
layout: page
title: Introduction to Datasets
---

A dataset is a collection of records, similar to a relational database table. Records are similar to table rows, but the columns can contain not only strings or numbers, but also nested data structures such as lists, maps, and other records.

To define a dataset, Kite minimally requires a [URI](#uris) and a [schema](#schemas).

## URIs

Kite identifies datasets by URI. The URI you provide tells Kite how and where to store data. For example, a dataset created with the URI `dataset:hdfs:/user/cloudera/datasets/movies` is stored in HDFS.

The default storage _scheme_ (as opposed to a _[schema](#schemas)_, described below) is Hive. If you omit the scheme in your URI, your dataset is stored in Hive. For example, the URI `movies` is equivalent to `dataset:hive:/movies`. A dataset you create with this URI is stored as a table in Hive's `default` database.

Dataset URIs cannot contain periods (.).

You can create datasets in Hive, HDFS, HBase, or as local files. See [Dataset and View URIs]({{site.baseurl}}/URIs.html).

## Schemas

A schema defines the field names and datatypes for a dataset. Kite relies on an Apache Avro schema definition for each dataset. For example, this is the schema definition for a table using four columns from the `movies` dataset.[<sup>1</sup>](#notes)

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

The goal is to get the schema into `.avsc` format. The following links provide examples for inferring schemas from data files or Java classes.

| Java API                                                      | Command Line Interface |
| --------                                                      | ---------------------- |
| [Inferring a schema from a Java Class][api-schema-from-class] | [Inferring a schema from a Java class][cli-schema-from-class] |
| [Using the schema of an Avro data file][api-schema-from-data] | [Inferring a schema from a CSV file][cli-schema-from-csv] |

[api-schema-from-class]: {{site.baseurl}}/Inferring-a-Schema-from-a-Java-Class.html
[api-schema-from-data]: {{site.baseurl}}/Inferring-a-Schema-from-an-Avro-Data-File.html
[cli-schema-from-class]: {{site.baseurl}}/cli-reference.html#obj-schema
[cli-schema-from-csv]: {{site.baseurl}}/cli-reference.html#csv-schema

## Configuration Options

While you need only a URI and schema to create a dataset, you can enhance the performance of your dataset with additional configuration.

### Partitions

Partitions define logical categories for data storage. For example, you might most often retrieve your data using time-based queries. You can define a partitioning strategy by year, month, day, and hour. When you look for data from January 8, 2015 between 8:00 and 9:00 a.m., your search engine only has to look in the data partition `/2015/1/8/8`. By using partitions that correspond to your most common queries, your data searches run more quickly.

You define your partition strategy in [JSON format][json-format] and apply it when you create your dataset. See [Partitioned Datasets][partition-strategy].

[json-format]: {{site.baseurl}}/Partition-Strategy-Format.html
[partition-strategy]: {{site.baseurl}}/Partitioned-Datasets.html


### Column Mapping

Column mapping allows you to configure how your records should be stored in HBase for maximum performance and efficiency. You define column mapping in JSON format in a data-centric way. Kite stores and retrieves the data correctly. See [Column Mapping][column-mapping].

[column-mapping]: {{site.baseurl}}/Column-Mapping.html

### Properties

You can add custom settings to dataset properties at creation time using the `--set` option. For example, you might create the dataset _users_ using a cache size of 20 (rather than the default cache size of 10):

```
kite-dataset create users --schema user.avsc --set kite.writer.cache-size=20
```

You can also define key-value pairs to use as custom properties in your application by appending the option `--set prop.name=value`.

## Working with Datasets

Datasets you create using Kite are no different than any other Hadoop dataset. For example, you can query the data with Hive and Impala. You can use commands in the Kite CLI and API for additional manipulation and analysis.

### Loading Data from CSV

You can load comma separated value records into a dataset using the command line interface function [csv-import][csv-import].

[csv-import]: {{site.baseurl}}/cli-reference.html#csv-import

### Showing Your Data

For quick verification that your data has loaded properly, you can retrieve the top _n_ records in your dataset using the command line interface function [show][cli-show].

You can query your dataset using Hive and Impala in Hue, by using Impala from a terminal command line, or however you typically interact with datasets in Hadoop.

You can also retrieve a subset of the records in your dataset by defining a view. See [Dataset and View URIs][dataset-uris].

[cli-show]: {{site.baseurl}}/cli-reference.html#show
[dataset-uris]: {{site.baseurl}}/URIs.html
---

#### Notes:
1. The MovieLens data set was created by the GroupLens Research Group at the University of Minnesota and is available at [http://grouplens.org/datasets/movielens/](http://grouplens.org/datasets/movielens/).