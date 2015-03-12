---
layout: page
title: Generating Events
---
## Purpose

Kite applications work with Big Data. This example class, `GenerateEvents.java`, generates 1-1.5 million random event records, a small amount of realistic Big Data you can use with Kite examples.

### Prerequisites

* A VM or cluster configured with Flume user impersonation. See [Preparing the Virtual Machine][vm].
* An [Events dataset][events] in which to capture session events.

[vm]:{{site.baseurl}}/tutorials/preparing-the-vm.html
[events]:{{site.baseurl}}/tutorials/create-events-dataset.html

### Result

The `events` dataset is populated with realistic event records. Use these records for ad hoc queries and with Kite data analysis tutorials.

## Running GenerateEvents

Follow these steps to run GenerateEvents to populate `dataset:hive:events`. 

1. In a terminal window, navigate to `kite-examples/dataset`.
1. Enter `mvn compile`.
1. Run the Java utility with `mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.GenerateEvents"`.

Use Hue to view the records in Hive.

[events]:{{site.baseurl}}/tutorials/create-events-dataset.html

## Understanding GenerateEvents

Much of the class GenerateEvents creates random values. The two methods of interest are `run` and `generateRandomEvent`.

The `run` method performs the following tasks:

1. Creates a view of the `hive:events` dataset.
1. Creates a writer instance.
1. Spends 36 seconds writing random events.
1. Closes the writer, which stores the results in the `events` dataset.

Although the goal is to create random events, if they're _too_ random, there won't be anything to aggregate. The `while` loop simulates a user session with random values for `sessionId`, `userId`, and `ip`. It then generates up to 25 random events for that session.

```Java
    View<StandardEvent> events = Datasets.load(
        (args[0].isEmpty() ? "dataset:hive:events" : args[0]),  
               StandardEvent.class);
    DatasetWriter<StandardEvent> writer = events.newWriter();
    try {
      Utf8 sessionId = new Utf8("sessionId");
      long userId = 0;
      Utf8 ip = new Utf8("ip");
      int randomEventCount = 0;
      while (System.currentTimeMillis() - baseTimestamp < 36000) {
        sessionId = randomSessionId();
        userId = randomUserId();
        ip = randomIp();
        randomEventCount = random.nextInt(25);
        for (int i=0; i < randomEventCount; i++) {
          writer.write(generateRandomEvent(sessionId, userId, ip));
        }
      }
    } finally {
      writer.close();
    }
```

The `generateRandomEvent` method produces `StandardEvent` objects, using random values for the event and time details. 

```Java
  public StandardEvent generateRandomEvent(Utf8 sessionId, long userId, Utf8 ip) {
    return StandardEvent.newBuilder()
        .setEventInitiator(new Utf8("client_user"))
        .setEventName(randomEventName())
        .setUserId(userId)
        .setSessionId(sessionId)
        .setIp(ip)
        .setTimestamp(randomTimestamp())
        .setEventDetails(randomEventDetails())
        .build();
  }
```
