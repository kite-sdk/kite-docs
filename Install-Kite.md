---
layout: page
title: Install the Kite Command Line Interface
---

These are the instructions for downloading the Kite command line interface. The most up-to-date instructions for downloading the current version of the software are always available at [http://kitesdk.org/docs/current/Install-Kite.html](http://kitesdk.org/docs/current/Install-Kite.html).

To download Kite with `curl`, run the following commands from a terminal window:

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/{{site.version}}/kite-tools-{{site.version}}-binary.jar -o {{site.dataset-command}}
chmod +x {{site.dataset-command}}
```

The first command downloads the Kite tools JAR to a local file named `{{site.dataset-command}}`. The second changes the access rights on the JAR so that the classes in the JAR are executable.

## Verifying the Version In Use

Some versions of CDH come with `{{site.dataset-command}}` installed. However, it might not be the latest version. To check the version, from a terminal window, enter the following command.

```
{{site.dataset-command}} --version
```

If the version number doesn't match the version you downloaded, you have two options.

1. Include the path to `{{site.dataset-command}}` when you invoke commands. For example, if the JAR file is in the current directory, use `./{{site.dataset-command}}`.

1. Replace the installed version of `{{site.dataset-command}}`.
  a. Download `{{site.dataset-command}}` (in this example, it is downloaded to the `~/` directory).
  b. Replace the old version of `{{site.dataset-command}}` in the existing location.
    1. For packages, use `sudo cp ~/{{site.dataset-command}} /usr/lib/kite/bin/{{site.dataset-command}}`.
    1. For parcels, use `sudo cp ~/{{site.dataset-command}} /opt/cloudera/parcels/lib/kite/bin/{{site.dataset-command}}`.
  
    c. To verify that the correct version is in use, enter the command `{{site.dataset-command}} --version`.
