---
layout: page
title: Kite View API
---

The Kite View API lets you work with some or all records in a dataset. Kite handles the underlying details of selecting the correct records based on user-friendly commands. If your dataset is partitioned, Kite searches only in the partitions you specify when creating your view.

Kite filters records so that you can express assumptions about your data and have Kite enforce them. For example, `events.with("type")` means that _type_ is not null in records returned to the view of the _events_ dataset.

It might seem as though a view is a subset of a dataset, but it is more accurate to think of a dataset as a view with no filters applied.

A `RefinableView` lets you set filters on your view to select and work with only the specific records you need.

## Loading a View

Loading a view is analogous to loading a full dataset. You provide a URI to the dataset, but replace the `dataset:` prefix with the `view:` prefix. The following code snippet creates a refinable view for a dataset of movie ratings submitted by critic (user_id) number 125. 

```Java
RefinableView<GenericRecord> ratings = Datasets.load("view:hive:ratings?user_id=125");
```

The `ratings` object just created refers to the entire dataset at this stage. Since it is a `RefinableView`, you can narrow down the selection of records.

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

You can also create views that take advantage of dataset partitioning. For example, you can create variables for the _start_ and _end_ values for a range of times during which ratings are submitted. By chaining the methods, you can set a range of times from which to select records from your dataset.

```Java
ratings.from("time", start).to("time", end);
```

In a partitioned dataset, Kite intelligently determines which partitions to draw from in response to this filter value. See [Partitioned Datasets](Partitioned-Datasets/).

## Validating a View

In some use cases, it might not be necessary to return a set of values, but only verify that values do or do not exist. You might also want to programmatically avoid processing steps if there are no values that meet your criteria. Two methods from the `View` interface allow you to check for values in your dataset at runtime.

### includes

The `includes` method returns whether an entity would be included in this `View` if it were present in the `Dataset`.

### isEmpty

The `isEmpty` method returns whether your `View` contains any records at all.

## Working with Records in a View

You can interact with records in a view the way you would work with records in a dataset. The only restriction is that you can't make a change that could potentially corrupt the underlying dataset.

### newReader

The `newReader` method creates an appropriate `DatasetReader` implementation based on this view of the underlying dataset. Kite returns only records that match the current constraints in this view.

### newWriter

The `newWriter` method creates an appropriate `DatasetWriter` implementation based on this view of the underlying `Dataset` implementation. Records you write to the view are appended to the underlying dataset. Kite rejects any records that do not match the current constraints on the view. See [Restricted Views](Restricted-Views.md/).

### deleteAll()

Deletes all entities included in this `View`. If the request cannot be completed, the method throws an `UnsupportedOperationException`. In the FileSystem implementation, for example, individual records cannot be deleted, only entire files. That means that Kite only allows you to delete an entire partition directory.

There is an important difference between deleting records working with a view versus deleting records while working with a dataset. When you delete records in a view, only the data is removed, even if you haven't set any filters. When you delete a dataset, both the data and the metadata are destroyed.