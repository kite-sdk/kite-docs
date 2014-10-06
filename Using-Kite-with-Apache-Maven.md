---
layout: page
---

The easiest way to start working with the Kite API is to use [Apache Maven](http://maven.apache.org). Maven is a build tool that handles the end-to-end build life cycle of a project including compilation, testing, packaging, and deployment. In addition, Maven handles many of the details of dependency management for you.

The core of a Maven project is the Project Object Model (POM) file. POM files are written in XML and provide a declarative way to configure your project and declare your dependencies. For more information on working with POM files see [Maven's POM Reference](http://maven.apache.org/pom.html#What_is_the_POM).

To make it even easier to use Kite with Maven, we publish a set of POM files that can be used as the parent of your application's POM. These application parent POMs are pre-configured with the dependencies you need to get started.  The application parent POMs also pre-configure the Kite and Apache Avro Maven plugins for use in your project.

In order to use the application parent POM, you simply need to configure the `parent` element in your `pom.xml` file with the appropriate `groupId`, `artifactId`, and `version`:

{% highlight xml %}
  <parent>
    <groupId>org.kitesdk</groupId>
    <artifactId>kite-app-parent-cdh5</artifactId>
    <version>0.17.0</version>
  </parent>
{% endhighlight %}

Currently, Kite has an application parent POM for CDH4 and CDH5. You can select the one you want to use by setting the `artifactId` to `kite-app-parent-cdh4` for CDH4 or `kite-app-parent-cdh5` for CDH5.

To aid in rapid prototyping and testing your Maven project directly on a cluster, the `kite-app-parent-cdh5` version is configured to add Hadoop and Hive configuration files to your output JAR. The files are only included if you set the `HADOOP_CONF_DIR` or `HIVE_CONF_DIR` environment variables to your configuration directories.

For example, you can ensure that your cluster's Hadoop configuration is picked up by running:

{% highlight bash %}
export HADOOP_CONF_DIR=/etc/hadoop/conf
{% endhighlight %}

prior to running a Maven command. Hive configuration can be included in a similar fashion:

{% highlight bash %}
export HIVE_CONF_DIR=/etc/hive/conf
{% endhighlight %}

__WARNING:__ While this is convenient for testing projects on a cluster, for example when using the `mvn exec:java` command to run classes, it is *not* a good idea to include configuration files when building code for release. The easiest way to ensure they won't be included in your final build is to unset the environment variables:

{% highlight bash %}
unset HADOOP_CONF_DIR
unset HIVE_CONF_DIR
{% endhighlight %}
