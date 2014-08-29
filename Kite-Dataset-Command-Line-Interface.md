---
layout: page
title: Kite Dataset Command Line Interface
---

The Kite Dataset command line interface (CLI) provides utility commands that let you perform essential tasks such as creating a schema and dataset, importing data from a CSV file, and viewing the results.

Each command is described below. See [Using the Kite CLI to Create a Dataset](../Using-the-Kite-CLI-to-Create-a-Dataset/) for a practical example of the CLI in use.



<a name="top" /> 

## Commands

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
* [mapping-config](#mapping-config): create a mapping strategy for a schema.
* [help](#help): get help for the dataset command in general or a specific command.

----
<a name="general" />

## General options

Every command begins with `dataset`, followed by general options. Currently, the only general option turns on debugging, which will show a stack trace if something goes awry during execution of the command. A concise set of additional options might be added as the product matures.

| `-v`<br />`--verbose`<br />`--debug` | Turn on debug logging and show stack traces. |

----
[Back to the Top](#top)

----
<a name="csvSchema" />

## csv-schema

Use `csv-schema` to generate an Avro schema from a comma separated value (CSV) file.

### Syntax

```
{{site.dataset-command}} [-v] csv-schema <sample csv path> [command options]
```

### Options

| `--skip-lines`           | The number of lines to skip before the start of the CSV data. Default is 0. |
| `--quote`                | Quote character in the CSV data file. Default is the double-quote ("). |
| `--delimiter`            | Delimiter character in the CSV data file. Default is the comma (,). |
| `--escape`               | Escape character in the CSV data file. Default is the backslash (\\). |
| `--class,`<br />`--record-name` | A class name or record name for the schema result. This value is **required**. |
| `-o, --output`           | Save schema avsc to path. |
| `--no-header`            | Use this option when the CSV data file does not have header information in the first line.<br />Fields are given the default names *field_0*, *field_1,...field_n*. |
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

<a name="objSchema" />

## obj-schema
Build a schema from a Java class.

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

## create

After you have generated an Avro schema, you can use `create` to make an empty dataset.

### Usage

```
{{site.dataset-command}} [-v] create <dataset> [command options]
```

### Options

| `-s, --schema`       | A file containing the Avro schema. This value is **required**. |
| `-f, --format`       | By default, the dataset is created in Avro format.<br />Use this switch to set the format to Parquet `-f parquet` |
| `-p, --partition-by` | A file containing a JSON-formatted partition strategy. |
| `-m, --mapping`      | A file containing a JSON-formatted column mapping. |
| `--set, --property`  | A property to set in the dataset's descriptor: `prop.name=value`. |

### Examples:

Create dataset "users" in Hive:

```
{{site.dataset-command}} create users --schema user.avsc
```

Create dataset "users" using Parquet:

```
{{site.dataset-command}} create users --schema user.avsc --format parquet
```

Create dataset "users" partitioned by JSON configuration:

```
{{site.dataset-command}} create users --schema user.avsc --partition-by user_part.json
```

Create dataset "users" and set some properties:

```
{{site.dataset-command}} create users --schema user.avsc --set kite.writer.cache-size=20 --set dfs.blocksize=256m
```

----

[Back to the Top](#top)

----

<a name="update" />

## update

Update the metadata descriptor for a dataset.

### Syntax

```
{{site.dataset-command}} [-v] update-dataset <dataset> [command options]
```

### Options

| `-s, --schema` | The file containing the Avro schema. |
| `--set, --property` | Add a property pair: `prop.name=value`. |


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

<a name="schema" />

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

<a name="csvImport" />

## csv-import

Copy CSV records into a dataset.

### Syntax

```
{{site.dataset-command}} [-v] csv-import <csv path> <dataset> [command options]
```

### Options

| `--escape` | Escape character. Default is backslash (\\). |
| `--delimiter` | Delimiter character. Default is comma (,). |
| `--quote` | Quote character. Default is double quote ("). |
| `--skip-lines` | Lines to skip before CSV start (default: 0) |
| `--no-header` | Use this option when the CSV data file does not have header information in the first line.<br />Fields are given the default names *field_0*, *field_1,...field_n*. |

### Examples

Copy the records from `sample.csv` to a Hive dataset named "sample":

```
{{site.dataset-command}} csv-import path/to/sample.csv sample
```

----

[Back to the Top](#top)

----

<a name="show" />

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

<a name="copy" />

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


<a name="delete" />

## delete

Delete one or more datasets and related metadata.

### Syntax

```
{{site.dataset-command}} [-v] delete <datasets> [command options]
```

### Examples

Delete all data and metadata for the dataset "users":

```
{{site.dataset-command}} delete users
```

----

[Back to the Top](#top)

----

<a name="partitionConfig" />

## partition-config

Builds a partition strategy for a schema.

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

<a name="mapping-config" />

## mapping-config

Builds a column mapping for a schema, required for HBase. The resulting mapping definition is a valid [JSON mapping file][mapping-format].

Mappings are specified by `field:type` pairs, where `field` is a source field from the given schema and `type` can be:

| `key`      | Uses a key mapping |
| `version`  | Uses a version mapping (for optimistic concurrency) |
| any string | The given string is used as the family in a column mapping |

If the last option is used, the mapping type will determined by the source field type. Numbers will use `counter`, hash maps and records will use `keyAsColumn`, and all others will use `column`.

[mapping-format]: ../Column-Mapping

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

<a name="help" />

## Help

Retrieves details on the functions of one or more dataset commands.

### Syntax

```
{{site.dataset-command}}  [-v] help <commands> [command options]
```

### Examples

Retrieve details for the create, show, and delete commands.

```
{{site.dataset-command}} help create show delete

```

----

[Back to the Top](#top)

----


