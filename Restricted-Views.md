---
layout: page
title: Restricted Views
---

Kite lets you write records to views. Kite then adds the records to the source tables. Kite does not store data in the wrong location when you write to a view. This prevents loss or corruption of data. In the context of a MapReduce or Crunch job, writing records to the wrong place causes the job to fail with an `IllegalArgument` exception. 

For example, you might have a Movies dataset partitioned by decade. Your application works with a view on that dataset. Your application attempts to store a record with a release date of 1941 in the 1950s partition. The operation fails.

It's important to write your applications so that they "do the right thing" when they write to a view. This will avoid the exception and its unhelpful message. 

If storage rules are not significant in your application, you can avoid these checks by writing directly to the top-level dataset.
