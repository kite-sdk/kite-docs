---
layout: page
title: Install the Kite Command Line Interface
---

To download Kite with `curl`, run the following commands from a terminal window:

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/0.17.0/kite-tools-0.17.0-binary.jar -o {{site.dataset-command}}
chmod +x {{site.dataset-command}}
```

The first command downloads the Kite tools JAR to a local file named _{{site.dataset-command}}_. The second changes the access rights on the JAR so that the classes in the JAR are executable.
