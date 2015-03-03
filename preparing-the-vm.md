---
layout: page
title: Preparing the Virtual Machine
---

Complete the following steps to run Kite example code on a Cloudera Quickstart VM.

* Install a VirtualBox or VMWare [Cloudera QuickStart VM][getvm] version 5.2 or later.
* In that VM, run the following command from a terminal window. This command clones a local copy of Kite code examples you can build and run.

```bash
git clone https://github.com/kite-sdk/kite-examples.git
```
* Download the `kite-dataset` CLI JAR. To install the Kite CLI using `curl` and give execution permission to `kite-dataset.jar`, run the following commands from a terminal window.

```
curl http://central.maven.org/maven2/org/kitesdk/kite-tools/{{site.version}}/kite-tools-{{site.version}}-binary.jar -o {{site.dataset-command}}
chmod +x {{site.dataset-command}}
```

[getvm]: http://www.cloudera.com/content/support/en/downloads/quickstart_vms.html

## Configuring the VM

Some Kite examples require Flume. If you use Cloudera Manager, Flume user impersonation is configured for you. If do not use Cloudera Manager, you must enable Flume user impersonation.

### Enabling Flume User Impersonation

Flume impersonates the dataset owner to write to your dataset, much like the Unix `sudo` utility. See [Configuring Flume's Security Properties](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Security-Guide/cdh5sg_flume_security_props.html#topic_4_2_1_unique_1).

Add the following XML snippet to your `/etc/hadoop/conf/core-site.xml` file.

```
<property>
  <name>hadoop.proxyuser.flume.groups</name>
  <value>*</value>
</property>
<property>
  <name>hadoop.proxyuser.flume.hosts</name>
  <value>*</value>
</property>
```

Restart your NameNode by running the following command in a terminal window.

```
sudo service hadoop-hdfs-namenode restart
```

## Working with the VM

All usernames/passwords for the VM are `cloudera`/`cloudera`.

## Troubleshooting

* __I can't find the VM files in VirtualBox (or VMWare).__
  * You might need to unpack the VM files.
    * On Windows, install 7zip, and extract the VM files from the `.7z` file.   
    * On Linux or Mac:
      1. In a terminal window, navigate to where you copied the VM file.
      1. Enter the command `7zr e <filename>`. For example, to extract files for the 5.4 VirtualBox VM, you  run the following command.
      `7zr e cloudera-quickstart-vm-5.4-virtualbox.7z`.
  * Import the extracted files to VirtualBox or VMWare.

* __How do I open an `.ovf` file?__
  1. Install and open [VirtualBox][vbox] on your computer.
  1. From the __File__ menu, choose __Import Appliance...__.
  1. Navigate to the `.ovf` file and open it.

* __What is a `.vmdk` file?__
  * The `.vmdk` file is the VM disk image that accompanies an `.ovf` file. The .ovf file is a portable VM description.

* __How do I open a `.vbox` file?__
  1. Install and open [VirtualBox][vbox] on your computer.
  1. From the __Machine__ menu, choose __Add...__.
  1. Navigate to where you unpacked the `.vbox` file and select it.
  1. Click __Open__, and click __Continue__.
  1. Follow the steps in [Configuring the VM](#configuring-the-vm) to complete the installation.

* __How do I fix "VTx" errors?__
  1. Reboot your computer and enter BIOS.
  1. Find the _Virtualization_ settings (usually under _Security_), and enable all of the virtualization options.

* __How do I get my mouse back?__
  * If your mouse/keyboard is stuck in the VM (captured), you can usually release it by pressing the right `CTRL` key. If you don't have one (or if that didn't work), click the release key in the lower-right corner of the VirtualBox window.

* __Other problems__
  * Using VirtualBox? Try using VMWare.
  * Using VMWare? Try using VirtualBox.

[vbox]: https://www.virtualbox.org/wiki/Downloads