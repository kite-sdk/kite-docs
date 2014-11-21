---
layout: page
title: Kite Examples Setup
--- 

Use these instructions to install and configure a virtual machine (VM) on which you can run examples of Kite programs.

## Getting Started

The easiest way to run the examples is on the
[Cloudera QuickStart VM](http://www.cloudera.com/content/support/en/downloads/quickstart_vms.html). The QuickStart VM has all of the necessary Hadoop services pre-installed, configured, and running locally. 

The current examples run on version 5.1.0 or later of the QuickStart VM.

## Setting up the QuickStart VM

There are two ways to run the examples with the QuickStart VM:

1. Logged in to the VM Admin account (username and password are both `cloudera`).
2. Logged in from your host computer.

The advantage of working in the VM is that you don't need to install anything extra on
your host computer, such as Java or Maven.

### Configuring a VirtualBox VM

Before starting a VirtualBox VM, follow these setup steps (you can't make these changes while the VM is running).

1. Download and expand the compressed VM files.
1. Open VirtualBox Manager.
1. Choose __File->Import Appliance...__
1. Browse to the expanded VM folder and open the `.ovf` file.
1. Click __Continue__.
1. Optionally change the name of the VM to something meaningful to your project.
1. Change the number of CPUs to 2.
1. Increase the RAM to 8192MB.
1. Click __Import__.
1. If you are going to access the CDH cluster inside the VM, you can now start and work with the VM.

  *  Open a terminal window in the VM and clone the latest branch of the kite-examples repository:

```
git clone git://github.com/kite-sdk/kite-examples.git
cd kite-examples
```
  * Choose the example you want to try and follow the README instructions in the example subdirectory.

Accessing the CDH cluster in the VM from your host computer requires additional setup, described in [Configuring the CDH Cluster on the VM to Work with the Host Machine](#host).

<a name="host" />

## Configuring the CDH Cluster on the VM to Work with the Host Machine

To work with the CDH cluster from the host machine, you need to perform additional configurations to enable two-way communications.

### Configure Port Forwarding

* If you are using VirtualBox, before you start the VM, configure port forwarding for YARN and MapReduce. (These settings are already set for you in the 5.2 VM):

  1. Open the __Settings__ dialog for the VM.
  1. Select the __Network__ tab.
  1. Expand the __Advanced__ settings.
  1. Click __Port Forwarding__.
  1. Click the __Insert New Rule__ icon.
  1. Set the Name, Host Port, and Guest Port to `8032`. (This port is used by the YARN ResourceManager.)
  1. Click the __Insert New Rule__ icon.
  1. In the new rule, set the Name, Host Port, and Guest Port to `10020`. (This port is used by the MapReduce JobHistoryServer.)

If you have VBoxManage installed on your host machine, you can set port forwarding using the command line instead. In bash, use the following command:

```
# Set VM_NAME to the name of your VM as it appears in VirtualBox
VM_NAME="QuickStart VM"
PORTS="8032 10020"
for port in $PORTS; do
  VBoxManage modifyvm "$VM_NAME" --natpf1 "Rule $port,tcp,,$port,,$port"
done
```

### Launch the VM and Synchronize the System Clock

* Start the VM.

* __Sync the system clock__ For some of the examples it's important that the host and
guest times are in sync. If the time displayed on the VM's tool bar is different than the time displayed on your host computer, synchronize the VM clock. From a terminal command line running in the VM, enter the command `sudo ntpdate pool.ntp.org`.

### Configure Listeners

* __Configure the NameNode to listen on all interfaces__ Set the `dfs.namenode.rpc-bind-host` property in `/etc/hadoop/conf/hdfs-site.xml`:

```xml
  <property>
    <name>dfs.namenode.rpc-bind-host</name>
    <value>0.0.0.0</value>
  </property>
```

* __Configure the History Server to listen on all interfaces__ Set the `mapreduce.jobhistory.address` property in `/etc/hadoop/conf/mapred-site.xml`:

```xml
  <property>
    <name>mapreduce.jobhistory.address</name>
    <value>0.0.0.0:10020</value>
  </property>
```

* __Configure HBase to listen on all interfaces__ Set the `hbase.master.ipc.address` and `hbase.regionserver.ipc.address`
properties in `/etc/hbase/conf/hbase-site.xml`:

```xml
  <property>
    <name>hbase.master.ipc.address</name>
    <value>0.0.0.0</value>
  </property>

  <property>
    <name>hbase.regionserver.ipc.address</name>
    <value>0.0.0.0</value>
  </property>
```

* __Add a host entry for quickstart.cloudera__ Add or edit the following line
in `/etc/hosts` on the host machine
```
127.0.0.1       localhost.localdomain   localhost       quickstart.cloudera
```

### Restart the VM

* __Restart the VM__ from a command line terminal using `sudo shutdown -r now`

* __Check out the latest [branch](https://github.com/kite-sdk/kite-examples/branches)__ of the kite-examples repository in the VM:

```
git clone git://github.com/kite-sdk/kite-examples.git
cd kite-examples
```

* __Choose the example__ you want to try and refer to the README in the relevant subdirectory.

## Troubleshooting the VM

* __What are the usernames/passwords for the VM?__
  * Cloudera manager: cloudera/cloudera
  * HUE: cloudera/cloudera
  * Login: cloudera/cloudera

* __I can't find the file in VirtualBox (or VMWare)!__
  * You probably need to unpack it: In Windows, install 7zip, and _extract_ the
    VM files from the `.7z` file. In linux or mac, `cd` to where you copied the
    file and run `7zr e cloudera-quickstart-vm-4.3.0-kite-vbox-4.4.0.7z`
  * You should be able to import the extracted files to VirtualBox or VMWare

* __How do I open a `.ovf` file?__
  * Install and open [VirtualBox][vbox] on your computer
  * Under the menu "File", select "Import..."
  * Navigate to where you unpacked the `.ovf` file and select it

* __What is a `.vmdk` file?__
  * The `.vmdk` file is the VM disk image that accompanies a
    `.ovf` file, which is a portable VM description.

* __How do I open a `.vbox` file?__
  * Install and open [VirtualBox][vbox] on your computer
  * Under the menu "Machine", select "Add..."
  * Navigate to where you unpacked the `.vbox` file and select it

* __How do I fix "VTx" errors?__
  * Reboot your computer and enter BIOS
  * Find the "Virtualization" settings, usually under "Security" and _enable_
    all of the virtualization options

* __How do I get my mouse back?__
  * If your mouse/keyboard is stuck in the VM (captured), you can usually
    release it by pressing the right `CTRL` key. If you don't have one (or that
    didn't work), then the release key will be in the __lower-right__ of the
    VirtualBox window

* __Other problems__
  * Using VirtualBox? Try using VMWare.
  * Using VMWare? Try using VirtualBox.

[vbox]: https://www.virtualbox.org/wiki/Downloads
