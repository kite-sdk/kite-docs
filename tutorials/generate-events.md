---
layout: page
title: Generating Events
---

Kite applications work with Big Data. `GenerateEvents.java` generates 1-1.5 million random event records, a small amount of realistic Big Data you can use with Kite examples.

Much of the class is devoted to creating random values. The two methods of interest are `run` and `generateRandomEvent`.

The `run` method performs the following tasks:
* creates a view of the `hive:events` dataset
* creates a writer instance
* spends 36 seconds writing random events
* closes the writer, which stores the results in the `events` dataset.

While the goal is to create random events, if they're _too_ random there won't be anything to aggregate. The `while` loop simulates a user session with random values for `sessionId`, `userId`, and `ip`. It then generates up to 25 random events for that session.

```Java
    View<StandardEvent> events = Datasets.load(
        "dataset:hive:events", StandardEvent.class);
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

The `generateRandomEvent` method produces `StandardEvent` objects using random values for the event and time details. 

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

## Running GenerateEvents

This example assumes that you've already created the [`hive:events` dataset][events].

These are the steps to run the GenerateEvents program to populate the `hive:events` dataset. 

1. In a terminal window, navigate to `/kite-examples/dataset`.
1. Enter `mvn compile`.
1. Run the Java utility with `mvn exec:java -Dexec.mainClass="org.kitesdk.examples.data.GenerateEvents"`.

Use Hue to view the records in Hive.

[events]:{{site.baseurl}}/tutorials/create-events-dataset.html