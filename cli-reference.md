---
layout: page
title: Kite CLI Reference
---

The Kite Dataset command line interface (CLI) provides utility commands that let you perform essential tasks such as creating a schema and dataset, importing data from a CSV file, and viewing the results.

Each command is described below. See [Using the Kite CLI to Create a Dataset][cli-csv-tutorial] for a practical example of the CLI in use.


[cli-csv-tutorial]: {{site.baseurl}}/Using-the-Kite-CLI-to-Create-a-Dataset.html



<a name="top" /> 

## Commands

----
* [general options](#general-options): options for all commands.
* [help](#help): get help for the dataset command in general or a specific command.
* [create](#create): create a dataset based on an existing schema.
* [update](#update): update the metadata descriptor for a dataset.
* [compact](#compact): compact all or part of a dataset.
* [list](#list): list datasets.
* [show](#show): show the first _n_ records of a dataset.
* [copy](#copy): copy one dataset to another dataset.
* [transform](#transform): transform records from one dataset and store them in another dataset.
* [delete](#delete): delete a dataset.
* [info](#info): show metadata for a dataset.
* [schema](#schema) : view the schema for an existing dataset.
* [csv-schema](#csv-schema): create a schema from a CSV data sample.
* [json-schema](#json-schema): create a schema from a JSON data sample.
* [obj-schema](#obj-schema): create a schema from a Java object.
* [csv-import](#csv-import): import CSV data.
* [json-import](#json-import): import JSON data.
* [inputformat-import](#inputformat-import): import data using a custom InputFormat.
* [tar-import](#tar-import): import files from a tarball as a dataset.
* [partition-config](#partition-config): create a partition strategy for a schema.
* [mapping-config](#mapping-config): create a mapping strategy for a schema.
* [log4j-config](#log4j-config): Configure Log4j.
* [flume-config](#flume-config): Configure Flume.


----

## General options

Every command begins with `{{site.dataset-command}}`, followed by general options. Currently, the only general option turns on debugging, which will show a stack trace if something goes awry during execution of the command. A concise set of additional options might be added as the product matures.

| `-v`<br />`--verbose`<br />`--debug` | Turn on debug logging and show stack traces. |

The Kite CLI supports the following environment variables.

| `HIVE_HOME` | Root directory of Hive instance |
| `HIVE_CONF_DIR` | Configuration directory for Hive instance |
| `HBASE_HOME` | Root directory of HBase instance |
| `HADOOP_MAPRED_HOME` | Root directory for MapReduce |
| `HADOOP_HOME` | Root directory for Hadoop instance |

To show the values for these variables at runtime, set the  `debug=` option to _true_. This can be helpful when troubleshooting issues where one or more of these resources is not found.  For example:

```
debug=true {{site.dataset-command}} info users
```

Use the `flags=` option to pass arguments to the internal Hadoop jar command. For example:

```
flags="-Xmx512m" {{site.dataset-command}} info users`
```

----

[Back to the Top](#top)

----

## help

Retrieves details on the functions of one or more dataset commands.

### Syntax

```
{{site.dataset-command}}  [-v] help <commands> [command options]
```

### Examples

Retrieve details for the create command:

```
{{site.dataset-command}} help create
```

----

[Back to the Top](#top)

----

## create

Create a dataset in a new location or using existing data.

The dataset must be either a full dataset URI beginning with "dataset:" or a dataset name that will be created as a Hive table using the default "dataset:hive:<name>" URI.

Any dataset configuration set in the command's options will be validated against existing data.

If there is no existing data, a schema is required. If existing data is found, the inferred schema, partition strategy, and format will be used unless it is changed by command options.

### Usage

```
{{site.dataset-command}} [-v] create <dataset> [command options]
```

### Options

| `-s, --schema`       | A file containing the Avro schema. |
| `-f, --format`       | Set the dataset format, either `avro` or `parquet`. Defaults to `avro` |
| `-p, --partition-by` | A file containing a JSON-formatted partition strategy. |
| `-m, --mapping`      | A file containing a JSON-formatted column mapping. |
| `--set, --property`  | A property to set in the dataset's descriptor: `prop.name=value`. |
| `--location`         | The location where data is or should be stored. |

### Examples:

Create a new dataset in Hive called "users":

```
{{site.dataset-command}} create users --schema user.avsc
```

Create dataset "users" using Parquet format:

```
{{site.dataset-command}} create users --schema user.avsc --format parquet
```

Create a Hive dataset for existing data in HDFS using the inferred schema and partition strategy:

```
{{site.dataset-command}} create events --location /path/to/events
```

Create dataset "events" with the given partition strategy and set the writer cache size:

```
{{site.dataset-command}} create events --partition-by config.json --set kite.writer.cache-size=20
```

Create dataset "users" and set multiple properties:

```
{{site.dataset-command}} create users --schema user.avsc --set kite.writer.cache-size=20 --set dfs.blocksize=256m
```

----

[Back to the Top](#top)

----

## update

Update the metadata for a dataset.

This command can update a dataset's schema or partition strategy, and add or change dataset properties.

Schema updates are validated according to Avro's Schema evolution rules to ensure that the updated schema can read data written with any previous version of the schema.

Partition strategy updates only allow replacing provided partitioners with another partitioner that is compatible with the existing partition data. For example, a provided partitioner called "year" with integer values can be replaced with a year partitioner called "year" that uses a valid timestamp field as its source.

### Syntax

```
{{site.dataset-command}} [-v] update <dataset> [command options]
```

### Options

| `-s, --schema`       | A file containing the updated Avro schema. |
| `-p, --partition-by` | A file containing an updated partition strategy. |
| `--set, --property`  | Add a property pair: `prop.name=value`. |

### Examples:

Update schema for dataset "users" in Hive:

```
{{site.dataset-command}} update users --schema user.avsc
```

Update HDFS dataset by URI, add property:

```
{{site.dataset-command}} update dataset:hdfs:/user/me/datasets/users --set kite.write.cache-size=20
```

----

[Back to the Top](#top)

----

## compact

Compact all or part of a dataset.

Compaction will rewrite partitions in the dataset, combining all files in each partition into a single large file using the dataset's current descriptor properties, like `dfs.blocksize` or `parquet.block.size`.

Partitions that have been rewritten will replace existing partitions by moving the rewritten content to a hidden location (a dot folder), deleting the existing partition, and renaming the hidden folder to replace it. This results in a small window of time when data for the partition is not visible.

This compaction does not coordinate with other readers or writers. No other processes should be reading from or writing to the dataset while this command is running.

If multiple directories make up a single logical partition, all of the directories will be replaced with a single rewritten directory with all of the data. This can happen when reading data with older naming schemes. For example, `month=5` and `month=05` are two directory names that would be considered the same logical partition.

### Syntax

```
{{site.dataset-command}} [-v] comapct <dataset or view> [command options]
```

### Options

| `--num-writers` | The number of writer processes to use. |

### Examples:

Compact all partitions of the `events` dataset:

```
{{site.dataset-command}} compact events
```

Compact all partitions under `year=2015` in `events`:

```
{{site.dataset-command}} compact view:hive:events?year=2015
```

----

[Back to the Top](#top)

----

## list

Lists available dataset URIs.

An optional repository URI can be given to list datasets in repositories other than Hive.

Repository URIs start with "repo:" and leave out table and namespace options that are in dataset or view URIs.

### Syntax

```
{{site.dataset-command}} [-v] list [repository] [command options]
```

### Examples

Show all supported Hive datasets:

```
{{site.dataset-command}} list
```

Show all datasets in HDFS under `/data`:

```
{{site.dataset-command}} list repo:hdfs:/data
```

----

[Back to the Top](#top)

----

## show

Print the first *n* records in a dataset.

### Syntax

```
{{site.dataset-command}} [-v] show <dataset> [command options]
```

### Options

| `-n, --num-records` | The number of records to print. The default number is 10. |

### Examples

Show the first 10 records in dataset "users":

```
{{site.dataset-command}} show users
```

Show the first 50 records in dataset "users":

```
{{site.dataset-command}} show users -n 50
```

----

[Back to the Top](#top)

----

## copy

Copy records from one dataset to another.

### Syntax

```
{{site.dataset-command}} [-v] copy <source dataset> <destination dataset> [command options]
```

### Options

| `--no-compaction` | Copy to output directly, without compacting the data. |
| `--num-writers` | The number of writer processes to use. |

### Examples

Copy the contents of `movies_avro` to `movies_parquet`:

```
{{site.dataset-command}} copy movies_avro movies_parquet
```
 
Copy the movies dataset into HBase in a map-only job:
 
```
{{site.dataset-command}} copy movies dataset:hbase:zk-host/movies --no-compaction
```

----

[Back to the Top](#top)

----

## transform
Transforms records from one dataset and stores them in another dataset.

### Syntax

```
{{site.dataset-command}} transform <source dataset> <destination dataset> [command options]
```

### Options

| `--no-compaction` | Copy to output without compacting the data |
| `--num-writers` | The number of writer processes to use |
| `--transform` | A transform DoFn class name |
| `--jar` | Add a jar to the runtime class path |

### Examples

Transform the contents of `movies_src` using `com.example.TransformFn`:

```
{{site.dataset-command}}  transform movies_src movies --transform com.example.TransformFn --jar fns.jar
```

---

[Back to the Top](#top)

----

## delete

Delete one or more datasets or views.

If deleting a dataset, all data and metadata is deleted. If deleting a view, only data is deleted.

Both datasets and views are identified by URI, but arguments that do not start with "dataset:" or "view:" are assumed to be a Hive table name.

### Syntax

```
{{site.dataset-command}} [-v] delete <datasets> [command options]
```

### Examples

Delete all data and metadata for the dataset "users":

```
{{site.dataset-command}} delete users
```

Delete just data from the Hive dataset "users":

```
{{site.dataset-command}} delete view:hive:users
```

----

[Back to the Top](#top)

----

## info

Print all metadata for a dataset.

### Syntax

```
{{site.dataset-command}} info <dataset name>
```

### Example

Print all metadata for the "users" dataset:


```
{{site.dataset-command}} info users
```

---

[Back to the Top](#top)

----

## schema

Show the schema for a dataset.

### Syntax

```
{{site.dataset-command}} [-v] schema <dataset> [command options]
```

### Options

| `-o, --output` | Save schema in Avro format to a given path. |
| `--minimize` | Minimize schema file size by eliminating white space. |

### Examples:

Print the schema for dataset "users" to standard out:

```
{{site.dataset-command}} schema users
```

Save the schema for dataset "users" to user.avsc:

```
dataset schema users -o user.avsc
```

----

[Back to the Top](#top)

----

## csv-schema

Use `csv-schema` to generate an Avro schema from a comma separated value (CSV) file.

The schema produced by this command is a record based on the first few lines of the file. If the first line is a header, it is used to name the fields.

Field schemas are set by inspecting the first non-empty value in each field. Fields are nullable unless the field's name is passed using `--require`. Nullable fields default to `null`.

The type is determined by the following rules:
* If the data is numeric and has a decimal point, the type is `double`
* If the data is numeric and has no decimal point, the type is `long`
* Otherwise, the type is `string`

See [CSV format details][csv-format].

[csv-format]: {{site.baseurl}}/read-only-formats.html#csv

### Syntax

```
{{site.dataset-command}} [-v] csv-schema <sample csv path> [command options]
```

### Options

| `--class,`<br />`--record-name` | A class name or record name for the schema result. This value is **required**. |
| `-o, --output`           | Save schema avsc to path. |
| `--require`              | Mark a field required; the schema for this field will not allow null values.<br />Use more than once to require multiple fields. |
| `--no-header`            | Use this option when the CSV data file does not have header information in the first line.<br />Fields are given the default names *field_0*, *field_1,...field_n*. |
| `--skip-lines`           | The number of lines to skip before the start of the CSV data. Default is 0. |
| `--delimiter`            | Delimiter character in the CSV data file. Default is the comma (,). |
| `--escape`               | Escape character in the CSV data file. Default is the backslash (\\). |
| `--quote`                | Quote character in the CSV data file. Default is the double-quote ("). |
| `--minimize`             | Minimize schema file size by eliminating white space. |

### Examples

Print the schema to standard out:

```
{{site.dataset-command}} csv-schema sample.csv --class Sample
```

Write the schema to sample.avsc:

```
{{site.dataset-command}} csv-schema sample.csv --class Sample -o sample.avsc
```

----

[Back to the Top](#top)

----

## json-schema

Build a schema from a JSON data sample.

This command produces a Schema by inspecting the first few JSON objects in the data sample. Each JSON object is converted to a Schema that describes it, and the final Schema is the result of merging each sample object's Schema.

The following two-object data sample, for example

```JSON
{ "id": 1, "color": "green", "shade": "dark" }
{ "id": 2, "color": "red" }
```

Produces the following merged Schema

```JSON
{
  "type" : "record",
  "name" : "Sample",
  "fields" : [ {
    "name" : "id",
    "type" : "int"
  }, {
    "name" : "color",
    "type" : "string"
  }, {
    "name" : "shade",
    "type" : [ "null", "string" ],
    "default" : null
  } ]
}
```

See [JSON format details][json-format].

[json-format]: {{site.baseurl}}/read-only-formats.html#json

### Syntax

```
{{site.dataset-command}} [-v] json-schema <sample json path> [command options]
```

### Options

| `--class,`<br />`--record-name` | A class name or record name for the schema result. This value is **required**. |
| `-o, --output`           | Save schema avsc to path. |
| `--minimize`             | Minimize schema file size by eliminating white space. |

### Examples

Print an inferred schema for `samples.json` to standard out

```
{{site.dataset-command}} json-schema samples.json --record-name Sample
```

Write an inferred schema to `sample.avsc`

```
{{site.dataset-command}} json-schema samples.json --record-name Sample -o sample.avsc
```

----

[Back to the Top](#top)

----

## obj-schema

Build a schema from a Java class.

Fields are assumed to be nullable if they are Objects, or required if they are primitives. You can edit the generated schema directly to remove the `null` option for specific fields.

### Syntax

```
{{site.dataset-command}} [-v] obj-schema <class name> [command options]
```

### Options

| `-o, --output` | Save schema in Avro format to a given path. |
| `--jar`        | Add a jar to the classpath used when loading the Java class. |
| `--lib-dir`    | Add a directory to the classpath used when loading the Java class. |
| `--minimize`   | Minimize schema file size by eliminating white space. |

### Examples

Create a schema for an example User class:

```
{{site.dataset-command}} obj-schema org.kitesdk.cli.example.User
```

Create a schema for a class in a jar:

```
{{site.dataset-command}} obj-schema com.example.MyRecord --jar my-application.jar
```

Save the schema for the example User class to user.avsc:

```
{{site.dataset-command}} obj-schema org.kitesdk.cli.example.User -o user.avsc
```

----

[Back to the Top](#top)

----

## csv-import

Copy CSV records into a dataset.

Kite matches the CSV header to the target record schema's fields by name. If a header is not present (that is, you use the `--no-header` option), then CSV columns are matched with the target fields based on their position.

As Kite constructs each record, it validates values using the target field's schema. Invalid values (in numeric fields) and null values (in required fields) cause exceptions. Kite handles empty strings as null values for numeric fields.

See [CSV format details][csv-format].

### Syntax

```
{{site.dataset-command}} [-v] csv-import <csv path> <dataset> [command options]
```

### Options

| `--no-header`     | Use this option when the CSV data file does not have header information in the first line.<br />Fields are given the default names *field_0*, *field_1,...field_n*. |
| `--skip-lines`    | Lines to skip before CSV start (default: 0) |
| `--delimiter`     | Delimiter character. Default is comma (,). |
| `--escape`        | Escape character. Default is backslash (\\). |
| `--quote`         | Quote character. Default is double quote ("). |
| `--num-writers`   | The number of writer processes to use |
| `--no-compaction` | Copy to output directly, without compacting the data |
| `--jar`           | Add a jar to the runtime classpath |
| `--transform`     | A transform DoFn class name |

### Examples

Copy the records from `sample.csv` to a Hive dataset named "sample":

```
{{site.dataset-command}} csv-import path/to/sample.csv sample
```

----

[Back to the Top](#top)

----

## json-import

Copy JSON objects into a dataset

Kite uses the target dataset's Schema to validate and store the JSON objects.

* All values must match the type specified in the target Schema
* JSON objects will match both record and map Schemas
* When converting a JSON object with a record Schema:
  * Only the record's fields are used, other key-value pairs are ignored
  * All fields must be present or have a default value in the record Schema
* When converting a JSON object with a map Schema, all key-value pairs are used

Invalid values, missing record fields, and other problems cause exceptions.

See [JSON format details][json-format].

### Syntax

```
{{site.dataset-command}} [-v] json-import <json path> <dataset name> [command options]
```

### Options

| `--num-writers`   | The number of writer processes to use |
| `--no-compaction` | Copy to output directly, without compacting the data |
| `--jar`           | Add a jar to the runtime classpath |
| `--transform`     | A transform DoFn class name |

### Examples

Copy the records from `sample.json` to dataset `sample`

```
{{site.dataset-command}} json-import path/to/sample.json sample
```

Copy the records from `sample.json` to a dataset URI

```
{{site.dataset-command}} json-import path/to/sample.json dataset:hdfs:/user/me/datasets/sample
```

Copy the records from an HDFS directory to `sample`

```
{{site.dataset-command}} json-import hdfs:/data/path/samples/ sample
```

----

[Back to the Top](#top)

----

## inputformat-import

Copy records read by an InputFormat into a dataset.

This will use a custom input format by name and copy the keys or values (set by `--record-type`) into a dataset.

Use the [`obj-schema` command](#obj-schema) to infer a schema for the key or value class used by the InputFormat.

### Syntax

```
{{site.dataset-command}} [-v] inputformat-import <data path> <dataset> [command options]
```

### Options

| `--format`          | The InputFormat class name. Must include the package. |
| `--jar`             | Add a jar to the runtime classpath |
| `--record-type`     | InputFormat argument to use as the record (`key` or `value`) |
| `--num-writers`     | The number of writer processes to use |
| `--no-compaction`   | Copy to output directly, without compacting the data |
| `--transform`       | A transform DoFn class name |
| `--set, --property` | A property to set on the configuration: `prop.name=value`. |

### Examples

Import the keys from a sequence file of `MyObject` defined in myobject.jar:

```
{{site.dataset-command}} inputformat-import data.seq mytable --jar myobject.jar --record-type key \
                           --format org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
```

----

[Back to the Top](#top)

----

## tar-import

Create a dataset from a tarball or load a tarball into an existing dataset.

The datasets that this command will create or write to use a static schema, TarFileEntry, that has 2 fields: filename and filecontent.

Tarballs imported using this command are converted to Avro or Parquet files of TarFileEntries and are compressed using Snappy compression.

### Syntax

```
{{site.dataset-command}} [-v] tar-import <tarball> <dataset> [command options]
```

### Options

| `--compression` | The compression algorithm used to compress the incoming tarball. |

### Examples

Convert a tarball of files to an Avro dataset:

```
{{site.dataset-command}} tar-import data.tar.gz dataset:hdfs:/user/me/tar_data
```

----

[Back to the Top](#top)

----

## partition-config

Builds a partition strategy for a schema.

The resulting partition strategy is a valid [JSON partition strategy file][strategy-format].

Entries in the partition strategy are specified by `field:type` pairs, where `field` is the source field from the given schema and `type` can be:

| `year`     | Extract the year from a timestamp |
| `month`    | Extract the month from a timestamp |
| `day`      | Extract the day from a timestamp |
| `hour`     | Extract the hour from a timestamp |
| `minute`   | Extract the minute from a timestamp |
| `hash[N]`  | Hash the source field, using _N_ buckets |
| `copy`     | Copy the field without modification (identity) |
| `provided` | Doesn't use a source field, the field name is used to name the partition |

Provided partitioners do not reference a source field and instead require that a value is provided when writing. Values can be provided by writing to [views][views].

[strategy-format]: {{site.baseurl}}/Partition-Strategy-Format.html
[views]: {{site.baseurl}}/view-api.html

### Syntax

```
{{site.dataset-command}} [-v] partition-config <field:type pairs> [command options]
```

### Options:

| `-s, --schema` | The file containing the Avro schema. **This value is required** |
| `-o, --output` | Save partition JSON file to path |
| `--minimize`   | Minimize output size by eliminating white space |

### Examples

Partition by email address, balanced across 16 hash partitions and save to a file.

```
{{site.dataset-command}} partition-config email:hash[16] email:copy -s user.avsc -o part.json
```

Partition by `created_at` time's year, month, and day:

```
{{site.dataset-command}} partition-config created_at:year created_at:month created_at:day -s event.avsc
```

----

[Back to the Top](#top)

----

## mapping-config

Builds a column mapping for a schema, required for HBase. The resulting mapping definition is a valid [JSON mapping file][mapping-format].

Mappings are specified by `field:type` pairs, where `field` is a source field from the given schema and `type` can be:

| `key`      | Uses a key mapping |
| `version`  | Uses a version mapping (for optimistic concurrency) |
| any string | The given string is used as the family in a column mapping |

If the last option is used, the mapping type will determined by the source field type. Numbers will use `counter`, hash maps and records will use `keyAsColumn`, and all others will use `column`.

[mapping-format]: {{site.baseurl}}/Column-Mapping.html

### Syntax

```
{{site.dataset-command}}  [-v] create-column-mapping <field:type pairs> [command options]
```

### Options

| `-s, --schema` | The file containing the Avro schema. |
| `-p, --partition-by` | The file containing the JSON partition strategy. |
| `--minimize` | Minimize output size by eliminating white space. |

### Examples

Store email in the key, other fields in column family `u`:

```
{{site.dataset-command}}  mapping-config email:key username:u id:u --schema user.avsc -o user-cols.json
```

Store preferences hash-map in column family `prefs`:

```
{{site.dataset-command}}  mapping-config preferences:prefs --schema user.avsc
```

Use the `version` field as an OCC version:

```
{{site.dataset-command}}  mapping-config version:version --schema user.avsc
```

----

[Back to the Top](#top)

----

## log4j-config

Builds a log4j configuration to log events to a dataset.

### Syntax

```
{{site.dataset-command}} log4j-config <dataset name> --host <flume hostname> [command options]
```

### Options

| `--port` | Flume port |
| `--class`, `--package` | Java class or package from which to log |
| `--log-all` | Configure the root logger to send to Flume | 
| `-o, --output` | Save the log4j configuration to a file |

### Examples

Print log4j configuration to log to dataset "users":

```
{{site.dataset-command}} log4j-config --host flume.cluster.com --class org.kitesdk.examples.MyLoggingApp users
```

Save log4j configuration to the file `log4j.properties`:

```
{{site.dataset-command}} log4j-config --host flume.cluster.com --package org.kitesdk.examples -o log4j.properties users
```

Print log4j configuration to log from all classes:

```
{{site.dataset-command}} log4j-config --host flume.cluster.com --log-all users
```

---

[Back to the Top](#top)

----

## flume-config

Builds a Flume configuration to log events to a dataset.

### Syntax

```
{{site.dataset-command}} flume-config <dataset name or URI> [command options]
```

### Options

| `--use-dataset-uri` | Configure Flume with a dataset URI. Requires Flume 1.6 or later. |
| `--agent` | Flume agent name |
| `--source` | Flume source name |
| `--bind` | Avro source bind address |
| `--port` | Avro source port |
| `--channel` | Flume channel name |
| `--channel-type` | Flume channel type (`memory` or `file`)|
| `--channel-capacity` | Flume channel capacity |
| `--channel-transaction-capacity` | Flume channel transaction capacity |
| `--checkpoint-dir` | File channel checkpoint directory (required when using `--channel-type file`)|
| `--data-dir` | File channel data directory. Use the option multiple times for multiple data directories. (required when using `--channel-type file`)|
| `--sink` | Flume sink name |
| `--batch-size` | Records to write per batch |
| `--roll-interval` | Time in seconds before starting the next file |
| `--proxy-user` | User identity to use when writing to HDFS |
| `-o, --output` | Save the Flume configuration to a file |

### Examples

Print Flume configuration to log to dataset "users":

```
{{site.dataset-command}} flume-config --checkpoint-dir /data/0/flume/checkpoint --data-dir /data/1/flume/data users
```

Print Flume configuration to log to dataset `dataset:hdfs:/datasets/default/users`:

```
{{site.dataset-command}} flume-config --channel-type memory dataset:hdfs:/datasets/default/users
```

Save Flume configuration to the file `flume.properties`:

```
{{site.dataset-command}} flume-config --channel-type memory -o flume.properties users
```

---

[Back to the Top](#top)

----
