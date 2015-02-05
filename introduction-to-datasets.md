---
layout: page
title: Introduction to Datasets
---

A dataset is a collection of records, similar to a relational database table. Records are similar to table rows, but the columns can contain not only strings or numbers, but also nested data structures such as lists, maps, and other records.

To define a dataset, Kite minimally requires a [URI](#uris) and a [schema](#schemas). Other considerations would include deciding how to partition your data and additional configuration options.

When using the CLI, you define your dataset using the [`create`][create] command. When using the API, you define your dataset using the [Datasets.create][datasets-create] method.

[create]:{{site.baseurl}}/cli-reference.html#create
[datasets-create]:{{site.baseurl}}/apidocs/org/kitesdk/data/Datasets.html#create(java.net.URI,%20org.kitesdk.data.DatasetDescriptor)

## URIs

Kite identifies datasets by URI. The URI you provide tells Kite how and where to store data. For example, a dataset created with the URI `dataset:hdfs:/user/cloudera/fact_tables/ratings` is stored in the `/user/cloudera/fact_tables/ratings` directory in HDFS.

### Names and Namespaces 

URIs also define a name and namespace for your dataset. Kite uses these values when the underlying system has the same concept (for example, Hive). The name and namespace are typically the last two values in a URI. For example, if you create a dataset using the URI `dataset:hive:fact_tables/ratings`, Kite stores a Hive table _ratings_ in the _fact___tables_ Hive database. If you create a dataset using the URI `dataset:hdfs:/user/cloudera/fact_tables/ratings`, Kite stores an HDFS dataset named _ratings_ in the _fact___tables_ namespace.

To ensure compatibility with Hive and other underlying systems, names and namespaces in URIs must be made of alphanumeric or underscore (\_) characters  and cannot start with a number.

### URI Schemes

You can create datasets in Hive, HDFS, HBase, or as local files. The dataset schemes are defined using scheme-specific URI patterns. See [Dataset and View URIs][uris].

Note that a URI _scheme_, which describes the storage location type, is different than a dataset _schema_, which describes the format of records in the dataset.

[list]: {{site.baseurl}}/apidocs/org/kitesdk/data/Datasets.html#list(java.net.URI)
[uris]:{{site.baseurl}}/URIs.html

## Schemas

A schema defines the field names and datatypes for a dataset. Kite relies on an Apache Avro schema definition for all datasets. Kite standardizes data definition by using Avro schemas for both Parquet and Avro, and supports the standard Avro object models _generic_ and _specific_.

For example, this is the schema definition for a table using four columns from the `movies` dataset.[<sup>1</sup>](#notes)

```json
{
  "type":"record",
  "name":"Movie",
  "namespace":"org.kitesdk.examples.data",
  "fields":[
    {"name":"id","type":"int"},
    {"name":"title","type":"string"},
    {"name":"release_date","type":"string"},
    {"name":"imdb_url","type":"string"}
  ]
}
```

The following links provide examples for inferring schemas from data files or Java classes.

| Java API                                                      | Command Line Interface |
| --------                                                      | ---------------------- |
| [Inferring a schema from a Java Class][api-schema-from-class] | [Inferring a schema from a Java class][cli-schema-from-class] |
| [Using the schema of an Avro data file][api-schema-from-data] | [Inferring a schema from a CSV file][cli-schema-from-csv] |

[api-schema-from-class]: {{site.baseurl}}/Inferring-a-Schema-from-a-Java-Class.html
[api-schema-from-data]: {{site.baseurl}}/Inferring-a-Schema-from-an-Avro-Data-File.html
[cli-schema-from-class]: {{site.baseurl}}/cli-reference.html#obj-schema
[cli-schema-from-csv]: {{site.baseurl}}/cli-reference.html#csv-schema

## Partition Strategies

Partitions define logical divisions for data storage. For example, you might most often work with data using time-based queries. You can define a partitioning strategy by year, month, and day. When you are using data from January 8, 2015, Hadoop only has to access data stored in the partition `/year=2015/month=1/day=8`. By using partitions that correspond to your most common queries, your applications run more quickly.

You should always consider partitioning as a best practice when planning your dataset. Partitioning is optional because there are times when partitioning is not the most efficient solution. 

Kite validates your partition strategy using the dataset schema. This catches problems early. For example, if you mistakenly type in your partition definition _timestmap_, validation catches the typo because the schema has a _timestamp_ column. Kite also validates that field types can be partitioned on the selected value. For example, you can't extract a year from a string.

You define your partition strategy in [partition strategy JSON format][ps-format] and apply it when you create your dataset. See [Partitioned Datasets][partition-strategies].

For example, you can create a partition strategy using the CLI command [`partition-config`][cli-part-conf] with name:value pairs to specify that the dataset should be partitioned on a timestamp (`ts`) field by year, month, and day.

```
$ kite-dataset partition-config ts:year ts:month ts:day -s rating.avsc
```

The result is a partition definition in JSON format. 

```JSON
[ {
  "name" : "year",
  "source" : "ts",
  "type" : "year"
}, {
  "name" : "month",
  "source" : "ts",
  "type" : "month"
}, {
  "name" : "day",
  "source" : "ts",
  "type" : "day"
} ]
```

If you want to save the partition definition for use with the CLI or API, you can use the `-o` option to output the result to a `.json` file.

[partition-strategies]: {{site.baseurl}}/Partitioned-Datasets.html#partition-strategies
[cli-part-conf]: {{site.baseurl}}/cli-reference.html#partition-config
[ps-format]: {{site.baseurl}}/Partition-Strategy-Format.html

## Additional Configuration

While you need only a URI and schema to create a dataset, you can use column mapping and properties for additional control over how Kite reads or writes your data.

### Column Mapping

When you use an HBase scheme, Kite requires a column mapping to configure how your records are stored. You define column mapping in JSON format. Kite stores and retrieves HBase data seamlessly, using the same commands as with other storage schemes.

See [Column Mapping][column-mapping]. See also the [CLI mapping-config command][cli-column-mapping].

[column-mapping]: {{site.baseurl}}/Column-Mapping.html
[cli-column-mapping]: {{site.baseurl}}/cli-reference.html#mapping-config

### Properties

You can set properties at creation time for additional control over how Kite reads or writes your data.

For example, Kite's default cache size is 10. This is the number of files that are open at any one time; each file represents a partition in the dataset written to by your application. In the CLI, you can use the `--set` option to increase the cache size to 20.

```
kite-dataset create users --schema user.avsc --set kite.writer.cache-size=20
```

You can also create custom properties for your own applications. See [Using Kite Properties][use-prop].

[use-prop]:{{site.baseurl}}/using-kite-properties.html

## Next Steps

The example [Using the Kite Command Line Interface to Create a Dataset][use-cli] demonstrates many of the features described above, and shows you how to create your own Hadoop dataset using only three commands.

[use-cli]:{{site.baseurl}}/Using-the-Kite-CLI-to-Create-a-Dataset.html

---

#### Notes:
1. The MovieLens data set was created by the GroupLens Research Group at the University of Minnesota and is available at [http://grouplens.org/datasets/movielens/](http://grouplens.org/datasets/movielens/).