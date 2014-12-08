---
layout: page
title: Partitioned Datasets
---

The Kite API supports partitioning. Records are written to specific partition files based on the values of specified fields. Partitioned datasets are more performant than unstructured datasets in most cases, because the system can target files stored in a partition rather than searching across an entire dataset.

## CreateProductDatasetPartitioned

This example creates a dataset that stores products for the popular store "Table, Truck, and Tent" partitioned by department.

```Java
package org.kitesdk.examples.data.generic;

import org.apache.avro.generic.GenericRecordBuilder;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Dataset;
import org.kitesdk.data.DatasetDescriptor;
import org.kitesdk.data.DatasetWriter;
import org.kitesdk.data.Datasets;
import org.kitesdk.data.PartitionStrategy;

import static org.apache.avro.generic.GenericData.Record;

/**
 * Create a dataset in HDFS and write some product objects to it,
 * using Avro generic records.
 */
public class CreateProductDatasetGenericPartitioned extends Configured implements Tool {
  private static final String truck = "truck";
  private static final String table = "table";
  private static final String tent = "tent";
  private static final String[] items = {
    "dinette", table,
    "gear shift", truck,
    "stakes", tent,
    "toaster", table,
    "teapot", table,
    "butter dish", table,
    "mud flaps", truck,
    "8-person dome tent", tent,
    "2-person ridge tent", tent
  };

  @Override
  public int run(String[] args) throws Exception {
    // Create a partition strategy that hash partitions on department
    PartitionStrategy partitionStrategy = new PartitionStrategy.Builder()
        .identity("department", "department")
        .build();

    // Create a dataset of products with the Avro schema
    DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
        .schemaUri("resource:partitionedProduct.avsc")
        .partitionStrategy(partitionStrategy)
        .build();
    Dataset<Record> products = Datasets.create(
        "dataset:hdfs:/tmp/data/products", descriptor, Record.class);

    // Get a writer for the dataset and write some products to it
    DatasetWriter<Record> writer = null;
    try {
      writer = products.newWriter();
      int id = 0;
      int iterator = 0;
      GenericRecordBuilder builder = new GenericRecordBuilder(descriptor.getSchema());
      for (int i=0; i<(items.length/2); i++) {
        Record item = builder
            .set("name", items[iterator++])
            .set("department", items[iterator++])
            .set("id", id++)
            .build();
        writer.write(item);
      }
    } finally {
      if (writer != null) {
        writer.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new CreateProductDatasetGenericPartitioned(), args);
    System.exit(rc);
  }
}
```

You can run the program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.CreateProductDatasetGenericPartitioned"
```

You can see how partitioning affects the data layout by looking at the subdirectories in [`/tmp/data/products`](http://localhost:8888/filebrowser/#/tmp/data/products).

## Reading the Dataset

Configuring a partition strategy helps Kite efficiently scan datasets. Try running [`ReadProductDatasetGeneric`](../generic#ReadProductDatasetGeneric) again, where this time the dataset is partitioned. The output includes the file reader's debug messages, which logs when files are opened and closed. The users are grouped by color and to read the dataset, Kite reads through each file.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.ReadProductDatasetGeneric"
 . . .
2014-12-04 12:05:30 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=table/8b83085d-9b9a-42a1-9439-ca8261cea4e4.avro
{"name": "dinette", "id": 0, "department": "table"}
{"name": "toaster", "id": 3, "department": "table"}
{"name": "teapot", "id": 4, "department": "table"}
{"name": "butter dish", "id": 5, "department": "table"}
2014-12-04 12:05:30 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=table/8b83085d-9b9a-42a1-9439-ca8261cea4e4.avro
2014-12-04 12:05:30 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=tent/0c90f1ba-00d2-43f7-b0dc-b8ed00daf57a.avro
{"name": "stakes", "id": 2, "department": "tent"}
{"name": "8-person dome tent", "id": 7, "department": "tent"}
{"name": "2-person ridge tent", "id": 8, "department": "tent"}
2014-12-04 12:05:30 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=tent/0c90f1ba-00d2-43f7-b0dc-b8ed00daf57a.avro
2014-12-04 12:05:30 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=truck/540ea7f8-b48f-455d-b60c-a6e714620d3d.avro
{"name": "gear shift", "id": 1, "department": "truck"}
{"name": "mud flaps", "id": 6, "department": "truck"}
2014-12-04 12:05:30 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=truck/540ea7f8-b48f-455d-b60c-a6e714620d3d.avro

```

`ReadProductDatasetGenericOnePartition` retrieves only products associated with trucks when creating the reader.

```Java
package org.kitesdk.examples.data.generic;

import org.apache.avro.generic.GenericRecord;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Dataset;
import org.kitesdk.data.DatasetReader;
import org.kitesdk.data.Datasets;

import static org.apache.avro.generic.GenericData.Record;

/**
 * Reads products by department from the dataset using Avro generic records.
 */
public class ReadProductDatasetGenericOnePartition extends Configured implements Tool {
  @Override
  public int run(String[] args) throws Exception {
    // Load the products dataset
    Dataset<Record> products = Datasets.load(
        "dataset:hdfs:/tmp/data/products", Record.class);

    // Get a reader for the dataset and read all the users
    DatasetReader<Record> reader = null;
    try {
      reader = products.with("department", "truck").newReader();
      for (GenericRecord product : reader) {
        System.out.println(product);
      }

    } finally {
      if (reader != null) {
        reader.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new ReadProductDatasetGenericOnePartition(), args);
    System.exit(rc);
  }
}
```

Run the program using Maven on the command line. It displays records for only those items in the truck department.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.ReadProductDatasetGenericOnePartition"
. . .
2014-12-04 12:14:48 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=truck/540ea7f8-b48f-455d-b60c-a6e714620d3d.avro
{"name": "gear shift", "id": 1, "department": "truck"}
{"name": "mud flaps", "id": 6, "department": "truck"}
2014-12-04 12:14:48 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/department=truck/540ea7f8-b48f-455d-b60c-a6e714620d3d.avro

```

Notice that Kite doesn't scan through all directories. The only file it opens is in the _truck_ directory. The partition strategy makes this possible. Otherwise, Kite would sort through all of the data to find just the products in the _truck_ department.

When finished, you can delete the partitioned dataset using [`DeleteProductDatasetGeneric`](../generic#DeleteProductDatasetGeneric).

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.DeleteProductDatasetGeneric"
```
