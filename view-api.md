---
layout: page
title: Kite View API
---

Most of the time, you don't need to work with all of the records stored in a dataset. It is common to work with subsets, like events _last month_ rather than _all_ events. The Views API is a way to express constraints for the records that Kite loads.

If your dataset is partitioned, Kite intelligently determines which partitions to draw from based on a view's constraints. You don't have to specify the partitions yourself because Kite will filter out partitions that cannot contain matching records, automatically.

Kite filters records so that you can express requirements for your data and have Kite enforce them. For example, `events.with("type")` is a view of `events` where each record loaded by the view will have a non-null value for the _type_ field.

[partitioned-datasets]: {{site.baseurl}}/Partitioned-Datasets.html "See [Partitioned Datasets][partitioned-datasets]."

## Views

Kite's [`View`][javadoc-view] interface represents a logical collection of records in a dataset. It might seem as though a view is a subset of a dataset, but it is more accurate to think of a dataset as a view with no constraints applied.

You can use a view as the input for a MapReduce job or read its content directly by using [`View#newReader`][javadoc-view-reader] to get a `DatasetReader` that returns only records in the view.

`View` instances are [immutable][def-immutable]. You can pass the view to other operations, safe in the knowledge that it won't be changed at all.

[javadoc-view]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html
[javadoc-view-reader]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#newReader()
[def-immutable]: https://jsr-305.googlecode.com/svn/trunk/javadoc/javax/annotation/concurrent/Immutable.html

## Refining a View

You create a view by adding a constraint to an existing view or dataset using one of the following methods.

| Method                                 | Definition                                 | Example |
| [`with`][javadoc-view-with]            | Add a non-null constraint for a field      | `events.with("level")` |
| [`with`][javadoc-view-with]            | Add an equality constraint for a field     | `events.with("level", "FATAL")` |
| [`with`][javadoc-view-with]            | Add a set-inclusion constraint for a field | `events.with("level", "WARNING", "ERROR")` |
| [`from`][javadoc-view-from]            | Add a >= constraint for a field            | `events.from("day", 1)` |
| [`fromAfter`][javadoc-view-from-after] | Add a > constraint for a field             | `events.fromAfter("day", 4)` |
| [`to`][javadoc-view-to]                | Add a <= constraint for a field            | `events.to("year", 2014)` |
| [`toBefore`][javadoc-view-to-before]   | Add a < constraint for a field             | `events.toBefore("year", 2015)` |

Each method returns a new `View` with the additional constraint added to the parent view[<sup>1</sup>](#notes). 

For example, If you want to work with the `ratings` dataset and with numeric rating of _5_, you would use the `with` method.

```Java
ratings.with("rating", 5);
```

Kite inspects each record and applies this constraint before passing records to your application. Only ratings with the value _5_ are returned.

The object you pass as a constraint must match the data type. For example, if the _rating_ field is a String data type, sending the value _5_ as a constraint will throw an exception.

You can chain refinement method calls to create a more complicated view all at once. For example, if you've dfined _start_ and _end_ variables, you can select a range of times during which ratings are submitted by chaining `from` and `to` for the same record field.

```Java
ratings.from("time", start).to("time", end).with("rating", 5);
```

If the ratings dataset is partitioned by `time`, then the view will automatically take advantage of dataset partitioning. Kite intelligently determines which partitions to draw from in response to this filter value. See [Partitioned Datasets][partitioned-datasets].

[javadoc-view-with]: {{site.baseurl}}/apidocs/org/kitesdk/data/RefinableView.html#with(java.lang.String,%20java.lang.Object...)
[javadoc-view-from]: {{site.baseurl}}/apidocs/org/kitesdk/data/RefinableView.html#from(java.lang.String,%20java.lang.Comparable)
[javadoc-view-from-after]: {{site.baseurl}}/apidocs/org/kitesdk/data/RefinableView.html#fromAfter(java.lang.String,%20java.lang.Comparable)
[javadoc-view-to]: {{site.baseurl}}/apidocs/org/kitesdk/data/RefinableView.html#to(java.lang.String,%20java.lang.Comparable)
[javadoc-view-to-before]: {{site.baseurl}}/apidocs/org/kitesdk/data/RefinableView.html#toBefore(java.lang.String,%20java.lang.Comparable)

## Loading a View

In addition to creating a view with the API, you can load a view from a [view URI][view-uris]. A view URIs is analogous to a dataset URI, where the scheme is `view:` instead of `dataset:` and constraints are added as query arguments.

The following code snippet creates a view for a dataset of movie ratings submitted by the critic with `user_id` 125. 

```Java
View<Record> ratings = Datasets.load("view:hive:ratings?user_id=125");
```

[view-uris]: {{site.baseurl}}/URIs.html#view-uris

## Inspecting a View

In some use cases, it might not be necessary to return a set of values, but only verify that values do or do not exist. For example, you might want to only submit a MapReduce job if there are values that would be processed. These methods allow you to inspect a view at runtime.

### isEmpty

The [`isEmpty`][javadoc-view-isempty] method returns whether your `View` contains any records at all.

[javadoc-view-isempty]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#isEmpty()

### getUri

The [`getUri`][javadoc-view-geturi] method returns a URI for a `View` that can be passed to `Datasets.load`.

[javadoc-view-geturi]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#getUri()

### includes

The [`includes`][javadoc-view-includes] method returns whether an entity matches a view's constraints. That is, whether the record would be included in this `View` if it were present in the `Dataset`.

[javadoc-view-includes]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#includes(E)

## Working with Records in a View

You can interact with records in a view the way you would work with records in a full dataset. You can use `newReader` and `newWriter` to get the same reader or writer objects, but they are restricted to operations on the view. 

### newReader

The [`newReader`][javadoc-view-newreader] method creates an appropriate `DatasetReader` that returns only records that match the view's constraints.

[javadoc-view-newreader]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#newReader()

### newWriter

The [`newWriter`][javadoc-view-newwriter] method creates an appropriate `DatasetWriter` that will write only records that match the view's constraints. For more information, see [Writing to Views][writing-to-views].

See [Restricted Views][restricted-views].

[javadoc-view-newwriter]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#newWriter()
[writing-to-views]: {{site.baseurl}}/Writing-to-Views.html

### deleteAll

The [`deleteAll`][javadoc-view-deleteall] method deletes all entities in the dataset that match the view's constraints.

If the delete cannot be completed cleanly, then the method throws an `UnsupportedOperationException`. In the FileSystem implementation, for example, individual records cannot be deleted, only entire files. That means that Kite only allows you to delete an entire partition directory.

This method will delete records in a dataset, and will not delete the dataset itself. When called on a dataset, all records in the dataset will be removed. To delete a dataset in addition to the data stored in that dataset, use [`Datasets.delete`][dataset-delete].

[javadoc-view-deleteall]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#deleteAll()
[dataset-delete]: {{site.baseurl}}/API-Overview.html#delete

----

#### Notes:
1. Views are created by refining other views because they are [immutable][def-immutable] and cannot be changed. This works like a Java's [String methods][javadoc-substring] that always return new strings.

[javadoc-substring]: http://docs.oracle.com/javase/7/docs/api/java/lang/String.html#substring(int)
