---
layout: page
title: 'A Data API for Hadoop'
---

Kite is a high-level data layer for Hadoop. It is an API and a set of tools that speed up development: you configure how Kite stores your data, instead of building and maintaining that infrastructure yourself.

## High-level tools

Kite's API and tools are built around datasets, which are identified by unique URIs, like `dataset:hive:ratings`. The dataset is a consistent interface for working with your data, whether it's stored in Parquet or Avro, HDFS or HBase, snappy compression or deflate. You still have control of those details, but you tell Kite what to do so you don't have to worry about how it happens.


<div class="right">
{% highlight text %}
$> kite-dataset csv-import ratings.csv \
              dataset:hbase:zk/ratings
Added 1000000 records to dataset "ratings"
{% endhighlight %}
</div>

Kite's command-line tools help you quickly manage datasets with pre-built tasks, like creating datasets, migrating schemas, or loading data. It also helps you configure Kite and other Hadoop projects.

[<i class="fa fa-chevron-right"></i>&nbsp; Get started with Kite's CSV tutorial][kite-cli]

<div class="left">
{% highlight java %}
View latest = Datasets.load(uri)
    .from("time", startOfToday)
    .to("time", now);
{% endhighlight %}
</div>

Kite's data API provides programmatic access to datasets. Using the API, you can select subsets of your data for MapReduce and Spark pipelines and build applications that interact with datasets directly.

[<i class="fa fa-chevron-right"></i>&nbsp; Learn more about Kite datasets][kite-data-overview]

## Low-level control

You control your data layout, record schema, and other options with straight-forward configuration when creating a dataset. Once a dataset is created, you can focus on building the rest of your app and let Kite handle storage. Kite automatically partitions records when writing and prunes partitions when reading.

<div class="columns">
  <div class="left">
{% highlight text %}
time,rating,user_id,item_id
1412361369702,4,34,18865
...
{% endhighlight %}
    <div class="center"><i class="fa fa-plus"></i></div>
{% highlight json %}
[
  {"type": "year", "source": "time"},
  {"type": "month", "source": "time"},
  {"type": "day", "source": "time"},
]
{% endhighlight %}
  </div>
  <div class="middle"><i class="fa fa-arrow-right"></i></div>
  <div class="right">
{% highlight text %}
datasets/
└── ratings/
    └── year=2014/
        ├── month=09/
        │   ├── day=01/
        │   ├── ...
        │   └── day=30/
        ├── month=10/
        │   ├── day=01/
        │   ├── ...
{% endhighlight %}
  </div>
</div>

[<i class="fa fa-chevron-right"></i>&nbsp; Learn more about configuring Kite][kite-config]

## Configuration-based transformation

Kite morphlines is a flexible way to express data transformations as configuration.

[<i class="fa fa-chevron-right"></i>&nbsp; Go to the Morphlines reference guide][morphlines-intro]

[kite-cli]: {{ site.baseurl }}/Using-the-Kite-CLI-to-Create-a-Dataset
[kite-data-overview]: {{ site.baseurl }}/Kite-Data-Module-Overview
[kite-config]: {{ site.baseurl }}/configuraton-formats
[morphlines-intro]: /docs/latest/kite-morphlines/index.html
