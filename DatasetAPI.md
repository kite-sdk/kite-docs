---
layout: page
title: Kite Data Module API
---

## The DatasetDescriptor API

```java
getSchema(): org.apache.avro.Schema
getPartitionStrategy(): PartitionStrategy
isPartitioned(): boolean
```

You do not instantiate datasets directly. Instead, you create them using factory methods on a DatasetRepository.

An instance of Dataset acts as a factory for both reader and writer streams. Each implementation is free to produce stream implementations that make sense for the underlying storage system. The Hadoop FileSystem implementation, for example, produces streams that read from, or write to, Avro data files on a FileSystem implementation.

### Dataset stream factory methods

Reader and writer streams both function similarly to Java's standard IO streams, but are specialized. Both interfaces are generic. The type parameter indicates the type of entity that they consume or produce, respectively.

```Java
<E> getReader(): DatasetReader <E>
    open()
    close()
    isOpen(): boolean
    hasNext(): boolean
    next(): E

<E> getWriter(): DatasetWriter <E>
    open()
    close()
    isOpen(): boolean
    write(E)
    flush()
```

## Partitioned Dataset

You can provide a PartitionStrategy when you construct a dataset. A partition strategy is a list of one or more partition functions that, when applied to an attribute of an entity, produce a value used to decide in which partition an entity should be written. Different partition function implementations exist, each of which facilitates a different form of partitioning. The initial version of the library includes the identity, hash, range, and value list functions.

This example produces a dataset that can have up to 53 partitions. User entities written to the dataset are automatically written to the correct partition. Note that the name of the attribute used in the partition strategy builder ("userId") must appear in the schema ("user.avsc").

You can specify multiple partition functions. The order of specification is extremely important, because it reflects the physical storage (in the case of the HDFS implementation).


```Java
/*Assume the content of userSchema is defined as follows:
 * {
 *   "type": "record",
 *   "name": "User",
 *   "fields": [
 *     { "type": "long", "name": "userId" },
 *     { "type": "string", "name": "username" }
 *   ]
 * }
 */

Schema userSchema = ...;

FileSystemDatasetRepository repo = new FileSystemDatasetRepository(
  FileSystem.get(new Configuration()),
  new Path("/data"),
  new FileSystemMetadataProvider(fileSystem, new Path("/data"))
);

DatasetDescriptor desc = new DatasetDescriptor.Builder()
  .schema(userSchema)
  .partitionStrategy(
    /*
     * Partition the users dataset using the hash code of the value of the
     * userId attribute modulo 53.
     */
    new PartitionStrategy.Builder().hash("userId", 53).get()
  ).get();

Dataset users = repo.create("users", desc);
DatasetWriter[Record] writer = users.getWriter();

try {
  writer.open();

  /*
   * This writes to /data/users/data/userId=15/*.avro because
   * (Integer.valueOf(1234).hashCode() & Integer.MAX_VALUE) % 53 = 15
   */
  writer.write(
    new GenericRecordBuilder(userSchema)
      .set("userId", 1234)
      .set("username", "jane")
      .build()
  );
  writer.flush();
} finally {
  writer.close();
}
```
It's worth pointing out that Hive and Impala only support the identity function in partitioned datasets, at least at the time this is written. Users who do not use partitioning for subset selection can use any partition function(s) they choose. If, however, you want to use the partition pruning feature of Hive/Impala's query engine, only the identity function works. This is because both systems rely on the idea that the value in the path name equals the value found in each record. If you look closely at the earlier example, you'll see that while the value of the userId attribute in record is 1234, its value in the path is 15. To mimic more complex partitioning schemes, users often resort to adding a surrogate field to each record to hold the derived value and handle proper setting of such a field themselves.

The equivalent workaround for the hashed field example above is to add a new attribute to the User entity called `userIdHash`, set it to the proper value in user code, and use the identity function on that column instead. Note that this means partition pruning is no longer transparent; the user must know to query the table using code similar to the following snippet.

```... WHERE userIdHash = (hashCode(SOME_VALUE) % 53)```

The hope is that these engines learn about more complex partitioning schemes in the future.

## Dataset Repositories and Metadata Providers

