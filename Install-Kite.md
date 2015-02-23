---
layout: page
title: Install the Kite Command Line Interface
---

To download Kite with `curl`, run the following commands from a terminal window:

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/{{site.version}}/kite-tools-{{site.version}}-binary.jar -o {{site.dataset-command}}
chmod +x {{site.dataset-command}}
```

The first command downloads the Kite tools JAR to a local file named _{{site.dataset-command}}_. The second changes the access rights on the JAR so that the classes in the JAR are executable.

Some versions of the Cloudera QuickStart VM comes with Kite installed. However, it might not be the latest version. To check the version, from a terminal window, enter the following command.

```
kite-dataset --version
```

If the version number doesn't match the version you downloaded, you have two options.

1. Include the path to `kite-dataset` when you invoke commands. For example, if the JAR file is in the current directory, use `./kite-dataset`.

1. Replace the installed version of `kite-dataset.jar`.
  a. Download `kite-dataset.jar` to the home directory.
  b. In a terminal window on the VM, navigate to `/usr/bin`.
  c. Enter the command `sudo cp ~/kite-dataset ./kite-dataset`
  d. To verify that the correct version is in use, enter the command `kite-dataset --version`.