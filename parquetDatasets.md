---
layout: page
title: Parquet Datasets
---
Parquet is a columnar format for data. Columnar formats provide performance advantages over row-oriented formats such as Avro data files (which is the default in Kite) when the number of columns is large (typically dozens) but the queries that you perform most often only retrieve a small subset of the columns.

You can create a Parquet dataset using the CreateProductDatasetGenericParquet program. This example creates a product dataset for the popular store "Table, Truck, and Tent."

```Java
package org.kitesdk.examples.data.generic;

//
import org.apache.avro.generic.GenericData;

// The Builder for Avro generic records. 
import org.apache.avro.generic.GenericRecordBuilder;

// ToolRunner and its required classes.
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import org.kitesdk.data.Dataset;           // Defines a dataset.
import org.kitesdk.data.DatasetDescriptor; // Stores dataset configuration.
import org.kitesdk.data.DatasetWriter;     // Writes records to a dataset.
import org.kitesdk.data.Datasets;          // Methods for working with datasets.
import org.kitesdk.data.Formats;

// Avro's generic record class.
import static org.apache.avro.generic.GenericData.Record;

/**
 * Create a dataset in HDFS, write some products objects to it
 * using Avro generic records, store in Parquet format.
 */
public class CreateProductDatasetGenericParquet extends Configured implements Tool {

// Department names used to partition items. Variables minimize runtime errors.
  private static final String truck = "truck";
  private static final String table = "table";
  private static final String tent = "tent";

// Items in the dataset, in serial form, object followed by department.
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

  // Create a dataset descriptor, passing an Avro schema and 
  //    setting the format to Parquet.
    DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
        .schemaUri("resource:parquetProduct.avsc")
        .format(Formats.PARQUET)
        .build();
        
  // Create a dataset definition for products using an Avro schema
    Dataset<Record> products = Datasets.create(
        "dataset:hdfs:/tmp/data/products", descriptor, Record.class);

    // Get a writer for the dataset and write some users to it
    DatasetWriter<Record> writer = null;
    try {
    // Assign the writer to the products dataset.
      writer = products.newWriter();

    // Dumb integer used for the faux object ID.
      int id = 0;

    // Counter used to iterate through the serialized input string.
      int iterator = 0;

    // Get an instance of Avro's generic record builder, passing
    //    the dataset record schema.
      GenericRecordBuilder builder = new GenericRecordBuilder(descriptor.getSchema());

    // Iterate through the items, Building each record with the name, department and ID.
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
    // Ensure that the writer is closed when the program is finished.
        writer.close();
    }
}

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new CreateProductDatasetGenericParquet(), args);
    System.exit(rc);
  }
}
```

The advantages of using Parquet are most evident when using Impala to query a dataset that has many columns and rows.

You can read the results of this small product dataset using [`ReadProductDatasetGeneric`](../generic#ReadProductDatasetGeneric). Your results will look to similar to the following.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.ReadProductDatasetGeneric"
. . .

2014-12-05 14:59:24 INFO  :: Got brand-new decompressor [.snappy]
{"name": "dinette", "department": "table", "id": 0}
{"name": "gear shift", "department": "truck", "id": 1}
{"name": "stakes", "department": "tent", "id": 2}
{"name": "toaster", "department": "table", "id": 3}
{"name": "teapot", "department": "table", "id": 4}
{"name": "butter dish", "department": "table", "id": 5}
{"name": "mud flaps", "department": "truck", "id": 6}
{"name": "8-person dome tent", "department": "tent", "id": 7}
{"name": "2-person ridge tent", "department": "tent", "id": 8}
Dec 5, 2014 2:59:21 PM INFO: parquet.hadoop.ParquetFileReader: reading another 1 footers
Dec 5, 2014 2:59:24 PM INFO: parquet.hadoop.InternalParquetRecordReader: RecordReader initialized will read a total of 9 records.
Dec 5, 2014 2:59:24 PM INFO: parquet.hadoop.InternalParquetRecordReader: at row 0. reading next block
Dec 5, 2014 2:59:24 PM INFO: parquet.hadoop.InternalParquetRecordReader: block read in memory in 219 ms. row count = 9

```

When finished, you can delete the Parquet dataset using [`DeleteProductDatasetGeneric`](../generic#DeleteProductDatasetGeneric).

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.DeleteProductDatasetGeneric"
```