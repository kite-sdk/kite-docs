---
layout: page
title: Using Kite with Apache Maven
---

The easiest way to use the Kite API in your own Java project is to use [Apache Maven](http://maven.apache.org). Maven is a build tool that handles the end-to-end build life cycle of a project including compilation, testing, packaging, and deployment. In addition, Maven handles many of the details of dependency management for you.

The core of a Maven project is the Project Object Model (POM) file. POM files are written in XML and provide a declarative way to configure your project and declare your dependencies. For more information on working with POM files see [Maven's POM Reference](http://maven.apache.org/pom.html#What_is_the_POM).

To make it even easier to use Kite with Maven, we publish a set of POM files that can be used as the parent of your application's POM. These application parent POMs are pre-configured with the dependencies you need to get started.  The application parent POMs also pre-configure the Kite and Apache Avro Maven plugins for use in your project.

In order to use the application parent POM, you simply need to configure the `parent` element in your `pom.xml` file with the appropriate `groupId`, `artifactId`, and `version`:

{% highlight xml %}
<parent>
  <groupId>org.kitesdk</groupId>
  <artifactId>kite-app-parent-cdh5</artifactId>
  <version>{{site.version}}</version>
</parent>
{% endhighlight %}

Currently, Kite has an application parent POM for CDH4 and CDH5. You can select the one you want to use by setting the `artifactId` to `kite-app-parent-cdh4` for CDH4 or `kite-app-parent-cdh5` for CDH5.

The [Kite examples](https://github.com/kite-sdk/kite-examples) are built using the application parent POMs and are a great way to see what a Kite Maven project looks like. If you're looking for a very simple starting point, take a look at the [dataset example's pom.xml](https://github.com/kite-sdk/kite-examples/blob/master/dataset/pom.xml).

After you've created your POM file and written some Java code, you can use Maven to build and test your project. Here is a short reference to some common Maven commands.

To compile your project you would run:

```
mvn compile
```

To build a JAR file you would use:

```
mvn package
```

To run your unit tests you can run:

```
mvn test
```

To install your packaged JAR into your local Maven repository you would use:

```
mvn install
```

That last command is especially useful for multi-module Maven project such as the [Kite end-to-end demo example](https://github.com/kite-sdk/kite-examples/tree/master/demo). If you want to learn more about working with Maven, check out their [Maven in 5 Minutes](http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html) guide and their follow-up [Maven Getting Started Guide](http://maven.apache.org/guides/getting-started/index.html).
