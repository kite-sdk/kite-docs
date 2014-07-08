---
layout: page
---
## Kite Dataset Command Line Interface


The Kite Dataset command line interface (CLI) provides utility commands that let you perform essential tasks such as creating a schema and dataset, importing data from a CSV file, and viewing the results.

Each command is described below. See [Using the Kite CLI to Create a Dataset](../Using-the-Kite-CLI-to-Create-a-Dataset/) for a practical example of the CLI in use.



<a name="top" /> 

----
* [general options](#general): options for all commands.
* [csv-schema](#csvSchema): create a schema from a CSV data file.
* [obj-schema](#objSchema): create a schema from a Java object.
* [create](#create): create a dataset based on an existing schema.
* [update](#update): update the metadata descriptor for a dataset. 
* [schema](#schema) : view the schema for an existing dataset.
* [csv-import](#csvImport): import a CSV data file.
* [show](#show): show the first _n_ records of a dataset.
* [copy](#copy): copy one dataset to another dataset.
* [delete](#delete): delete a dataset.
* [partition-config](#partition-config): create a partition strategy for a schema.
* [mapping-config](#mapping-config): create a partition strategy for a schema.
* [help](#help): get help for the dataset command in general or a specific command.

----
<a name="general" />

## general options

Every command begins with `dataset`, followed by `[general options]`. Currently, the only general options are `-v`, `--verbose`, and `--debug`, all three of which show a stack trace if something goes awry during execution of the command. A concise set of additional options might be added as the product matures.

----
[Back to the Top](#top)

----
<a name="csvSchema" />

## csv-schema
Use `csv-schema` to generate an Avro schema from a comma separated value (CSV) file.

### Syntax

`dataset [general options] csv-schema <sample csv path> [command options]`

### Options
`--skip-lines`

The number of lines to skip before the start of the CSV data. Default is 0.

`--quote`

Quote character in the CSV data file. Default is the double-quote (").

`--delimiter`

Delimiter character in the CSV data file. Default is the comma (,).

`--escape`

Escape character in the CSV data file. Default is the backslash (\\).

`--class, --record-name`

A class name or record name for the schema result. This value is **required**.

`-o, --output`

Save schema avsc to path.

`--no-header`

Use this option when the CSV data file does not have header information in the first line. Fields are given the default names *field_0*, *field_1,...field_n*.

`--minimize`

Minimize schema file size by eliminating white space.

### Examples

Print the schema to standard out: `dataset csv-schema sample.csv --class Sample`

Write the schema to sample.avsc: `dataset csv-schema sample.csv --class Sample -o sample.avsc`

----

[Back to the Top](#top)

----

<a name="objSchema" />

## obj-schema
Build a schema from a Java class.

### Syntax

`dataset [general options] obj-schema <class name> [command options]`

### Options

`-o, --output`

Save schema in Avro format to a given path.

`--jar`

Add a jar to the classpath used when loading the Java class.

`--lib-dir`

Add a directory to the classpath used when loading the Java class.

`--minimize`

Minimize schema file size by eliminating white space.

### Examples

Create a schema for an example User class:
`dataset obj-schema org.kitesdk.cli.example.User`

Create a schema for a class in a jar:
`dataset obj-schema com.example.MyRecord --jar my-application.jar`

Save the schema for the example User class to user.avsc:
`dataset obj-schema org.kitesdk.cli.example.User -o user.avsc`

----

[Back to the Top](#top)

----

## create
After you have generated an Avro schema, you can use `create` to make an empty dataset.

### Usage

`dataset [general options] create <dataset name> [command options]`

### Options

`-d, --directory`

The root directory of the dataset repository. Optional if using Hive for metadata storage.

`--use-hive`

The dataset is stored in the filesystem by default. Set this switch to false to store the dataset in the file system.

`-s, --schema`

The file containing the Avro schema. This value is **required**.

`-f, --format`

By default, the dataset is created in Avro format. Use this switch to set the format to Parquet (`-f parquet`).

`-p, --partition-by`

The file containing a JSON-formatted partition strategy.


### Examples:

Create dataset "users" in Hive:

`dataset create users --schema user.avsc`

Create dataset "users" using Parquet:

`dataset create users --schema user.avsc --format parquet`

Create dataset "users" partitioned by JSON configuration:

`dataset create users --schema user.avsc --partition-by user_part.json`


----

[Back to the Top](#top)

----

<a name="update" />

## update

Update the metadata descriptor for a dataset.

### Syntax

`dataset [general options] update-dataset <dataset name> [command options]`

### Options

`-s, --schema`
The file containing the Avro schema.

`--set, --property`

Add a property pair: `prop.name=value`.


### Examples:

Update schema for dataset "users" in Hive:": `dataset update users --schema user.avsc`

Update HDFS dataset by URI, add property: `dataset update dataset:hdfs:/user/me/datasets/users --set kite.write.cache-size=20`

----

[Back to the Top](#top)

----

<a name="schema" />

## schema

Show the schema for a dataset.

### Syntax

`dataset [general options] schema <dataset name> [command options]`

### Options

`-d, --directory`

The root directory of the dataset repository. Optional if you are using Hive for metadata storage.

`--use-hive`

By default, dataset metadata is stored in the file system. Use this switch to store dataset metadata in Hive.

`--minimize`

Minimize schema file size by eliminating white space.

`-o, --output`

Save schema in Avro format to a given path.

### Examples:

Print the schema for dataset "users" to standard out: `dataset schema users`

Save the schema for dataset "users" to user.avsc: `dataset schema users -o user.avsc`

----

[Back to the Top](#top)

----

<a name="csvImport" />

## csv-import

Copy CSV records into a dataset.

### Syntax
`dataset [general options] csv-import <csv path> <dataset name> [command options]`

### Options

`-d, --directory`

The root directory of the dataset repository. Optional if using Hive for metadata storage.

`--use-hive`

By default, dataset metadata is stored in Hive. Use this switch to store the dataset metadata in the file system.

`--escape`

Escape character. Default is backslash (\\).

`--delimiter`

Delimiter character. Default is comma (,).

`--quote`

Quote character. Default is double quote (").

`--skip-lines`


Lines to skip before CSV start (default: 0)

`--no-header`

Use this option when the CSV data file does not have header information in the first line. Fields are given the default names *field_0*, *field_1,...field_n*.

### Examples

Copy the records from `sample.csv` to a dataset named "sample": `dataset csv-import csv-import path/to/sample.csv sample`

----

[Back to the Top](#top)

----

<a name="show" />

## show

Print the first *n* records in a dataset.

### Syntax
`dataset [general options] show <dataset name> [command options]`

### Options

`-d, --directory`

The root directory of the dataset repository. Optional if using Hive for metadata storage.

`--use-hive`

By default, dataset metadata is stored in Hive. Set this switch to false to use the file system (`--use-hive false`).

`-n, --num-records`

The number of records to print. The default number is 10.

### Examples

Show the first 10 records in dataset "users": `dataset show users`

Show the first 50 records in dataset "users": `dataset show users -n 50`

----

[Back to the Top](#top)

----

<a name="copy" />

## copy

Copy records from one dataset to another.

### Syntax
`dataset [general options] copy <source dataset> <destination dataset> [command options]`

### Options

`--no-compaction`

Copy to output directly, without compacting the data.

`--num-writers`

The number of writer processes to use.



### Examples

Copy the contents of movies_avro to movies_parquet:

 `dataset copy movies_avro movies_parquet`
 
Copy the movies dataset into HBase in a map-only job:
 
`dataset copy movies dataset:hbase:zk-host/movies --no-compaction`

----

[Back to the Top](#top)

----


<a name="delete" />

## delete

Delete one or more datasets and related metadata.

### Syntax

`dataset [general options] delete <dataset names> [command options]`

### Options

`-d, --directory`

The root directory of the dataset repository. Optional if using Hive for metadata storage.

`--use-hive`

By default, metadata is stored in Hive. Set this value to false to store the metadata in the file system (`--use-hive false`).

### Examples

Delete all data and metadata for the dataset "users": `dataset delete users`

----

[Back to the Top](#top)

----

<a name="partitionConfig" />

## partition-config

Builds a partition strategy for a schema.

### Syntax

`dataset [general options] partition-config <field:type pairs> [command options]`

### Options:

`-s, --schema`
The file containing the Avro schema. **This value is required**.

`-o, --output`
Save partition JSON file to path

`--minimize`
Minimize output size by eliminating white space

### Examples

Partition by email address, balanced across 16 hash partitions and save as a JSON file.

`dataset partition-config email:hash[16] email:copy -s user.avsc -o part.json`

Partition by created_at time's year, month, and day:

`dataset partition-config created_at:year created_at:month created_at:day -s event.avsc`

----

[Back to the Top](#top)

----

<a name="mapping-config" />

## mapping-config

Builds a partition strategy for a schema, based on a key value, version, or column. The mapping definition is a JSON object with required "type" and "source" attributes.

Types:

`column`: requires _family_ and _qualifier_, regular storage.

`counter`: requires _family_ and _qualifier_, incrementable storage, must be int or long.

`keyAsColumn`: requires _family_, optional _prefix_, must be record or map type. Maps each value to a separate qualifier in the same family.

`key`: gets value from storage in the key. Primitive types only.

`occVersion`: occ version, must be an int or long. Conflicts with counter types.

### Syntax
`dataset [general options] create-column-mapping <field:type pairs> [command options]`

### Options

`-s, --schema`

The file containing the Avro schema.

`-p, --partition-by`

The file containing the JSON partition strategy.

`--minimize`

Minimize output size by eliminating white space.

### Examples

Store email in the key, other fields in column family _u_:

`dataset mapping-config email:key username:u id:u --schema user.avsc -o user-cols.json`

Store preferences hash-map in column family _prefs_:

`dataset mapping-config preferences:prefs --schema user.avsc`

Use the _version_ field as an OCC version:

`dataset mapping-config version:version --schema user.avsc`

----

[Back to the Top](#top)

----

<a name="help" />

## Help

Retrieves details on the functions of one or more dataset commands.

### Syntax

`dataset [general options] help <commands> [command options]`

### Examples

Retrieve details for the create, show, and delete commands. `dataset help create show delete`

----

[Back to the Top](#top)

----
