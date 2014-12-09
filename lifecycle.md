---
layout: page
title: Kite Dataset Lifecycle
---

Datasets have a fairly predictable lifecycle: creation, population, validation, modification, and, ultimately, annihilation.

In truth, the lifecycle looks something like this.

<p align="center">

<img src="../img/lifecycleflow.jpg" />
</p>

For the sake of simplicity, let's break it down into six general steps.

* <a href="#generate">Generate</a> a schema for your dataset.
* <a href="#create">Create</a> the dataset.
* <a href="#populate">Populate</a> the dataset.
* <a href="#validate">Validate</a> the dataset.
* <a href="#update">Update</a> the dataset.
* <a href="#annihilate">Annihilate</a> the dataset.

<a name="generate" />

<p align="center">

<img src="../img/simplelifecycleflow1.jpg" usemap="#lifecycle" />
</p>

## Preparation

If you have not done so already, install the [Kite JAR](../Install-Kite/).

<map name="lifecycle">
  <area shape="rect" coords="25,35,150,100" href="#generate" alt="Generate Schema" title="Generate Schema" />
  <area shape="rect" coords="190,35,300,100" href="#create" alt="Create Dataset" title="Create Dataset" />
  <area shape="rect" coords="335,35,460,100" href="#populate" alt="Populate Dataset" title="Populate Dataset" />
  <area shape="rect" coords="500,35,615,100" href="#validate" alt="Validate Dataset" title="Validate Dataset" />
  <area shape="rect" coords="650,35,760,100" href="#update" alt="Update Dataset" title="Update Dataset" />
  <area shape="rect" coords="800,35,925,100" href="#annihilate" alt="Annihilate Dataset" title="Annihilate Dataset" />
</map>

## Generate a Schema for the Dataset

<p align="center">
<img src="../img/generateschema.jpg" usemap="#lifecycle" />
</p>

You define a Kite dataset using an Avro schema. The schema defines the fields for each row in your dataset.

You can create the schema yourself as a plain text file. Avro schema syntax is designed to be concise, rather than easy to read. It can be tricky to create and troubleshoot a schema definition. See <a href="http://avro.apache.org/docs/1.7.6/gettingstartedjava.html#Defining+a+schema">Defining a schema</a> in the Apache Avro documentation for more information on writing your own Avro schema.

In most cases, it's easier to generate a schema definition than to create one by hand. You can generate an Avro schema based on a Java object or a CSV data file.
 
### Inferring a Schema from a Java Class

You can use the CLI Command `object-schema` to infer a dataset schema from the instance variable fields of a Java class. Classes are mapped to Avro records. Avro reflect only supports concrete classes with no-argument constructors. Avro reflect includes all inherited fields that are not static or transient. Fields cannot be null unless annotated by Nullable or a Union containing null.

For example, the following code sample excerpts the pertinent lines from a class that defines a Java object that describes a dataset about movies.

