---
layout: page
title: 'Kite: A Data API for Hadoop'
---

Kite is a high-level data layer for Hadoop. It is an API and a set of tools that speed up development. You configure how Kite stores your data in Hadoop, instead of building and maintaining that infrastructure yourself.

## High-level tools

Kite's API and tools are built around datasets. Datasets are uniquely identified URIs, like `dataset:hive:ratings`.

Dataset is a consistent interface for working with your data. You have control of implementation details, such as whether to use Avro or Parquet format, HDFS or HBase storage, and snappy compression or another. You only have to tell Kite what to do; Kite handles the implementation for you.

<div class="right">
{% highlight text %}
$> kite-dataset csv-import ratings.csv \
              dataset:hbase:zk/ratings
Added 1000000 records to dataset "ratings"
{% endhighlight %}
</div>

Kite's command-line interface helps you manage datasets with pre-built tasks like creating datasets, migrating schemas, and loading data. It also helps you configure Kite and other Hadoop projects.

[<i class="fa fa-chevron-right"></i>&nbsp; Get started with Kite's CSV tutorial][kite-cli]

<div class="left">
{% highlight java %}
View latest = Datasets.load(uri)
    .from("time", startOfToday)
    .to("time", now);
{% endhighlight %}
</div>

Kite's data API provides programmatic access to datasets. Using the API, you can build applications that directly interact with your datasets. For example, you can load a dataset and select a subset of it for a MapReduce pipeline.

[<i class="fa fa-chevron-right"></i>&nbsp; Learn more about Kite datasets][kite-data-overview]

## Low-level control

When you create a dataset, you control your data layout, record schema, and other options with straight-forward configuration. Then you can focus on building your application, while Kite handles data storage for you. Kite automatically partitions records when writing and prunes partitions when reading. It will even keep Hive up-to-date with a dataset's newest partitions.

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

[kite-cli]: {{site.baseurl}}/Using-the-Kite-CLI-to-Create-a-Dataset.html
[kite-data-overview]: {{site.baseurl}}/Kite-Data-Module-Overview.html
[kite-config]: {{site.baseurl}}/configuraton-formats.html
[morphlines-intro]: {{site.baseurl}}/morphlines/
