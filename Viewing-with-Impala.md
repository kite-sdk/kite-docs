---
layout: page
title: Viewing a Kite CLI Dataset with Impala
---
You can create datasets using the Kite CLI, then view the data in a variety of ways using Impala.

This example uses datasets based on the MovieLens dataset provided by the GroupLens Research Group at the University of Minnesota. You can get a copy of the original dataset at the [Grouplens site](http://grouplens.org/datasets/movielens/). The _movies.csv_ and _ratings.csv_ data files were converted from the original plain text dataset to CSV format. The Release field, which is stored in string format, has been formatted as yyyy-mm-dd so that the dates sort properly. 

## Preparation

If you have not done so already, download the Kite command-line interface jar. This jar is the executable that runs the command-line interface, so save it as `dataset`. To download with curl, run:

```
$ curl https://repository.cloudera.com/artifactory/libs-release-local/org/kitesdk/kite-tools/0.15.0/kite-tools-0.15.0-binary.jar -o dataset
$ chmod +x dataset
```

You can download the modified example CSV files from [https://github.com/DennisDawson/KiteImages/raw/master/ImpalaExample.tar.gz](https://github.com/DennisDawson/KiteImages/raw/master/ImpalaExample.tar.gz).

Expand _movies.csv_ and _ratings.csv_ to a directory containing dataset.jar.

If you are using a quickstart virtual machine, Impala is installed for you. If you need to install Impala on your own system, see the [Impala](http://www.cloudera.com/content/support/en/documentation.html) documentation for your version of CDH.

## Infer Schemas CSV Files


Use the `csv-schema` CLI command to infer the schemas for both files.

```
$ dataset csv-schema movies.csv -o movies.avsc --record-name movies 
$ dataset csv-schema ratings.csv -o ratings.avsc --record-name ratings 
```

## Create Datasets

Now that you have the schema, you can create the metadata for your tables in Hadoop. Use the `create` CLI command to add the metadata to Hadoop.

```
$ dataset create "movies" --schema movies.avsc
$ dataset create "ratings" --schema ratings.avsc
```

## Import Data

Hadoop is now prepared with empty tables, ready to import your CSV data.

```
$ dataset csv-import movies.csv movies
$ dataset csv-import ratings.csv ratings
```

## View Datasets with Impala

In a new terminal window, begin an Impala shell session.

```
$ impala-shell
```

### Invoke the Most Intuitive Command Ever Conceived. Ever.

Impala maintains its own copy of  your dataset metadata to enhance performance. When you create a table outside of Impala, you need to flag the existing metadata as out of date, so that Impala knows it needs to refresh the metadata. After you create your table using the CLI, you must run the following command. See? The following command is completely intuitive, now that it has been explained. Probably.

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
| imdburl     | string | from deserializer |
| unknown     | bigint | from deserializer |
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

Ratings, on the other hand, is narrow. It has only 4 columns, but over a
million records.

```
> desc ratings;
Query: describe ratings
+-----------+--------+-------------------+
| name      | type   | comment           |
+-----------+--------+-------------------+
| user      | bigint | from deserializer |
| id        | bigint | from deserializer |
| rating    | bigint | from deserializer |
| timestamp | bigint | from deserializer |
+-----------+--------+-------------------+
```

### Verify Data

The *movies* dataset is broad, but short, with only about 2,000 records. You can select the first 10 records, just to see that they loaded properly.

```
> select * from movies limit 10;
Query: select * from movies limit 10
+----+------------------+------------+----------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| id | title            | release    | imdburl                                                        | unknown | action | adventure | animation | children | comedy | crime | documentary | drama | fantasy | filmnoir | horror | musical | mystery | romance | scifi | thriller | war | western |
+----+------------------+------------+----------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| 1  | Toy Story        | 1995-01-01 | http://us.imdb.com/M/title-exact?Toy%20Story%20(1995)          | 0       | 0      | 0         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 2  | GoldenEye        | 1995-01-01 | http://us.imdb.com/M/title-exact?GoldenEye%20(1995)            | 0       | 1      | 1         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 1        | 0   | 0       |
| 3  | Four Rooms       | 1995-01-01 | http://us.imdb.com/M/title-exact?Four%20Rooms%20(1995)         | 0       | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 1        | 0   | 0       |
| 4  | Get Shorty       | 1995-01-01 | http://us.imdb.com/M/title-exact?Get%20Shorty%20(1995)         | 0       | 1      | 0         | 0         | 0        | 1      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 5  | Copycat          | 1995-01-01 | http://us.imdb.com/M/title-exact?Copycat%20(1995)              | 0       | 0      | 0         | 0         | 0        | 0      | 1     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 1        | 0   | 0       |
| 6  | Shanghai Triad   | 1995-01-01 | http://us.imdb.com/Title?Yao+a+yao+yao+dao+waipo+qiao+(1995)   | 0       | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 7  | Twelve Monkeys   | 1995-01-01 | http://us.imdb.com/M/title-exact?Twelve%20Monkeys%20(1995)     | 0       | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 0        | 0   | 0       |
| 8  | Babe             | 1995-01-01 | http://us.imdb.com/M/title-exact?Babe%20(1995)                 | 0       | 0      | 0         | 0         | 1        | 1      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 9  | Dead Man Walking | 1995-01-01 | http://us.imdb.com/M/title-exact?Dead%20Man%20Walking%20(1995) | 0       | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 10 | Richard III      | 1996-01-22 | http://us.imdb.com/M/title-exact?Richard%20III%20(1995)        | 0       | 0      | 0         | 0         | 0        | 0      | 0     | 0           | 1     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 1   | 0       |
+----+------------------+------------+----------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
Returned 10 row(s) in 0.19s
```
The ratings dataset is narrow but tall, with over a million records. Check the first 10 to be sure that they loaded properly, as well.

```
> select * from ratings limit 10;
Query: select * from ratings limit 10
+------+-----+--------+--------------+
| user | id  | rating | timestamp    |
+------+-----+--------+--------------+
| 1    | 122 | 5      | 838985046000 |
| 1    | 185 | 5      | 838983525000 |
| 1    | 231 | 5      | 838983392000 |
| 1    | 292 | 5      | 838983421000 |
| 1    | 316 | 5      | 838983392000 |
| 1    | 329 | 5      | 838983392000 |
| 1    | 355 | 5      | 838984474000 |
| 1    | 356 | 5      | 838983653000 |
| 1    | 362 | 5      | 838984885000 |
| 1    | 364 | 5      | 838983707000 |
+------+-----+--------+--------------+
Returned 10 row(s) in 0.16s

```

### Peek at the Data

Now that there is data in the datasets, you can view the results in a variety of ways.

```
> select * from movies where animation=1;
Query: select * from movies where animation=1
+------+----------------------------------------------------+------------+--------------------------------------------------------------------------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| id   | title                                              | release    | imdburl                                                                                                                        | unknown | action | adventure | animation | children | comedy | crime | documentary | drama | fantasy | filmnoir | horror | musical | mystery | romance | scifi | thriller | war | western |
+------+----------------------------------------------------+------------+--------------------------------------------------------------------------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+
| 1    | Toy Story                                          | 1995-01-01 | http://us.imdb.com/M/title-exact?Toy%20Story%20(1995)                                                                          | 0       | 0      | 0         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 71   | Lion King, The                                     | 1994-01-01 | http://us.imdb.com/M/title-exact?Lion%20King,%20The%20(1994)                                                                   | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 95   | Aladdin                                            | 1992-01-01 | http://us.imdb.com/M/title-exact?Aladdin%20(1992)                                                                              | 0       | 0      | 0         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 99   | Snow White and the Seven Dwarfs                    | 1937-01-01 | http://us.imdb.com/M/title-exact?Snow%20White%20and%20the%20Seven%20Dwarfs%20(1937)                                            | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 101  | Heavy Metal                                        | 1981-03-08 | http://us.imdb.com/M/title-exact?Heavy%20Metal%20(1981)                                                                        | 0       | 1      | 1         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 1      | 0       | 0       | 0       | 1     | 0        | 0   | 0       |
| 102  | Aristocats, The                                    | 1970-01-01 | http://us.imdb.com/M/title-exact?Aristocats,%20The%20(1970)                                                                    | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 103  | All Dogs Go to Heaven 2                            | 1996-03-29 | http://us.imdb.com/M/title-exact?All%20Dogs%20Go%20to%20Heaven%202%20(1996)                                                    | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 114  | Wallace & Gromit: The Best of Aardman Animation    | 1996-04-05 | http://us.imdb.com/Title?Wallace+%26+Gromit%3A+The+Best+of+Aardman+Animation+(1996)                                            | 0       | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 169  | Wrong Trousers, The                                | 1993-01-01 | http://us.imdb.com/M/title-exact?Wrong%20Trousers,%20The%20(1993)                                                              | 0       | 0      | 0         | 1         | 0        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 189  | Grand Day Out, A                                   | 1992-01-01 | http://us.imdb.com/M/title-exact?Grand%20Day%20Out,%20A%20(1992)                                                               | 0       | 0      | 0         | 1         | 0        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 206  | Akira                                              | 1988-01-01 | http://us.imdb.com/M/title-exact?Akira%20(1988)                                                                                | 0       | 0      | 1         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 1        | 0   | 0       |
| 240  | Beavis and Butt-head Do America                    | 1996-12-20 | http://us.imdb.com/M/title-exact?Beavis%20and%20Butt-head%20Do%20America%20(1996)                                              | 0       | 0      | 0         | 1         | 0        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 404  | Pinocchio                                          | 1940-01-01 | http://us.imdb.com/M/title-exact?Pinocchio%20(1940)                                                                            | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 408  | Close Shave, A                                     | 1996-04-28 | http://us.imdb.com/M/title-exact?Close%20Shave,%20A%20(1995)                                                                   | 0       | 0      | 0         | 1         | 0        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 1        | 0   | 0       |
| 418  | Cinderella                                         | 1950-01-01 | http://us.imdb.com/M/title-exact?Cinderella%20(1950)                                                                           | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 420  | Alice in Wonderland                                | 1951-01-01 | http://us.imdb.com/M/title-exact?Alice%20in%20Wonderland%20(1951)                                                              | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 422  | Aladdin and the King of Thieves                    | 1996-01-01 | http://us.imdb.com/M/title-exact?Aladdin%20and%20the%20King%20of%20Thieves%20(1996)%20(V)                                      | 0       | 0      | 0         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 426  | Transformers: The Movie, The                       | 1986-01-01 | http://us.imdb.com/M/title-exact?Transformers:%20The%20Movie,%20The%20(1986)                                                   | 0       | 1      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 1        | 1   | 0       |
| 432  | Fantasia                                           | 1940-01-01 | http://us.imdb.com/M/title-exact?Fantasia%20(1940)                                                                             | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 473  | James and the Giant Peach                          | 1996-04-12 | http://us.imdb.com/M/title-exact?James%20and%20the%20Giant%20Peach%20(1996)                                                    | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 501  | Dumbo                                              | 1941-01-01 | http://us.imdb.com/M/title-exact?Dumbo%20(1941)                                                                                | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 538  | Anastasia                                          | 1997-01-01 | http://us.imdb.com/M/title-exact?Anastasia+(1997)                                                                              | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 542  | Pocahontas                                         | 1995-01-01 | http://us.imdb.com/M/title-exact?Pocahontas%20(1995)                                                                           | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 1       | 0     | 0        | 0   | 0       |
| 588  | Beauty and the Beast                               | 1991-01-01 | http://us.imdb.com/M/title-exact?Beauty%20and%20the%20Beast%20(1991)                                                           | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 596  | Hunchback of Notre Dame, The                       | 1996-06-21 | http://us.imdb.com/M/title-exact?Hunchback%20of%20Notre%20Dame,%20The%20(1996)                                                 | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 624  | Three Caballeros, The                              | 1945-01-01 | http://us.imdb.com/M/title-exact?Three%20Caballeros,%20The%20(1945)                                                            | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 625  | Sword in the Stone, The                            | 1963-01-01 | http://us.imdb.com/M/title-exact?Sword%20in%20the%20Stone,%20The%20(1963)                                                      | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 820  | Space Jam                                          | 1996-11-15 | http://us.imdb.com/M/title-exact?Space%20Jam%20(1996)                                                                          | 0       | 0      | 1         | 1         | 1        | 1      | 0     | 0           | 0     | 1       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 946  | Fox and the Hound, The                             | 1981-01-01 | http://us.imdb.com/M/title-exact?Fox%20and%20the%20Hound,%20The%20(1981)                                                       | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 969  | Winnie the Pooh and the Blustery Day               | 1968-01-01 | http://us.imdb.com/M/title-exact?Winnie%20the%20Pooh%20and%20the%20Blustery%20Day%20%281968%29                                 | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 989  | Cats Don't Dance                                   | 1997-03-26 | http://us.imdb.com/M/title-exact?Cats%20Don%27t%20Dance%20(1997)                                                               | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 993  | Hercules                                           | 1997-06-27 | http://us.imdb.com/M/title-exact?Hercules+(1997)                                                                               | 0       | 0      | 1         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1066 | Balto                                              | 1995-01-01 | http://us.imdb.com/M/title-exact?Balto%20(1995)                                                                                | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1076 | Pagemaster, The                                    | 1994-01-01 | http://us.imdb.com/M/title-exact?Pagemaster,%20The%20(1994)                                                                    | 0       | 1      | 1         | 1         | 1        | 0      | 0     | 0           | 0     | 1       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1078 | Oliver & Company                                   | 1988-03-29 | http://us.imdb.com/M/title-exact?Oliver%20&%20Company%20(1988)                                                                 | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1091 | Pete's Dragon                                      | 1977-01-01 | http://us.imdb.com/M/title-exact?Pete's%20Dragon%20(1977)                                                                      | 0       | 0      | 1         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 1       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1219 | Goofy Movie, A                                     | 1995-01-01 | http://us.imdb.com/M/title-exact?Goofy%20Movie,%20A%20(1995)                                                                   | 0       | 0      | 0         | 1         | 1        | 1      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 1       | 0     | 0        | 0   | 0       |
| 1240 | Ghost in the Shell                                 | 1996-04-12 | http://us.imdb.com/M/title-exact?Kokaku%20Kidotai%20(1995)                                                                     | 0       | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 1     | 0        | 0   | 0       |
| 1367 | Faust                                              | 1994-01-01 | http://us.imdb.com/M/title-exact?Faust%20%281994%29                                                                            | 0       | 0      | 0         | 1         | 0        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1409 | Swan Princess, The                                 | 1994-01-01 | http://us.imdb.com/M/title-exact?Swan%20Princess,%20The%20(1994)                                                               | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1412 | Land Before Time III: The Time of the Great Giving | 1995-01-01 | http://us.imdb.com/M/title-exact?Land%20Before%20Time%20III%3A%20The%20Time%20of%20the%20Great%20Giving%20%281995%29%20%28V%29 | 0       | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
| 1470 | Gumby: The Movie                                   | 1995-01-01 | http://us.imdb.com/M/title-exact?Gumby:%20The%20Movie%20(1995)                                                                 | 0      http://www.cloudera.com/content/support/en/documentation.html | 0      | 0         | 1         | 1        | 0      | 0     | 0           | 0     | 0       | 0        | 0      | 0       | 0       | 0       | 0     | 0        | 0   | 0       |
+------+----------------------------------------------------+------------+--------------------------------------------------------------------------------------------------------------------------------+---------+--------+-----------+-----------+----------+--------+-------+-------------+-------+---------+----------+--------+---------+---------+---------+-------+----------+-----+---------+

```

Most of the columns are concerned with genre. Since you're selecting rows based on the genre, there's no reason to display them. You can just show the title and release date.

```
> select title, release from movies where animation=1;
Query: select title, release from movies where animation=1
+----------------------------------------------------+------------+
| title                                              | release    |
+----------------------------------------------------+------------+
| Toy Story                                          | 1995-01-01 |
| Lion King, The                                     | 1994-01-01 |
| Aladdin                                            | 1992-01-01 |
| Snow White and the Seven Dwarfs                    | 1937-01-01 |
| Heavy Metal                                        | 1981-03-08 |
| Aristocats, The                                    | 1970-01-01 |
| All Dogs Go to Heaven 2                            | 1996-03-29 |
| Wallace & Gromit: The Best of Aardman Animation    | 1996-04-05 |
| Wrong Trousers, The                                | 1993-01-01 |
| Grand Day Out, A                                   | 1992-01-01 |
| Akira                                              | 1988-01-01 |
| Beavis and Butt-head Do America                    | 1996-12-20 |
| Pinocchio                                          | 1940-01-01 |
| Close Shave, A                                     | 1996-04-28 |
| Cinderella                                         | 1950-01-01 |
| Alice in Wonderland                                | 1951-01-01 |
| Aladdin and the King of Thieves                    | 1996-01-01 |
| Transformers: The Movie, The                       | 1986-01-01 |
| Fantasia                                           | 1940-01-01 |
| James and the Giant Peach                          | 1996-04-12 |
| Dumbo                                              | 1941-01-01 |
| Anastasia                                          | 1997-01-01 |
| Pocahontas                                         | 1995-01-01 |
| Beauty and the Beast                               | 1991-01-01 |
| Hunchback of Notre Dame, The                       | 1996-06-21 |
| Three Caballeros, The                              | 1945-01-01 |
| Sword in the Stone, The                            | 1963-01-01 |
| Space Jam                                          | 1996-11-15 |
| Fox and the Hound, The                             | 1981-01-01 |
| Winnie the Pooh and the Blustery Day               | 1968-01-01 |
| Cats Don't Dance                                   | 1997-03-26 |
| Hercules                                           | 1997-06-27 |
| Balto                                              | 1995-01-01 |
| Pagemaster, The                                    | 1994-01-01 |
| Oliver & Company                                   | 1988-03-29 |
| Pete's Dragon                                      | 1977-01-01 |
| Goofy Movie, A                                     | 1995-01-01 |
| Ghost in the Shell                                 | 1996-04-12 |
| Faust                                              | 1994-01-01 |
| Swan Princess, The                                 | 1994-01-01 |
| Land Before Time III: The Time of the Great Giving | 1995-01-01 |
| Gumby: The Movie                                   | 1995-01-01 |
+----------------------------------------------------+------------+
Returned 42 row(s) in 0.18s
```
If you narrow the search with additional genre criteria, you can get a short list of movies that interest you most. You might look for animated science fiction films.

```
> select title, release from movies where animation=1 and scifi=1;
Query: select title, release from movies where animation=1 and scifi=1
+------------------------------+------------+
| title                        | release    |
+------------------------------+------------+
| Heavy Metal                  | 1981-03-08 |
| Akira                        | 1988-01-01 |
| Transformers: The Movie, The | 1986-01-01 |
| Ghost in the Shell           | 1996-04-12 |
+------------------------------+------------+
Returned 4 row(s) in 0.17s
```

### Get More Specific

The movies are in no particular order in the dataset. It can be helpful to sort the results. You can use `ORDER BY` to choose sort criteria.  Impala requires any query including an `ORDER BY` clause to also use a `LIMIT` clause. Sorting a huge result set can require a lot of memory. "Top-N" queries are common Impala use cases. By limiting the returned results, you avoid overwhelming memory capacity on the query's coordinator node.

```
> select title, release from movies where animation=1 and scifi=1 order by title asc limit 1000;
Query: select title, release from movies where animation=1 and scifi=1 order by title limit 1000
+------------------------------+------------+
| title                        | release    |
+------------------------------+------------+
| Akira                        | 1988-01-01 |
| Ghost in the Shell           | 1996-04-12 |
| Heavy Metal                  | 1981-03-08 |
| Transformers: The Movie, The | 1986-01-01 |
+------------------------------+------------+
```
### In the real world, this is the sort of thing you would do with a dataset like this one

Show Westerns from newest to oldest release dates.

```
> select title, release from movies where western=1 order by release desc limit 2000;
+----------------------------------------------+------------+
| title                                        | release    |
+----------------------------------------------+------------+
| Last Man Standing                            | 1996-09-20 |
| Dead Man                                     | 1996-05-10 |
| Wild Bill                                    | 1995-01-01 |
| Quick and the Dead, The                      | 1995-01-01 |
| Wyatt Earp                                   | 1994-01-01 |
| City Slickers II: The Legend of Curly's Gold | 1994-01-01 |
| Bad Girls                                    | 1994-01-01 |
| Lightning Jack                               | 1994-01-01 |
| Maverick                                     | 1994-01-01 |
| Legends of the Fall                          | 1994-01-01 |
| Geronimo: An American Legend                 | 1993-01-01 |
| Tombstone                                    | 1993-01-01 |
| Unforgiven                                   | 1992-01-01 |
| Dances with Wolves                           | 1990-01-01 |
| Young Guns II                                | 1990-01-01 |
| Young Guns                                   | 1988-01-01 |
| Apple Dumpling Gang, The                     | 1975-01-01 |
| Wild Bunch, The                              | 1969-01-01 |
| Butch Cassidy and the Sundance Kid           | 1969-01-01 |
| Once Upon a Time in the West                 | 1969-01-01 |
| Good, The Bad and The Ugly, The              | 1966-01-01 |
| Terror in a Texas Town                       | 1958-01-01 |
| Davy Crockett, King of the Wild Frontier     | 1955-01-01 |
| Magnificent Seven, The                       | 1954-01-01 |
| High Noon                                    | 1952-01-01 |
| Angel and the Badman                         | 1947-01-01 |
| Outlaw, The                                  | 1943-01-01 |
+----------------------------------------------+------------+

```
Show movies with titles that start with _Ha_ sorted by title.

```
> select title, avg(ratings.rating) 
from movies join ratings on movies.id=ratings.id
where title like "Ha%"
group by title
order by title 
limit 5000;

+---------------------------------------+---------------------+
| title                                 | avg(ratings.rating) |
+---------------------------------------+---------------------+
| Half Baked                            | 4.306878306878307   |
| Halloween: The Curse of Michael Myers | 2.866666666666667   |
| Hamlet                                | 4.333333333333333   |
| Hana-bi                               | 2.914893617021276   |
| Happy Gilmore                         | 3.75                |
| Hard Eight                            | 2.5                 |
| Hard Rain                             | 3.749572162007986   |
| Hard Target                           | 3.602176541717049   |
| Harlem                                | 3.183673469387755   |
| Harold and Maude                      | 3.882845188284519   |
| Harriet the Spy                       | 3.868421052631579   |
| Hate                                  | 3.834340991535671   |
+---------------------------------------+---------------------+
```
Show crime movies, sorted by highest to lowest rating.

```
> select title, avg(ratings.rating) 
from movies join ratings on movies.id=ratings.id 
where crime=1
group by title 
order by avg(ratings.rating) desc
limit 5000;

+-----------------------------------------+---------------------+
| title                                   | avg(ratings.rating) |
+-----------------------------------------+---------------------+
| Batman                                  | NULL                |
| Serial Mom                              | NULL                |
| Best Men                                | 4.5                 |
| Gang Related                            | 4.358695652173913   |
| Purple Noon                             | 4.320328542094455   |
| Twilight                                | 4.265193370165746   |
| Amateur                                 | 4.219512195121951   |
| Guilty as Sin                           | 4.206005004170142   |
| C'est arriv� pr�s de chez vous          | 4.172804532577904   |
| New York Cop                            | 4.153748411689961   |
| Kiss of Death                           | 4.12573673870334    |
| Once Upon a Time in America             | 4.125               |
| Big Bang Theory, The                    | 4.035040431266847   |
| Wild Things                             | 4.030769230769231   |
| From Dusk Till Dawn                     | 4.025868440502586   |
| Night Falls on Manhattan                | 4.016260162601626   |
| Devil in a Blue Dress                   | 4                   |
| Cyclo                                   | 4                   |
| Thieves                                 | 4                   |
| Donnie Brasco                           | 3.998183469573116   |
| Devil's Advocate, The                   | 3.997050147492625   |
| Batman Forever                          | 3.989501312335958   |
| Gridlock'd                              | 3.988679245283019   |
| Set It Off                              | 3.940074906367041   |
| Big Lebowski, The                       | 3.925170068027211   |
| Truth or Consequences, N.M.             | 3.895032802249297   |
| Hoodlum                                 | 3.847826086956522   |
| Bound                                   | 3.846153846153846   |
| Sting, The                              | 3.82258064516129    |
| L.A. Confidential                       | 3.813725490196079   |
| Original Gangstas                       | 3.761904761904762   |
| Romeo Is Bleeding                       | 3.75                |
| New Jersey Drive                        | 3.75                |
| U Turn                                  | 3.745454545454546   |
| Sleepers                                | 3.731468531468531   |
| Seven                                   | 3.700620017714792   |
| Freeway                                 | 3.692307692307693   |
| Switchblade Sisters                     | 3.662921348314607   |
| Keys to Tulsa                           | 3.660714285714286   |
| Mask, The                               | 3.630769230769231   |
| Hard Target                             | 3.602176541717049   |
| Curdled                                 | 3.595141700404858   |
| Albino Alligator                        | 3.530973451327434   |
| Reservoir Dogs                          | 3.509090909090909   |
| MURDER and murder                       | 3.5                 |
| Some Like It Hot                        | 3.493670886075949   |
| Strange Days                            | 3.46875             |
| Desperate Measures                      | 3.449627791563275   |
| Once Were Warriors                      | 3.412280701754386   |
| Godfather: Part II, The                 | 3.39622641509434    |
| Jackie Brown                            | 3.393939393939394   |
| Innocent Sleep, The                     | 3.367924528301887   |
| Rumble in the Bronx                     | 3.351409978308026   |
| Incognito                               | 3.345890410958904   |
| Touch of Evil                           | 3.319609967497291   |
| Professional, The                       | 3.297297297297297   |
| Playing God                             | 3.285714285714286   |
| Red Corner                              | 3.269230769230769   |
| Fargo                                   | 3.236686390532544   |
| Striptease                              | 3.222222222222222   |
| M                                       | 3.220930232558139   |
| GoodFellas                              | 3.162790697674418   |
| Copycat                                 | 3.158198614318707   |
| Heat                                    | 3.12532637075718    |
| Carpool                                 | 3.111111111111111   |
| Lashou shentan                          | 3.086261980830671   |
| Letter From Death Row, A                | 3.086021505376344   |
| Bonnie and Clyde                        | 3.063291139240506   |
| Sneakers                                | 3.044585987261147   |
| Things to Do in Denver when You're Dead | 3.041666666666667   |
| Crossfire                               | 3.02962962962963    |
| Batman Returns                          | 3.019493177387914   |
| Menace II Society                       | 3                   |
| Mad Dog Time                            | 3                   |
| Kansas City                             | 3                   |
| Young Poisoner's Handbook, The          | 2.980769230769231   |
| Grosse Pointe Blank                     | 2.977900552486188   |
| True Romance                            | 2.976047904191617   |
| City of Industry                        | 2.959183673469388   |
| Cop Land                                | 2.944099378881988   |
| Carlito's Way                           | 2.929203539823009   |
| Batman & Robin                          | 2.928571428571428   |
| Hana-bi                                 | 2.914893617021276   |
| He Walked by Night                      | 2.871794871794872   |
| Deceiver                                | 2.769230769230769   |
| Midnight in the Garden of Good and Evil | 2.766233766233766   |
| 2 Days in the Valley                    | 2.684210526315789   |
| Laura                                   | 2.678571428571428   |
| Mulholland Falls                        | 2.666666666666667   |
| Angel on My Shoulder                    | 2.662790697674418   |
| Usual Suspects, The                     | 2.633587786259542   |
| Kiss the Girls                          | 2.581818181818182   |
| Grifters, The                           | 2.5                 |
| Hard Eight                              | 2.5                 |
| Jason's Lyric                           | 2.318181818181818   |
| Pulp Fiction                            | 2.25                |
| Twin Town                               | 2.25                |
| Newton Boys, The                        | 2                   |
| Godfather, The                          | 1                   |
+-----------------------------------------+---------------------+

```
You might find it surprising that a movie like "The Godfather" received an average rating of "1," despite its iconic status. It might be helpful to know how many reviews were received for each of the films. You can use the `COUNT` function to see how many people actually voted for each film. Doing so casts an entirely different light on that rating. You can use the `ROUND` function to make the ratings column easier to read. Sorting by title makes it easier to find a specific movie.

```
> select title, round(avg(ratings.rating), 2), count(ratings.id)
from movies join ratings on movies.id=ratings.id 
where crime=1
group by title, ratings.id
order by title
limit 5000;
Query: select title, round(avg(ratings.rating), 2), count(ratings.id) from movies join ratings on movies.id=ratings.id where crime=1 group by title, ratings.id order by title limit 5000
+-----------------------------------------+-------------------------------+-------------------+
| title                                   | round(avg(ratings.rating), 2) | count(ratings.id) |
+-----------------------------------------+-------------------------------+-------------------+
| 2 Days in the Valley                    | 2.68                          | 86                |
| Albino Alligator                        | 3.53                          | 118               |
| Amateur                                 | 4.22                          | 45                |
| Angel on My Shoulder                    | 2.66                          | 93                |
| Batman                                  | NULL                          | 1                 |
| Batman & Robin                          | 2.93                          | 45                |
| Batman Forever                          | 3.99                          | 462               |
| Batman Returns                          | 3.02                          | 1840              |
| Best Men                                | 4.50                          | 2                 |
| Big Bang Theory, The                    | 4.04                          | 411               |
| Big Lebowski, The                       | 3.93                          | 517               |
| Bonnie and Clyde                        | 3.06                          | 81                |
| Bound                                   | 3.85                          | 14                |
| C'est arriv� pr�s de chez vous          | 4.17                          | 390               |
| Carlito's Way                           | 2.93                          | 238               |
| Carpool                                 | 3.11                          | 18                |
| City of Industry                        | 2.96                          | 52                |
| Cop Land                                | 2.94                          | 366               |
| Copycat                                 | 3.16                          | 931               |
| Crossfire                               | 3.03                          | 161               |
| Curdled                                 | 3.60                          | 265               |
| Cyclo                                   | 4.00                          | 2                 |
| Deceiver                                | 2.25                          | 46                |
| Deceiver                                | 3.60                          | 26                |
| Desperate Measures                      | 3.72                          | 536               |
| Desperate Measures                      | 3.36                          | 1655              |
| Devil in a Blue Dress                   | 4.00                          | 2                 |
| Devil's Advocate, The                   | 4.00                          | 390               |
| Donnie Brasco                           | 4.00                          | 1335              |
| Fargo                                   | 3.24                          | 347               |
| Freeway                                 | 3.69                          | 13                |
| From Dusk Till Dawn                     | 4.03                          | 1437              |
| Gang Related                            | 4.36                          | 205               |
| Godfather, The                          | 1.00                          | 1                 |
| Godfather: Part II, The                 | 3.40                          | 56                |
| GoodFellas                              | 3.16                          | 45                |
| Gridlock'd                              | 3.99                          | 322               |
| Grifters, The                           | 2.50                          | 2                 |
| Grosse Pointe Blank                     | 2.98                          | 186               |
| Guilty as Sin                           | 4.21                          | 1432              |
| Hana-bi                                 | 2.91                          | 50                |
| Hard Eight                              | 2.50                          | 4                 |
| Hard Target                             | 3.60                          | 912               |
| He Walked by Night                      | 2.87                          | 45                |
| Heat                                    | 3.13                          | 425               |
| Hoodlum                                 | 3.85                          | 198               |
| Incognito                               | 3.35                          | 313               |
| Innocent Sleep, The                     | 3.37                          | 113               |
| Jackie Brown                            | 3.39                          | 74                |
| Jason's Lyric                           | 2.32                          | 22                |
| Kansas City                             | 3.00                          | 1                 |
| Keys to Tulsa                           | 3.66                          | 185               |
| Kiss of Death                           | 4.13                          | 1257              |
| Kiss the Girls                          | 2.58                          | 117               |
| L.A. Confidential                       | 3.81                          | 107               |
| Lashou shentan                          | 3.09                          | 359               |
| Laura                                   | 2.68                          | 122               |
| Letter From Death Row, A                | 3.09                          | 102               |
| M                                       | 3.22                          | 89                |
| MURDER and murder                       | 3.50                          | 22                |
| Mad Dog Time                            | 3.00                          | 1                 |
| Mask, The                               | 3.63                          | 76                |
| Menace II Society                       | 3.00                          | 31                |
| Midnight in the Garden of Good and Evil | 2.77                          | 78                |
| Mulholland Falls                        | 2.67                          | 3                 |
| New Jersey Drive                        | 3.75                          | 4                 |
| New York Cop                            | 4.15                          | 941               |
| Newton Boys, The                        | 2.00                          | 1                 |
| Night Falls on Manhattan                | 4.02                          | 134               |
| Once Upon a Time in America             | 4.13                          | 10                |
| Once Were Warriors                      | 3.41                          | 135               |
| Original Gangstas                       | 3.76                          | 26                |
| Playing God                             | 3.29                          | 22                |
| Professional, The                       | 3.30                          | 75                |
| Pulp Fiction                            | 2.25                          | 5                 |
| Purple Noon                             | 4.32                          | 2335              |
| Red Corner                              | 3.27                          | 28                |
| Reservoir Dogs                          | 3.51                          | 115               |
| Romeo Is Bleeding                       | 3.75                          | 13                |
| Rumble in the Bronx                     | 3.35                          | 511               |
| Serial Mom                              | NULL                          | 2                 |
| Set It Off                              | 3.94                          | 284               |
| Seven                                   | 3.70                          | 1221              |
| Sleepers                                | 3.73                          | 808               |
| Sneakers                                | 3.04                          | 172               |
| Some Like It Hot                        | 3.49                          | 173               |
| Sting, The                              | 3.82                          | 405               |
| Strange Days                            | 3.47                          | 1595              |
| Striptease                              | 3.22                          | 10                |
| Switchblade Sisters                     | 3.66                          | 97                |
| Thieves                                 | 4.00                          | 1                 |
| Things to Do in Denver when You're Dead | 3.04                          | 132               |
| Touch of Evil                           | 3.32                          | 1048              |
| True Romance                            | 2.98                          | 173               |
| Truth or Consequences, N.M.             | 3.90                          | 1301              |
| Twilight                                | 4.27                          | 214               |
| Twin Town                               | 2.25                          | 4                 |
| U Turn                                  | 3.75                          | 112               |
| Usual Suspects, The                     | 2.63                          | 281               |
| Wild Things                             | 4.03                          | 520               |
| Young Poisoner's Handbook, The          | 2.98                          | 56                |
+-----------------------------------------+-------------------------------+-------------------+

```

If you use a query frequently, you can store it as a view. A view is a named query that you can use as shorthand when conducting additional analysis.

```
> create view crime as select title, round(avg(ratings.rating),2)
from movies join ratings on movies.id=ratings.id 
where crime=1 
group by title 
order by avg(ratings.rating) desc 
limit 5000;
```

One advantage of working with a view is that you can use the aggregate column (rating, named _c1 in the view) in a WHERE clause. If you only want to see the highest rated crime movies, you can run an additional query on the view.

```
> select * from crime where _c1 > 3.99;
Query: select * from crime where _c1 > 3.99
+--------------------------------+------+
| title                          | _c1  |
+--------------------------------+------+
| Best Men                       | 4.50 |
| Gang Related                   | 4.36 |
| Purple Noon                    | 4.32 |
| Twilight                       | 4.27 |
| Amateur                        | 4.22 |
| Guilty as Sin                  | 4.21 |
| C'est arriv� pr�s de chez vous | 4.17 |
| New York Cop                   | 4.15 |
| Kiss of Death                  | 4.13 |
| Once Upon a Time in America    | 4.13 |
| Big Bang Theory, The           | 4.04 |
| Wild Things                    | 4.03 |
| From Dusk Till Dawn            | 4.03 |
| Night Falls on Manhattan       | 4.02 |
| Thieves                        | 4.00 |
| Cyclo                          | 4.00 |
| Devil in a Blue Dress          | 4.00 |
| Donnie Brasco                  | 4.00 |
| Devil's Advocate, The          | 4.00 |
+--------------------------------+------+
```

Beyond that, it's all Impala. See the [Impala documentation](http://www.cloudera.com/content/support/en/documentation.html) for more detail on your available SQL options.
