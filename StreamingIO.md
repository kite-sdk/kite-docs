---
layout: page
title: Streaming Input and Output
---

This example how you can use the Kite Data API for performing streaming writes to (and reads from) a dataset.

## Product.class

`Product.class` defines a record as a [POJO](http://en.wikipedia.org/wiki/Plain_Old_Java_Object) with two fields that represent a product: _name_ and _id_. The `MoreObjects.toStringHelper()` method is a fluid builder that makes it easier to construct and return a string containing all of the fields and their values.

```Java

package org.kitesdk.examples.data;

import com.google.common.base.MoreObjects; // Provides toStringHelper method

/**
 * A POJO representing a product.
 */

public class Product {
  private String name;
  private long id;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  @Override
  public String toString() {
    return MoreObjects.toStringHelper(this)
        .add("name", name)
        .add("id", id)
        .toString();
  }
}
```

## CreateProductDatasetPojo.java

Having defined the product object, you can create a dataset in which to store product records. Infer the schema for the products dataset from the Product POJO.

```Java


package org.kitesdk.examples.data;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import org.kitesdk.data.Dataset;
import org.kitesdk.data.DatasetDescriptor;
import org.kitesdk.data.DatasetWriter;
import org.kitesdk.data.Datasets;

/**
 * Create a dataset on the local filesystem and write some {@link Product} objects to it.
 */

public class CreateProductDatasetPojo () {
	
   public CreateProductDatasetPojo() {
   }
   
  private static final String[] names = { "toaster", "teapot", "butter dish" };

  @Override
  public int run(String[] args) throws Exception {

    // Create a dataset descriptor based on a schema inferred from Product.class.
    DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
        .schema(Product.class)
        .build();

    // Create an HDFS dataset using the descriptor and Product.class.
    Dataset<Product> products = Datasets.create(
        "dataset:hdfs:/tmp/data/products", descriptor, Product.class);

    // Create a dataset writer instance.
    DatasetWriter<Product> writer = null;

 
    try {
      writer = products.newWriter(); // Associate the writer with the dataset.

      // Create a simple integer to use as the product ID.
      int i = 0;

      // Iterate through the product names, creating and writing a record for each.
      for (String name : names) {
        Product product = new Product();
        product.setName(name);
        product.setId(i++);
        writer.write(product);
      }
    } finally {

      // Ensure that the writer is closed when the method is finished.
      if (writer != null) {
        writer.close();
      }
    }

    return 0;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new CreateProductDatasetPojo(), args);
    System.exit(rc);
  }
}
```

You can use Maven to run CreateProductDatasetPojo from a terminal command line.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.CreateProductDatasetPojo"
```

You can look at the files the application created in
[`/tmp/data/products`](http://localhost:8888/filebrowser/#/tmp/data/products).

## ReadProductDatasetPojo

Once you have created a dataset and written some data to it, you can read it back from the dataset using `ReadProductDatasetPojo`.

```Java

package org.kitesdk.examples.data;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Dataset;
import org.kitesdk.data.DatasetReader;
import org.kitesdk.data.Datasets;

/**
 * Read all the {@link Product} objects from the products dataset.
 */
public class ReadProductDatasetPojo extends Configured implements Tool {

  @Override
  public int run(String[] args) throws Exception {
    // Load the products dataset
    Dataset<Product> products = Datasets.load(
        "dataset:hdfs:/tmp/data/products", Product.class);

    // Get a reader for the dataset and read all the users
    DatasetReader<Product> reader = null;
    try {
      reader = products.newReader();
      for (Product product : reader) {
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
    int rc = ToolRunner.run(new ReadProductDatasetPojo(), args);
    System.exit(rc);
  }
}

```
You can run `ReadProductDatasetPojo` from the command line using Maven.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.ReadProductDatasetPojo"
```

The program writes information to the console similar to the following.

```
2014-12-02 11:26:49 DEBUG :: Opening reader on path:hdfs://quickstart.cloudera/tmp/data/products/4a5b52ec-a355-4453-bb96-17705e045e84.avro
Product{name=toaster, id=0}
Product{name=teapot, id=1}
Product{name=butter dish, id=2}
2014-12-02 11:26:49 DEBUG :: Closing reader on path:hdfs://quickstart.cloudera/tmp/data/products/4a5b52ec-a355-4453-bb96-17705e045e84.avro
```

## DeleteProductDataset

When you are finished with the example, or if you want to run it again, you can run `DeleteProductDataset`.

```Java

package org.kitesdk.examples.data;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.kitesdk.data.Datasets;

/**
 * Delete the products dataset.
 */
public class DeleteProductDataset extends Configured implements Tool {

  @Override
  public int run(String[] args) throws Exception {

    // Delete the products dataset, based on its URI.

    boolean success = Datasets.delete("dataset:hdfs:/tmp/data/products");

    return success ? 0 : 1;
  }

  public static void main(String... args) throws Exception {
    int rc = ToolRunner.run(new DeleteProductDataset(), args);
    System.exit(rc);
  }
}
```

Invoke the program from the command line using Maven.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.DeleteProductDataset"
```
 