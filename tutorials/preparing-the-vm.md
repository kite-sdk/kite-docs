---
layout: page
title: Preparing the Virtual Machine
---
## Purpose
This lesson describes the steps for configuring a virtual machine to run Kite example code on a Cloudera Quickstart VM.

### Result
Your VM is ready for you to run sample programs from the Kite SDK Examples project.

## Installing the VM and Kite Examples

Install an Oracle VirtualBox or VMWare Fusion [Cloudera QuickStart VM][getvm] version 5.2 or later.

Before you launch the VM, decide whether to use Cloudera Manager. If you choose to use Cloudera Manager, you'll need to allocate additional memory and processing resources to your VM. The advantages of using Cloudera Manager are that it provides a visual interface for monitoring the health of your system, it configures by default most of the settings for using Kite examples, and it makes it easier for you to perform additional optional configurations.

### Configuring the VM for Cloudera Manager

If you use Cloudera Manager, you must increase the VM memory allocation and the number of CPUs.

#### Adding Memory and CPUs in a VirtualBox VM

1. In VirtualBox Manager, select your VM instance and click __Settings__.
1. Select the __System__ tab.
1. On the __Motherboard__ page, set the __Base Memory__ slider to _8192 MB_.
1. Click the __Processor__ page tab.
1. Set the __Processor(s)__ slider to _2_.
1. Click __OK__.

#### Adding Memory and CPUs in a VMware Fusion VM

1. From the VMware Fusion menu bar, select __Window > Virtual Machine Library__.
1. Select your virtual machine and click __Settings__.
1. In the __Settings__ window, in the __System Settings__ section, select __Processors & Memory__.
1. Set the amount of memory to allocate to the VM to _8192 MB_ using the slider control.
1. Expand __Advanced Options__, and set the number of CPUs to _2_.
1. Click __OK__.

### Downloading Resources to the VM

1. Start your VM.
1. In the VM, run the following command from a terminal window. This command clones a local copy of Kite code examples you can build and run.

     ```bash
     git clone https://github.com/kite-sdk/kite-examples.git
     ```

1. Install the [Kite CLI][install-cli] command.

[getvm]: http://www.cloudera.com/content/support/en/downloads/quickstart_vms.html
[install-cli]:{{site.baseurl}}/Install-Kite.html

## Configuring the VM

Some Kite examples require Flume. To write to your dataset, Flume impersonates the dataset owner, much like the Unix `sudo` utility. See [Configuring Flume's Security Properties](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Security-Guide/cdh5sg_flume_security_props.html#topic_4_2_1_unique_1).
If you use Cloudera Manager, Flume user impersonation is configured for you. If don't use Cloudera Manager, you must update Flume user impersonation in `core-site.xml`.

### Starting Cloudera Manager

To run Cloudera Manager, double-click the __Launch Cloudera Manager__ icon on the VM desktop. Flume user impersonation is enabled by default.

### Enabling Flume User Impersonation

If choose not to use Cloudera Manager, add the following XML snippet to your `/etc/hadoop/conf/core-site.xml` file.

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
  1. Find the _Virtualization_ settings (usually under _Security_), and enable all virtualization options.

* __How do I get my mouse back?__
  * If your mouse/keyboard is stuck in the VM (captured), you can usually release it by pressing the right `CTRL` key. If you don't have one (or if that didn't work), click the release key in the lower-right corner of the VirtualBox window.

* __Other problems__
  * Using VirtualBox? Try using VMWare.
  * Using VMWare? Try using VirtualBox.

[vbox]: https://www.virtualbox.org/wiki/Downloads