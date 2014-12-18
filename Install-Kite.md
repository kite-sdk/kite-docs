---
layout: page
title: Install the Kite Command Line Interface
---

You can download Kite using `curl`. The following commands download the Kite JAR and prepare it for and install Kite. Replace both occurrences of the _version_number_ with the most recent version number to install a local copy of the Kite CLI.

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/version_number/kite-tools-version_number-binary.jar -o {{site.dataset-command}}
```

For example, the following command downloads Kite CLI 0.18.0

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/0.18.0/kite-tools-0.18.0-binary.jar -o {{site.dataset-command}}
```

Once you've downloaded the JAR, change the access rights on the JAR so that the classes in the JAR are executable.

```
chmod +x {{site.dataset-command}}
```