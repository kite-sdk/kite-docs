---
layout: page
title: kite-data-core
---

The kite-data-core module provides primary support for the most common tasks required to create and maintain CDH datasets.

The `Datasets` class provides methods to create, update, and delete datasets.

Equally important is the `DatasetDescriptor` class, which stores the structural definition of a dataset, including its schema and partition strategy. `DatasetDescriptor.Builder` is a fluent builder you can use when defining new datasets.

## Example: Hello World!

This example creates infers the schema of `Hello.class` and creates a new dataset using the `DatasetDescriptor.Builder()` method.

`Hello.class` defines one field called _name_. The `sayHello` method sends a friendly greeting to standard out.

### Hello.class

```Java
package org.kitesdk.examples.data;

public class Hello {
  private String name;

  public Hello(String name) {
    this.name = name;
  }
	
  public Hello() {
    // Empty constructor for serialization purposes
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void sayHello() {
    System.out.println("Hello, " + name + "!");
  }
}
```

Kite can create a dataset based on the _name_ field defined in `Hello.class`. Here is the complete listing for `MakeDataset.class`, followed by a line-by-line description.

### MakeDataset.class

```Java
package org.kitesdk.examples.data;

import org.kitesdk.data.Dataset;
import org.kitesdk.data.DatasetDescriptor;
import org.kitesdk.data.DatasetReader;
import org.kitesdk.data.DatasetWriter;
import org.kitesdk.data.Datasets;

public class MakeDataset {
	
   public MakeDataset() {
   }
	
   public static void makeDataset() {
      String datasetUri = "dataset:file:/tmp/hellos";
      String name "Bob";

      DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
             .schema(Hello.class).build();
      Dataset<Hello> hellos = Datasets.create(datasetUri, descriptor, Hello.class);

      DatasetWriter<Hello> writer = null;
      try {
         writer = hellos.newWriter();     
         MyHello2 hello = new Hello(name);
         writer.write(hello);
      } finally {
         if (writer != null) {
         writer.close();
      }
    
    DatasetReader<Hello> reader = null;
    try {
      reader = hellos.newReader();

      for (Hello hello : reader) {
        hello.sayHello();
      }

    } finally {
      if (reader != null) {
        reader.close();
      }
    }
    
    // Delete the dataset now that we are done with it
    Datasets.delete(datasetUri);
  }
}
```

### MakeDataset.class with Commentary

```Java
package org.kitesdk.examples.data;

import org.kitesdk.data.Dataset;           // Defines a dataset instance
import org.kitesdk.data.DatasetDescriptor; // Stores metadata
import org.kitesdk.data.DatasetReader;     // Reads records from dataset
import org.kitesdk.data.DatasetWriter;     // Writes records to dataset
import org.kitesdk.data.Datasets;          // Provides common management methods

public class MakeDataset {

   public MakeDataset() {
   }
	
   public static void makeDataset() { 
      String datasetUri = "dataset:file:/tmp/hellos";
      String name "Bob";

   // Create a dataset of Hellos. 


   // `DatasetDescriptor.Builder().schema()` scans `Hello.class` and extracts
   // the name and type of each defined field.
      DatasetDescriptor descriptor = new DatasetDescriptor.Builder()
             .schema(Hello.class).build();

      Dataset<Hello> hellos = Datasets.create(datasetUri, descriptor, Hello.class);

   // Write some Hellos to the dataset

   // Create a DatasetWriter instance
      DatasetWriter<Hello> writer = null;

      try {

      // Create an instance of a Hello DatasetWriter
         writer = hellos.newWriter();     

      // Create a Hello object instance
         Hello hello = new Hello(name);

      // Write the Hello object to the dataset
         writer.write(hello);

      } finally {
         if (writer != null) writer.close();
      }
    
   // Read the Hellos from the dataset

   // Create an instance of a Hello DatasetReader
      DatasetReader<Hello> reader = null;

      try {

      // Read the Hello objects from the dataset
         reader = hellos.newReader();

      // Iterate through the Hello objects with the sayHello method.
         for (Hello hello : reader) {
            hello.sayHello();
         }

      } finally {
         if (reader != null) {
         reader.close();
      }
   }
    
// Delete the dataset now that we are done with it
   Datasets.delete(datasetUri);
   }
}
```


```Java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder().schema(Hello.class).build();
```

You create the dataset using a URI that points to the local filesystem to store the data and metadata. You use the descriptor you just created and the original class to create the dataset.

```Java

Dataset<Hello.class> hellos = Datasets.create(datasetUri, descriptor, Hello.class);
```

 To create a `Dataset`, you need to:

1. Create a `DatasetDescriptor` (metadata that describes the dataset).
1. Create the dataset by passing a location URI and the dataset descriptor.

For step 1, use the `DatasetDescriptor.Builder` class to make a `DatasetDescriptor` that holds the description of this data set. The only required property is the schema. You can set the schema using a Builder that automatically inspects the `Hello` class:


```java
DatasetDescriptor descriptor = new DatasetDescriptor.Builder().schema(Hello.class).build();
```

For step 2, we use the `create` factory method in `Datasets` with a dataset URI
that points to the local filesystem to store the data (and metadata). The URI
here, "dataset:file:/tmp/hellos", tells Kite to store data in `/tmp/hellos`.

```java
Dataset hellos = Datasets.create("dataset:file:/tmp/hellos", descriptor);
```

Create returns a working `Dataset` instance. You load the `Dataset` later using the `Datasets.load` method and the dataset's URI. The descriptor's configuration is stored with the dataset, so there is no need to pass it the next time.

After creating the dataset, the example creates a `Hello` object and writes it
out. 




Then, it reads it back in, calls `sayHello`, and finally, deletes the data
set. After you read through the rest of [`HelloKite code`][hello-java], you can
build the code from the `dataset/` folder with this command:

```
mvn compile
```
and then run the example with:

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.HelloKite"
```

[hello-java]: src/main/java/org/kitesdk/examples/data/HelloKite.java

## Example: Products Dataset

This example shows basic usage of the Kite Data API for performing streaming writes
to (and reads from) a dataset. Like the "Hello Kite" example above, the
products are plain (old) java object, POJOs.

Create the dataset with:

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.CreateProductDatasetPojo"
```

You can look at the files that were created in
[`/tmp/data/products`](http://localhost:8888/filebrowser/#/tmp/data/products).

Once we have created a dataset and written some data to it, the next thing to do is to
read it back. We can do this with the `ReadProductDatasetPojo` program.

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.ReadProductDatasetPojo"
```

Finally, delete the dataset:

```
mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.DeleteProductDataset"
```
 