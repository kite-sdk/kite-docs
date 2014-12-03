---
layout: page
title: Generic Record Datasets
---

[POJO](http://en.wikipedia.org/wiki/Plain_Old_Java_Object)s are familiar data transfer objects for most Java programmers. Avro also supports generic records. Generic records are more efficient, since they don't require reflection. When you use generic records, neither the reader nor the writer require a POJO class to work with your data.

## CreateProductDatasetGeneric

This program creates the same product dataset used in the Streaming I/O example, but uses generic records.

```Java
package org.kitesdk.examples.data.generic;

// Avro's generic record builder
import org.apache.avro.generic.GenericRecordBuilder;

// ToolRunner and its required classes.
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;


import org.kitesdk.data.Dataset;           // Defines a dataset instance.
import org.kitesdk.data.DatasetDescriptor; // Stores dataset configuration information.
import org.kitesdk.data.DatasetWriter;     // Writes records to a dataset.
import org.kitesdk.data.Datasets;          // Supports common tasks for working
                                           //   with datasets.

import static org.apache.avro.generic.GenericData.Record; // Avro's generic record object

/**
 * Create a dataset on the local filesystem and write some user objects to it,
 * using Avro generic records.
 */
public class CreateProductDatasetGeneric extends Configured implements Tool {
	
// Items to add to the products dataset.
  private static final String[] items = { "toaster", "teapot", "butter dish" };

// URI for the dataset in HDFS. 
  private static final String datasetURI = "dataset:hdfs:/tmp/data/products";

// Maven looks for resources by default in the main/resources directory.
// The product.avsc file defines the schema for a product record.
 private static final String schemaURI = "resource:product.avsc";

// Label for the product name field.
  private static final String name = "name";

// Label for the product ID field.
  private static final String id = "id";
  
  @Override
  public int run(String[] args) throws Exception {
	  
// Create a dataset descriptor using the Avro schema.
    DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
        .schemaUri(schemaURI)
        .build();
        
// Use the dataset URI, the descriptor, and the generic Record class
//     to create a Products dataset.

    Dataset<Record> products = Datasets.create(
        datasetURI, descriptor, Record.class);

// Get a writer for the dataset. 
    DatasetWriter<Record> writer = null;
    
// Write some products to the dataset.
    try {
      
    // Create an instance of the record builder based on the schema.
      GenericRecordBuilder builder = new GenericRecordBuilder(descriptor.getSchema());
      
    // Assign the generic writer to the products dataset.      
      writer = products.newWriter();
      
    // Create a dumb integer to increment as an example ID number.
      int i = 0;
      
    // Iterate through the items, creating a record for each.
     for (String item : items) {
        Record product = builder
            .set("name", item)
            .set("id", i++)
            .build();
        writer.write(product);
      }
    } finally {

    // Ensure that you close the writer when the job is complete.
      if (writer != null) {
        writer.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new CreateProductDatasetGeneric(), args);
    System.exit(rc);
  }
}

```
You can run this program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.CreateProductDatasetGeneric"
```

## ReadProductDatasetGeneric

This program reads records from the products data as generic record objects.

```Java
package org.kitesdk.examples.data.generic;

// Avro's generic record object
import org.apache.avro.generic.GenericRecord;

// ToolRunner and its required classes
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;


import org.kitesdk.data.Dataset;       // Defines a dataset instance.
import org.kitesdk.data.DatasetReader; // Reads records from a dataset.
import org.kitesdk.data.Datasets;      // Supports common tasks for working
                                       //   with datasets.

import static org.apache.avro.generic.GenericData.Record; // Avro's generic record object

/**
 * Read all the product objects from the products dataset using Avro generic records.
 */
public class ReadProductDatasetGeneric extends Configured implements Tool {

  private static final String datasetURI = "dataset:hdfs:/tmp/data/products";
  @Override
  public int run(String[] args) throws Exception {
	  
  // Load the products dataset as Avro generic records.
    Dataset<Record> products = Datasets.load(datasetURI, Record.class);

  // Get a reader for the dataset and read all the product records.
    DatasetReader<Record> reader = null;
    try {
	
    // Assign the reader to the products dataset.
      reader = products.newReader();
      
    // Iterate through the product records and print one at a time.
      for (GenericRecord product : reader) {
        System.out.println(product);
      }

    } finally {
		
    // Ensure that the reader is closed when the program is finished.		
      if (reader != null) {
        reader.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new ReadProductDatasetGeneric(), args);
    System.exit(rc);
  }
}
```

Run the program using Maven on the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.ReadProductDatasetGeneric"
```

Not surprisingly, the results are very much the same as those returned by the StreamingIO example.

```
2014-12-03 13:27:58 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/8a3fa27c-a78e-491e-883c-830e0b6938bf.avro
{"name": "toaster", "id": 0}
{"name": "teapot", "id": 1}
{"name": "butter dish", "id": 2}
2014-12-03 13:27:58 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/8a3fa27c-a78e-491e-883c-830e0b6938bf.avro
```

## DeleteProductDatasetGeneric

Use the Datasets.delete method to delete a dataset based on its URI.

```Java
package org.kitesdk.examples.data.generic;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Datasets;

/**
 * Delete the products dataset.
 */
public class DeleteProductDatasetGeneric extends Configured implements Tool {
	
  private static final String datasetURI = "dataset:hdfs:/tmp/data/products";
  
  @Override
  public int run(String[] args) throws Exception {
	  
    // Delete the products dataset, based on the URI.
    boolean success = Datasets.delete(datasetURI);
    return success ? 0 : 1;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new DeleteProductDatasetGeneric(), args);
    System.exit(rc);
  }
}
```
Run the program using Maven from the command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.generic.DeleteProductDatasetGeneric"
```