A _dataset repository_ is a physical storage location for zero or more datasets. In keeping with the relational database analogy, a dataset repository is the equivalent of a database. An instance of a `DatasetRepository` acts as a factory for `Datasets`, supplying methods for creating, loading, and dropping datasets.

Each dataset belongs to exactly one dataset repository. There's no built in
support for moving or copying datasets between repositories. MapReduce and other execution engines provide copy functionality when needed.

## DatasetRepository APIs

### DatasetRepository

```Java
    load(String): Dataset
    create(String, DatasetDescriptor): Dataset
    update(String, DatasetDescriptor): Dataset
    delete(String): boolean
```

Along with the Hadoop FileSystem Dataset and stream implementations, there is a related `DatasetRepository` implementation. This implementation requires an instance of a Hadoop FileSystem, a root directory under which datasets are stored, and a metadata provider supplied upon instantiation. Once complete, users can freely interact with datasets under the supplied root directory. The supplied MetadataProvider is used to resolve dataset schemas,
partitioning information, and any other like data.

## MetadataProvider API

Along with the dataset repository, the metadata provider is a service provider interface used to interact with the service that provides dataset metadata information. The MetadataProvider interface defines the contract metadata services must provide to the library and, specifically, the DatasetRepository.

### MetadataProvider

```Java
    load(String): DatasetDescriptor
    create(String, DatasetDescriptor): DatasetDescriptor
    update(String, DatasetDescriptor): DatasetDescriptor
    delete(String): boolean
```

The expectation is that `MetadataProvider` implementations act as a bridge between this library and centralized metadata repositories. An obvious example of this (in the Hadoop ecosystem) is HCatalog and the Hive metastore. By providing an implementation that makes the necessary API calls to HCatalog's REST service, any and all datasets are immediately consumable by systems compatible with HCatalog, the storage system represented by the `DatasetRepository` implementation, and the format in which the data is written.


As it turns out, that's a pretty tall order and, in keeping with the Kite's purpose of simplifying rather than presenting additional options, you are encouraged to

<ol>
<li> Use HCatalog</li>
<li>Allow this library to default to snappy compressed Avro data files</li>
<li>Use systems that also integrate with HCatalog</li>
</ol>

In this way, this library acts as a fourth integration point to working with data in HDFS that is HCatalog-aware, in addition to Hive, Pig, and MapReduce input/output formats.

[verify it does not exist and/or remove this paragraph]

At this time, an HCatalog implementation of the MetadataProvider interface does not exist. It is, however, straightforward to implement and on the roadmap.

## Examples

### Writing to a new dataset

```Java
FileSystem fileSystem = FileSystem.get(new Configuration());
Schema eventSchema = new Schema.Parser.parse(
  Resources.getResource("event.avsc").openStream()
);

DatasetRepository repo = new FileSystemDatasetRepository(
  fileSystem,
  new Path("/data"),
  new FileSystemMetadataProvider(fileSystem, new Path("/data"))
);
DatasetDescriptor eventDescriptor = new DatasetDescriptor.Builder()
  .schema(eventSchema)
  .get();
Dataset events = repo.create("events", eventDescriptor);
DatasetWriter<Event> writer = events.getWriter();

try {
  writer.open();

  while (...) {
    /*
     * Event is an Avro specific (generated) type, a generic type, or a
     * POJO, in which case we use reflection. Here, we use a POJO.
     */
    Event e = ...

    writer.write(e);
  }
} finally {
  if (writer != null) {
    writer.close();
  }
}
```

## Reading from an existing dataset

```Java
FileSystem fileSystem = FileSystem.get(new Configuration());

DatasetRepository repo = new FileSystemDatasetRepository(
  fileSystem,
  new Path("/data")
  new FileSystemMetadataProvider(fileSystem, new Path("/data"))
);
Dataset events = repo.get("events");
DatasetReader<GenericData.Record> reader = events.getReader();

try {
  reader.open();

  // We can also use Avro Generic records.
  for (GenericData.Record record : reader) {
    System.out.println(new StringBuilder("event - timestamp:")
      .append(record.get("timestamp"))
      .append(" eventId:", record.get("eventId"))
      .append(" message:", record.get("message"))
      .toString()
    );
  }
} finally {
  reader.close();
}
```

