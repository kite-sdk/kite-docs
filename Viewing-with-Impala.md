---
layout: page
title: Viewing a Kite CLI Dataset with Impala
---
You can create datasets using the Kite CLI, then view the data in a variety of ways using Impala.

This example uses datasets based on the MovieLens dataset provided by the GroupLens Research Group at the University of Minnesota. You can get a copy of the original dataset at the [Grouplens site](http://grouplens.org/datasets/movielens/). For this example, the _movies.csv_ and _ratings.csv_ data files are converted from the original plain text dataset to CSV format. The Release field, which is stored in string format, has been formatted as yyyy-mm-dd so that the dates sort properly. You can modify the GroupLens files yourself as a starting point, you can create your own sample CSV files based on the table descriptions below, or you can use [Dennis's Random Ratings Dataset](https://github.com/DennisDawson/KiteImages/raw/master/movies.zip), a list of random ratings for movies that do not exist (at least not yet).

## Preparation

If you have not done so already, [install the Kite command-line interface jar](../Install-Kite/index.html).

If you are using a quickstart virtual machine, Impala is installed for you. If you need to install Impala on your own system, see the [Impala](http://www.cloudera.com/content/support/en/documentation.html) documentation for your version of CDH.

## Infer Schemas from CSV Files


Use the `csv-schema` CLI command to infer the schemas for both files.

```
$ {{site.dataset-command}} csv-schema movies.csv -o movies.avsc --record-name movies 
$ {{site.dataset-command}} csv-schema ratings.csv -o ratings.avsc --record-name ratings 
```

## Create Datasets

Now that you have the schema, you can create the metadata for your tables in Hadoop. Use the `create` CLI command to add the metadata to Hadoop.

```
$ {{site.dataset-command}} create "movies" --schema movies.avsc
$ {{site.dataset-command}} create "ratings" --schema ratings.avsc
```

## Import Data

Hadoop is now prepared with empty tables, ready to import your CSV data.

```
$ {{site.dataset-command}} csv-import movies.csv movies
$ {{site.dataset-command}} csv-import ratings.csv ratings
```

## View Datasets with Impala

In a new terminal window, begin an Impala shell session.

```
$ impala-shell
```

### Invalidate Metadata

Impala maintains its own copy of your dataset metadata to enhance performance. When you create a table outside of Impala, you need to flag the existing metadata as out of date, so that Impala knows it needs to refresh the metadata. After you create your table using the CLI, you must run the following command.

```
> invalidate metadata;
```

### Verify That Tables Are Created Properly

```
> show tables;
Query: show tables
+-----------+
| name      |
+-----------+
| movies    |
| ratings   |
| sample_07 |
| sample_08 |
+-----------+

```

The movies dataset is broad, with many columns. Use the desc[ribe] query to view the metadata for the table.

```
> desc movies;
Query: describe movies
+-------------+--------+-------------------+
| name        | type   | comment           |
+-------------+--------+-------------------+
| id          | bigint | from deserializer |
| title       | string | from deserializer |
| release     | string | from deserializer |
| action      | bigint | from deserializer |
| adventure   | bigint | from deserializer |
| animation   | bigint | from deserializer |
| children    | bigint | from deserializer |
| comedy      | bigint | from deserializer |
| crime       | bigint | from deserializer |
| documentary | bigint | from deserializer |
| drama       | bigint | from deserializer |
| fantasy     | bigint | from deserializer |
| filmnoir    | bigint | from deserializer |
| horror      | bigint | from deserializer |
| musical     | bigint | from deserializer |
| mystery     | bigint | from deserializer |
| romance     | bigint | from deserializer |
| scifi       | bigint | from deserializer |
| thriller    | bigint | from deserializer |
| war         | bigint | from deserializer |
| western     | bigint | from deserializer |
+-------------+--------+-------------------+
 
```

Ratings, on the other hand, is narrow. It has only 3 columns, but around 2500 records.

```
> desc ratings;
Query: describe ratings
+--------+--------+-------------------+
| name   | type   | comment           |
+--------+--------+-------------------+
| id     | bigint | from deserializer |
| critic | bigint | from deserializer |
| rating | bigint | from deserializer |
+--------+--------+-------------------+

```

### Verify Data

The *movies* dataset is broad, but short, with only 50 records. You can select the first 10 records, just to see that they loaded properly.

```
> select * from movies limit 10;
Query: select * from movies limit 10
+----+------------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| id | title                  | release    | action | adventure | animation | children | comedy | crime | documentary | drama | fantasy | filmnoir | horror | musical | mystery | romance | scifi | thriller | war | western |
+----+------------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| 1  | Anticoagulance         | 2003-11-15 | 1      | 0         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 1      | 0       | 0       | 0       | 1     | 0        | 1   | 0       |
| 2  | Boy and His Cattle, A  | 2012-03-18 | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 3  | Carpool to Vermont     | 2005-10-01 | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 0        | 0   | 0       |
| 4  | Chameleon Chameleon    | 2009-02-20 | 1      | 1         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 5  | Champion of Mediocrity | 2011-01-09 | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 1        | 0   | 0       |
| 6  | Chest Pains            | 2001-12-14 | 0      | 0         | 0         | 0        | 1      | 0     | 0           | 1     | 0       | 0        | 1      | 1       | 0       | 0       | 0     | 1        | 0   | 0       |
| 7  | Chuck Maggot           | 2003-07-16 | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 8  | Cock Crows Thrice, The | 2005-06-26 | 0      | 1         | 0         | 1        | 0      | 0     | 0           | 0     | 1       | 0        | 0      | 1       | 0       | 1       | 0     | 0        | 0   | 0       |
| 9  | Cormack!               | 2003-03-10 | 0      | 0         | 0         | 0        | 1      | 0     | 0           | 0     | 1       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 10 | Dancing in Detroit     | 2004-08-19 | 0      | 0         | 0         | 0        | 0      | 1     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
+----+------------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+

```
The ratings dataset is narrow but tall, with about 2500 records. Check the first 10 to be sure that they loaded properly, as well.

```
> select * from ratings limit 10;
Query: select * from ratings limit 10
+----+--------+--------+
| id | critic | rating |
+----+--------+--------+
| 1  | 1      | 1      |
| 1  | 2      | 2      |
| 1  | 3      | 1      |
| 1  | 4      | 1      |
| 1  | 5      | 1      |
| 1  | 6      | 1      |
| 1  | 7      | 1      |
| 1  | 8      | 1      |
| 1  | 9      | 1      |
| 1  | 10     | 2      |
+----+--------+--------+

```

### Peek at the Data

Now that there is data in the datasets, you can view the results in a variety of ways.

```
> select * from movies where animation=1;
Query: select * from movies where animation=1
+----+-----------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| id | title                 | release    | action | adventure | animation | children | comedy | crime | documentary | drama | fantasy | filmnoir | horror | musical | mystery | romance | scifi | thriller | war | western |
+----+-----------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| 2  | Boy and His Cattle, A | 2012-03-18 | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 7  | Chuck Maggot          | 2003-07-16 | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 11 | Dingo!                | 2010-08-04 | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 1     | 0        | 0   | 0       |
| 25 | Naughty Randy         | 2003-04-27 | 0      | 0         | 1         | 0        | 0      | 0     | 1           | 0     | 0       | 1        | 0      | 0       | 1       | 0       | 0     | 0        | 0   | 0       |
| 37 | Space Dentist         | 2014-02-18 | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 0        | 0   | 0       |
| 47 | Trout Catchers        | 2010-07-25 | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 1        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 1       |
+----+-----------------------+------------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+

```

Most of the columns are concerned with genre. Since you're selecting rows based on the genre, there's no reason to display them. You can just show the title and release date.

```
> > select title, release from movies where animation=1;
Query: select title, release from movies where animation=1
+-----------------------+------------+
| title                 | release    |
+-----------------------+------------+
| Boy and His Cattle, A | 2012-03-18 |
| Chuck Maggot          | 2003-07-16 |
| Dingo!                | 2010-08-04 |
| Naughty Randy         | 2003-04-27 |
| Space Dentist         | 2014-02-18 |
| Trout Catchers        | 2010-07-25 |
+-----------------------+------------+
```

If you narrow the search with additional genre criteria, you can get a short list of movies that interest you most. You might look for animated science fiction films.

```
> > select title, release from movies where animation=1 and scifi=1;
Query: select title, release from movies where animation=1 and scifi=1
+---------------+------------+
| title         | release    |
+---------------+------------+
| Dingo!        | 2010-08-04 |
| Space Dentist | 2014-02-18 |
+---------------+------------+

```

### Realistic Examples

It can be helpful to sort the results of your queries. You can use `ORDER BY` to choose your sort criteria.  Impala requires any query including an `ORDER BY` clause to also use a `LIMIT` clause. The reason is that sorting a huge result set can require a lot of memory. "Top-N" queries are common Impala use cases. By limiting the returned results, you avoid overwhelming memory capacity on the query's coordinator node.

Show Westerns from newest to oldest release dates.

```
> select title, release from movies where western=1 order by release desc limit 2000;
Query: select title, release from movies where western=1 order by release desc limit 2000
+------------------+------------+
| title            | release    |
+------------------+------------+
| Wrastlin'!       | 2013-04-08 |
| Trout Catchers   | 2010-07-25 |
| Empty Wagons     | 2009-10-23 |
| Traffic Surgeon  | 2006-12-13 |
| Simple Pleasures | 2006-05-12 |
| Tutti and Frutti | 2001-06-29 |
| Numbskull        | 2001-03-03 |
+------------------+------------+

```
Show movies with titles that start with _S_, sorted by title.

```
 > select title, avg(ratings.rating) 
from movies join ratings on movies.id=ratings.id
where title like "S%"
group by title
order by title 
limit 5000;
Query: select title, avg(ratings.rating) from movies join ratings on movies.id=ratings.id where title like "S%" group by title order by title limit 5000
+----------------------+---------------------+
| title                | avg(ratings.rating) |
+----------------------+---------------------+
| Simple Pleasures     | 4.28                |
| Something Shapely    | 1.34                |
| Sometimes It's a Boy | 2.24                |
| Space Dentist        | 2.22                |
| Spaetzle             | 3.22                |
| Spaetzle 2           | 2.24                |
| Stegoceratops!       | 1.26                |
+----------------------+---------------------+

```

Show crime movies, sorted by highest to lowest rating.

```

> select title, avg(ratings.rating) 
from movies join ratings on movies.id=ratings.id 
where crime=1
group by title 
order by avg(ratings.rating) desc
limit 5000;
Query: select title, avg(ratings.rating) from movies join ratings on movies.id=ratings.id where crime=1 group by title order by avg(ratings.rating) desc limit 5000
+--------------------+---------------------+
| title              | avg(ratings.rating) |
+--------------------+---------------------+
| Embryoglio         | 4.12                |
| Dancing in Detroit | 1.22                |
| Tattlers           | 1                   |
+--------------------+---------------------+


```

You might find it surprising that a modern classic like "Tattlers" received an average rating of "1," despite its iconic status. It might be helpful to know how many reviews were received for each of the films. You can use the `COUNT` function to see how many critics actually ranked for each film. Doing so casts an entirely different light on that rating. You can use the `ROUND` function to make the ratings column easier to read. Sorting by title makes it easier to find a specific movie.

```
> select title, round(avg(ratings.rating), 2), count(ratings.id)
from movies join ratings on movies.id=ratings.id 
where crime=1
group by title, ratings.id
order by title
limit 5000;
Query: select title, round(avg(ratings.rating), 2), count(ratings.id) from movies join ratings on movies.id=ratings.id where crime=1 group by title, ratings.id order by title limit 5000
+--------------------+-------------------------------+-------------------+
| title              | round(avg(ratings.rating), 2) | count(ratings.id) |
+--------------------+-------------------------------+-------------------+
| Dancing in Detroit | 1.22                          | 50                |
| Embryoglio         | 4.12                          | 50                |
| Tattlers           | 1.00                          | 1                 |
+--------------------+-------------------------------+-------------------+

```

If you use a query frequently, you can store it as a view. A view is a named query that you can use as shorthand when conducting additional analysis.

```
> create view children as select title, round(avg(ratings.rating),2)
from movies join ratings on movies.id=ratings.id 
where children=1 
group by title 
order by avg(ratings.rating) desc 
limit 5000;
Query: create view children as select title, round(avg(ratings.rating),2) from movies join ratings on movies.id=ratings.id where children=1 group by title order by avg(ratings.rating) desc limit 5000

Returned 0 row(s) in 0.04s

```

No rows are returned as a result of the query, but Impala creates a new view.

One advantage of working with a view is that you can use the aggregate column (rating, named _c1 in the view) in a WHERE clause. If you only want to see the highest rated movies for children, you can run an additional query on the view.

```
> select * from children where _c1> 2.5;
Query: select * from children where _c1> 2.5
+-----------------------+------+
| title                 | _c1  |
+-----------------------+------+
| Simple Pleasures      | 4.28 |
| Return from Mars      | 4.24 |
| Tell 'Em Mikey's Back | 4.12 |
| Fledgling             | 3.30 |
| Boy and His Cattle, A | 3.24 |
+-----------------------+------+

```

Beyond that, it's all variations on the SQL calls supported by Impala. See the [Impala documentation](http://www.cloudera.com/content/support/en/documentation.html) for more detail on your available SQL options.
