---
layout: page
title: Kite View API
---

The Kite View API lets you work with some or all records in a dataset. Kite allows you to use an API that reads more like plain English to express expectations (constraints) about which records to return, then loads the correct records for you.

If your dataset is partitioned, Kite automatically determines the partitions to use based on the constraints for the view. You don't have to specify the partitions yourself. For example, your dataset is partitioned by time, Kite knows how to filter out the partitions that cannot match the constraints you set in your view.

Kite filters records so that you can express requirements for your data and have Kite enforce them. For example, `events.with("type")` means that _type_ is not null in records returned to the view of the _events_ dataset.

It might seem as though a view is a subset of a dataset, but it is more accurate to think of a dataset as a view with no filters applied.

## Loading a View

Loading a view is analogous to loading a full dataset. You provide a URI to the dataset, but replace the `dataset:` prefix with the `view:` prefix. See [Dataset and View URIs]({{site.baseurl}}/URIs.html).

The following code snippet creates a refinable view for a dataset of movie ratings submitted by critic (user_id) number 125. 

```Java
RefinableView<GenericRecord> ratings = Datasets.load("view:hive:ratings").with("user_id",125);
```

The `ratings` object just created is a `RefinableView`. You can narrow down the selection of records by creating new views with additional constraints.

## Refining a View

The `RefinableView` interface has methods you can use to work with a subset of records.

| Method | Definition |
| `with` | Restricted to entities in the field you choose with values equal to the given value. |
| `from` | Restricted to entities in the field you choose with values greater than or equal to the given value. |
| `fromAfter` | Restricted to entities in the field you choose with values greater than the given value. |
| `to` | Restricted to entities in the field you choose with values less than or equal to the given value. |
| `toBefore` | Restricted to entities in the field you choose with values less than the given value. |

For example, If you want to work with movies with the rating of _5_, you can use the `with` method.

```Java
ratings.with("rating", 5);
```

Kite inspects each record and applies this constraint before passing entities to your application. Only ratings with the value _5_ are returned. The object you pass as a constraint must match the data type. For example, if the _rating_ field is a String data type, sending the value _5_ as a constraint causes an error.

`RefinableView` instances are immutable. When you add a constraint to an existing view, Kite returns a new view that reflects all of the constraints. Adding a constraint does not affect the original view object. This way, you can pass the view to other operations or applications, safe in the knowledge that it won't be updated in unexpected ways.

You can also create views that take advantage of dataset partitioning. For example, you can create variables for the _start_ and _end_ values for a range of times during which ratings are submitted. By chaining the methods, you can set a range of times from which to select records from your dataset.

```Java
ratings.from("time", start).to("time", end);
```

In a partitioned dataset, Kite intelligently determines which partitions to draw from in response to this filter value. See [Partitioned Datasets]({{site.baseurl}}/Partitioned-Datasets.html).

## Validating a View

In some use cases, it might not be necessary to return a set of values, but only verify that values do or do not exist. You might also want to programmatically avoid processing steps if there are no values that meet your criteria. Two methods from the `View` interface allow you to check for values in your dataset at runtime.

### includes

The `includes` method returns whether an entity would be included in this `View` if it were present in the `Dataset`.

### isEmpty

The `isEmpty` method returns whether your `View` contains any records at all.

## Working with Records in a View

You can interact with records in a view the way you would work with records in a full dataset. You can use `newReader` and `newWriter` to get the same reader or writer objects, but they are restricted to operations on the view. 

### newReader

The `newReader` method creates an appropriate `DatasetReader` based on this view of the underlying dataset. Kite returns only records that match the constraints in this view.

### newWriter

The `newWriter` method creates an appropriate `DatasetWriter` based on this view of the underlying `Dataset` implementation. Records you write to the view are appended to the underlying dataset. Kite throws an error if the writer attempts to create a record that doesn't match the current constraints on the view.

For example, you might have two writers working in parallel on the same dataset partitioned by time. You can set a constraint on writer1 so that it only writes to a view (and its partition) for the month of June, and a constraint on writer2 so that it only writes to a view for the month of July. This avoids a situation where the two writers might write to the same partition, leading to performance problems and suboptimal use of resources.

See [Restricted Views]({{site.baseurl}}/Restricted-Views.html).

### deleteAll()

Deletes all entities included in this `View`. If the request cannot be completed, the method throws an `UnsupportedOperationException`. In the FileSystem implementation, for example, individual records cannot be deleted, only entire files. That means that Kite only allows you to delete an entire partition directory.

There is an important difference between deleting records working with a view versus deleting records while working with a dataset. When you delete records in a view, only the data is removed, even if you haven't set any filters. When you delete a dataset, both the data and the metadata are destroyed.