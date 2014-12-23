---
layout: page
title: Writing to Views
---

In Kite, a view is a logical collection of records defined by a set of constraints. When reading a view, Kite filters out records that don't match the view's constraints. Similarly, you can use a view to restrict the records that a writer will accept to the subset of your dataset that is included in a view.

Kite `DatasetWriters` created using [`View#newWriter`][javadoc-view-newwriter] reject records that don't match the view's constraints by throwing an exception. This is useful when you want to guarantee writers behave a certain way. If, however, storage guarantees are not significant in your application, you can avoid these checks by creating writers for the dataset.

## Why restrict writes?

Take, for example, an ingest process that monitors a directory for today's data and imports CSV files to a dataset when they arrive. A simple approach is to use the dataset's URI as the import target:

```
kite-dataset csv-import $file dataset:hive:logs
```

If one of the processes creating those files has a clock problem and starts producing files with records in January 1970, this import command will happily add the data as though it were valid.

To fix this problem, you can add the expectation that the data is for today, using a view URI for the target:

```
current_uri=view:hive:logs?year=`date +%Y`\&month=`date +%m`\&day=`date +%d`
kite-dataset csv-import $file $current_uri || mv $file bad_files/
```

Now, files with invalid dates will be rejected.

## Other uses

You may also want to restrict writers to guarantee data pipelines written with the Kite API behave in expected ways. This is useful for cases such as:

* Ensuring a writer is responsible for no more than N partitions to avoid file thrashing
* Ensuring writers are not responsible for the same set of partitions to minimize the number of files
* Ensuring writers are sent the correct data (when dividing work between several writers)

For example, you might have two writers working in parallel on the same dataset partitioned by time. You can set a constraint on writer1 so that it only writes to a view (and its partition) for the month of June, and a constraint on writer2 so that it only writes to a view for the month of July. This ensures the writers will not write to the same partition, which would create extra files, and validates that no records in July are sent to writer1.

[javadoc-view-newwriter]: {{site.baseurl}}/apidocs/org/kitesdk/data/View.html#newWriter()
