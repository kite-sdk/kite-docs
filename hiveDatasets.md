---
layout: page
title: Hive Datasets
---

You can store your Kite dataset metadata in Hive. You can use your Kite-generated Hive dataset with other metastore-enabled applications.

The primary difference between these Hive examples and the Streaming I/O and Generic examples is that the these examples use a Hive URI rather than an HDFS URI.

## CreateHiveProductDatasetGeneric

This example creates the generic `products` dataset used in the Streaming I/O and Generic examples, but stores its metadata in the Hive metastore. When you create a Hive dataset, records are partitioned automatically.

```Java
package org.kitesdk.examples.data.hive;

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

// Avro's generic record class.
import static org.apache.avro.generic.GenericData.Record;

/**
 * Create a dataset using HCatalog for metadata. Write some product 
 * objects using Avro generic records.
 */

public class CreateHiveProductDatasetGeneric extends Configured implements Tool {

// Department names. Using variables to avoid runtime errors.
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

  // Create a dataset definition for products using an Avro schema. 
  // The partitioned product schema works fine.
    DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
        .schemaUri("resource:partitionedProduct.avsc")
        .build();
        
  /*
   * This is the important line in this example. Since you're passing a Hive URI,
   * Kite creates a Hive dataset and puts the schema in the Hive metastore.
   *
   * Create the dataset using a Hive URI, the descriptor, and the Record class.    
   */
      Dataset<Record> products = Datasets.create("dataset:hive?dataset=products",
        descriptor, Record.class);

  // Create an empty writer.
    DatasetWriter<Record> writer = null;

    try {
		
    // Assign the writer to the products dataset.
      writer = products.newWriter();

    // Dumb integer used for the faux object ID
      int id = 0;

    // Counter used to iterate through the serialized input string
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
    int rc = ToolRunner.run(new CreateHiveProductDatasetGeneric(), args);
    System.exit(rc);
  }
}

```

Run the program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.hive.CreateHiveProductDatasetGeneric"
```

Note: This example assumes a local (not embedded) metastore running on the local machine. You can change the default to use a different metastore by editing `src/main/resources/hive-site.xml`.

Now inspect the dataset storage area in [`/user/hive/warehouse/products`](http://localhost:8888/filebrowser/#/user/hive/warehouse/products).

Notice that there is no metadata stored there, since the metadata is stored in Hive's metastore.

You can use SQL to query the data directly using the Hive UI (Beeswax) in Hue. For example:

```SQL
SELECT * FROM products
```

The results of the SQL query should look something like this.

<img src="../img/hiveinhue.png"  width="794" height="360"/>

## ReadHiveProductDatasetGeneric

You can use the Java API to read a Hive dataset.

```Java
package org.kitesdk.examples.data.hive;

//Avro GenericRecord object.
import org.apache.avro.generic.GenericRecord;

// ToolRunner and its required classes.
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import org.kitesdk.data.Dataset;        // Defines a dataset.
import org.kitesdk.data.DatasetReader;  // Reads records from a dataset.
import org.kitesdk.data.Datasets;       // Methods for working with datasets.

// Avro Record object.
import static org.apache.avro.generic.GenericData.Record;

/**
 * Read all the objects from the products Hive dataset as Avro generic records.
 */

public class ReadHiveProductDatasetGeneric extends Configured implements Tool {

  @Override
  public int run(String[] args) throws Exception {

  // Load the products dataset from Hive.
    Dataset<Record> products = Datasets.load(
        "dataset:hive?dataset=products", Record.class);

  // Create an empty DatasetReader object
    DatasetReader<Record> reader = null;

    try {
    // Assign the reader to the products dataset.
      reader = products.newReader();

    // Iterate through the dataset, printing one record to console at a time.
      for (GenericRecord product : products.newReader()) {
        System.out.println(product);
      }

    } finally {

    // Ensure that the reader is closed when the program ends.
      if (reader != null) {
        reader.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new ReadHiveProductDatasetGeneric(), args);
    System.exit(rc);
  }
}

```

Run the program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.hive.ReadHiveProductDatasetGeneric"
```

The results of the query should look something like this.

```
2014-12-05 16:35:34 INFO  :: Trying to connect to metastore with URI thrift://localhost:9083
2014-12-05 16:35:34 INFO  :: Connected to metastore.
2014-12-05 16:35:35 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera:8020/user/hive/warehouse/products/c84b8d5d-e9aa-4a5a-b45f-128104ea8c6f.avro
{"name": "dinette", "id": 0, "department": "table"}
{"name": "gear shift", "id": 1, "department": "truck"}
{"name": "stakes", "id": 2, "department": "tent"}
{"name": "toaster", "id": 3, "department": "table"}
{"name": "teapot", "id": 4, "department": "table"}
{"name": "butter dish", "id": 5, "department": "table"}
{"name": "mud flaps", "id": 6, "department": "truck"}
{"name": "8-person dome tent", "id": 7, "department": "tent"}
{"name": "2-person ridge tent", "id": 8, "department": "tent"}
2014-12-05 16:35:35 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera:8020/user/hive/warehouse/products/c84b8d5d-e9aa-4a5a-b45f-128104ea8c6f.avro
```

## DeleteHiveProductDataset

Deleting the dataset deletes the metadata from the metastore and the data from the filesystem.

```Java
package org.kitesdk.examples.data.hive;

// ToolRunner and its dependencies.
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Datasets;   // Methods for working with datasets.

/**
 * Delete the products dataset and HCatalog metadata.
 */
public class DeleteHiveProductDataset extends Configured implements Tool {

  @Override
  public int run(String[] args) throws Exception {
    // Delete the users dataset
    boolean success = Datasets.delete("dataset:hive?dataset=products");

    return success ? 0 : 1;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new DeleteHiveProductDataset(), args);
    System.exit(rc);
  }
}
```

Run the program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.hive.DeleteHiveProductDataset"
```