```java
 package org.kitesdk.examples.data;
 /** Movie class */
 class Movie {
   private int id;
   private String title;
   private String releaseDate;
 . . . 
   public Movie() {
     // Empty constructor for serialization purposes
   }

```
Use the CLI command [`obj-schema`](../Kite-Dataset-Command-Line-Interface/index.html#obj-schema) to generate an Avro schema file based on the source Java class.

```
{{site.dataset-command}} obj-schema org.kitesdk.cli.example.Movie -o movie.avsc
```

The CLI uses the names and data types of the instance variables in the Java object to construct an Avro schema definition. For the Movie class, it looks like this.

```json
{
  "type":"record",
  "name":"Movie",
  "namespace":"org.kitesdk.examples.data",
  "fields":[
    {"name":"id","type":"int"},
    {"name":"title","type":"string"},
    {"name":"releaseDate","type":"string"},
  ]
}
```
For more insight into Avro reflection, see the Javadoc entry for [org.apache.avro.reflect](http://www.google.com/url?q=http%3A%2F%2Favro.apache.org%2Fdocs%2F1.7.6%2Fapi%2Fjava%2Forg%2Fapache%2Favro%2Freflect%2Fpackage-summary.html&sa=D&sntz=1&usg=AFQjCNHqyzEwXBbUShm8tSyzQK-BbWtOsA)

### Inferring a Schema from a CSV File

The Kite CLI can generate an Avro schema based on a CSV data file.

The CSV data file for the Movie dataset might start off like this.

```
id, title,releaseDate
1,Sam and the Big Dog,"August 14, 2014"
2,Crocophiles,"November 18, 1995"
. . .
```

Use the CLI command [`csv-schema`](../Kite-Dataset-Command-Line-Interface/index.html#csv-schema) to generate the Avro schema.

```
{{site.dataset-command}} csv-schema movie.csv --class Movie -o movie.avsc
```

The Kite CLI infers field names from the values in the first row and data types from the values in the second row of the CSV file.

```json
{
  "type":"record",
  "name":"Movie",
  "namespace":"org.kitesdk.examples.data",
  "fields":[
    {"name":"id","type":"int"},
    {"name":"title","type":"string"},
    {"name":"releaseDate","type":"string"},
  ]
}
```

<a name="create" />

<p align="center">

<img src="../img/simplelifecycleflow2.jpg" usemap="#lifecycle" />
</p>

## Create Dataset

<p align="center">

<img src="../img/createdataset.jpg" />
</p>

Once you have an Avro schema, you can create your dataset.

```
{{site.dataset-command}} create movie --schema movie.avsc
```

### Partition Strategy

In some cases, you can improve the performance of your dataset by creating logical partitions. For example, the _Movie_ dataset could be partitioned by ID. Searches by ID would only search the containing folder, rather than the entire dataset. If you were searching for movie ID 3215, the search would be limited to the partition with records 3001-4000.

You define a partition strategy in JSON format. The following code sample defines the partition strategy movie.json for the _Movie_ dataset.

```JSON
[ {
  "source" : "id",
  "type" : "int",
  "name" : "id"
}]
```

Include the `partition-by` argument when you execute the `create` command.

```
{{site.dataset-command}} create movie --schema movie.avsc partition-by movie.json
```
See [Partitioned Datasets](../Partitioned-Datasets/) for more detail on partition strategies.

### Column Mapping

Column mapping allows you to configure how your records should be stored in HBase for maximum performance and efficiency. You define the mapping based on the type of data you want to store, and Kite handles the infrastructure required to support your mapping strategy. See [Column Mapping](../Column-Mapping/).

### Parquet

If you typically work with a subset of the fields in your dataset rather than an entire row, you might want to create the dataset in Parquet format, rather than the default Avro format. See [Parquet vs Avro Format](../Parquet-vs-Avro-Format/).

```
{{site.dataset-command}} create movie --schema movie.avsc -f parquet
```


<a name="populate" />

<p align="center">

<img src="../img/simplelifecycleflow3.jpg" usemap="#lifecycle" />
</p>

## Populate Dataset

<p align="center">

<img src="../img/populatedataset.jpg" />
</p>

Once you create the dataset, you can insert data in a number of ways.

### Import CSV

You can use the CLI command `csv-import` to insert records from a CSV file to your dataset.

```
{{site.dataset-command}} csv-import /kite/example/movie.csv movie
```

See [`csv-import`](../Kite-Dataset-Command-Line-Interface/#csv-import) for additional options.

### Copy Dataset

Use the [`copy`](../Kite-Dataset-Command-Line-Interface/#copy) command to transfer the contents of one dataset into another.

```
{{site.dataset-command}} copy movie_parquet movie
```


<a name="validate" />

<p align="center">

<img src="../img/simplelifecycleflow4.jpg" usemap="#lifecycle" />
</p>


## Validate Dataset

Select the first few records of your dataset to ensure that they loaded properly. Use the [`show`](../Kite-Dataset-Command-Line-Interface/index.html#show) command to view the first 10 records in your dataset.

```
{{site.dataset-command}} show movie
```

10 records is the default. You can set the number of records you want returned when you execute the command. For example, this would return the first 50 records.

```
{{site.dataset-command}} show movie -n 50
```

<a name="update" />

<p align="center">

<img src="../img/simplelifecycleflow5.jpg" usemap="#lifecycle" />
</p>


## Update Dataset

<p align="center">

<img src="../img/updatedataset.jpg" />
</p>

### Loading Data

Once you have created your Kite dataset, you can add records as you would with any CDH dataset. If you use [`csv-import`](../Kite-Dataset-Command-Line-Interface/index.html#csv-import) to add more records, they are appended to the dataset.

### Compacting the Dataset

One by-product of the [`copy`](../Kite-Dataset-Command-Line-Interface/index.html#copy) command is that it compacts multiple files in a partition into one file. This can be particularly useful for datasets that use streaming input. You can periodically copy the active dataset to an archive, or copy the dataset, delete the current data, and copy the compacted data back to the active dataset.  

### Updating the Dataset Schema

Over time, your dataset requirements might change. You can add, remove, or change the datatype of columns in your dataset, provided you don't attempt a change that would result in the loss or corruption of data. Kite follows the guidelines in the [Avro schema](http://avro.apache.org/docs/current/spec.html#Schema+Resolution). See [Schema Evolution](../Schema-Evolution/) for more detail and examples.

<a name="annihilate" />

<p align="center">

<img src="../img/simplelifecycleflow6.jpg" usemap="#lifecycle" />
</p>

## Annihilate Dataset

When you first create a dataset, you might want to tweak it before you go live. It can be much cleaner and easier to delete the nascent dataset and start over. It could also be the case that your dataset is no longer needed. Regardless of your motivation, you can permanently remove one or more datasets from CDH using the CLI command `delete`.

For example, to remove the _movies_ dataset, you can use the following command.

```
$ {{site.dataset-command}} delete movies
```




