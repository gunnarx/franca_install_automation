Automated Eclipse/Franca environment installation
=================================================

Scripts related to Franca IDL installation

VM or bare metal?
-----------------

If you are installing on your machine directly, skip to the end!

If you want to create a Virtual Machine read on:

A note on branches (for VM)
---------------------------

Before you create the VM there is a choice to make and that is which flavour
(distro) to use.  The git repository has a number of branches with minor
differences in the code but leading to quite big differences in the VM
(different distros and graphical environments).

If you just want to go ahead and do a quick test, choose precise64-lxde
(or simply master branch) and skip to the next chapter.

### Branches / flavors:

* precise64-lxde  -- Ubuntu Precise Pangolin 12.04 LTS, with LXDE desktop
* trusty64-lxde   -- Ubuntu Trusty Tahr 14.04 LTS, with LXDE desktop
* debian_7.3-lxde -- Debian 7.3, with LXDE desktop
* trusty64-unity  -- Ubuntu Trusty Tahr 14.04 LTS, with standard Ubuntu (Unity) desktop
                     (read KNOWN BUGS)

All images are x86 64-bit versions.

LXDE desktops are lightweight.  Debian build is quick booting and lightweight
but lacks the nicer Virtualbox integration.  Ubuntu with LXDE is also
good and with full integration.

If you prefer, a full Ubuntu desktop is available but 14.04 with Unity is
heavier on resources.  The memory for this VM is set to 2.5G as opposed to
1.5 on the others.  With that setting it runs OK.  Installation is _much_
slower though.  There is a huge amount of packages being installed as part
of ubuntu-desktop, including things like LibreOffice...

Better measurements would be nice but here follows the approximate _compressed_
sizes I could measure.  I did not at this time check the actual install size,
just a quick check of a gzipped version of the hdd image.

Note that this depends not only on the distro but more on how the provided
"base box" has been installed.  The base boxes can surely be optimized if
desired.

Gzipped hard disk image size:

* 1.3G  debian_7.3-lxde
* 886M  precise64-lxde
* 853M  trusty64-lxde
* 1.9G  trusty64-unity

### Sources:

The Ubuntu base systems are from Ubuntu's provided official "cloud" images.
They are from the current/ directory, so they will be updated, but hopefully
will not break.

(Note however that the first time you run, you will download the
currently latest copy but after that Vagrant caches the base system,
so it will not be changed unless you remove it from your Vagrant setup)

- Ubuntu images include Virtualbox guest additions

The Debian base system is fetched from Puppet Labs with a fixed version.
Presumably the system on this URL will not change.

- Debian image does not include the Virtualbox guest additions (i.e. no
automatic window resize.)  (But the  shared folder functionality
apparently works, it needs to work for Vagrant).


Instructions for Virtual Machine creation
-----------------------------------------

1. Get Vagrant, for example:

```bash
    $ sudo apt-get install vagrant
```
or
```bash
    $ sudo yum install vagrant
```

2. Install the latest VirtualBox

3. Run Vagrant up: 

NOTE: I ran into a new bug where a new machine claims to be provisioned already
(it can't be...) but for that reason we give the explicit --provision flag.  It
works.

```bash
    $ vagrant up --provision
```

   The first time it will download the base VM "box" which
   is currently an Ubuntu system.

   Feel free to replace it with another box of another distro, but the
   provisioning using apt-get may need changes then.  Pull requests
   welcome.

   NOTE: There will be some errors towards the end of the provisioning which
   seems to be due to vagrant provisioning not running in a normal interactive
   shell?

   You can ignore those errors.  Of course you may have some other error that I
   have not seen yet, but using vagrant and a known base box this should be
   quite foolproof.

4. Stop the VM which is now running headless:

```bash
    $ vagrant halt
```

5. Locate your VM in VirtualBox GUI and boot it normally (i.e. not headless)

   You should soon see an LXDE graphical shell asking you to select user.

   Login as vagrant, password vagrant

6. Enjoy testing Franca environment!

   Use the default workspace dir at /home/vagrant/workspace.  Just hit OK.

7. To run Franca examples you must manually import them into the
   workspace. The instructions can be found towards the end of script.sh


Tweaking settings
------------------

   The VM is configured with 1.5 GB RAM (2.5 for Unity).  You may want to
   modify that setting in Vagrantfile or change the VM settings manually in
   VirtualBox if you are doing large builds.  I am not sure what is required
   except that 512MB was not enough, and 1.5G worked for running Franca tests.

Sharing files
-------------

Note, in a Vagrant box you can share files through the /vagrant directory:
On host: it's this directory, where you have Vagrantfile and this README.
On Virtual Machine:   Mounted at /vagrant

You can also get a direct command line on the VM using vagrant ssh, but
that's not too useful for running Eclipse:

```bash
    $ vagrant ssh
```

Read Vagrant documentation to learn more: http://www.vagrantup.com/

Installation on bare metal
--------------------------

You may use ./script.sh (and CONFIG) directly on any machine (VM or
bare metal) without using Vagrant, to simply automate the Franca installation.

1. Edit CONFIG if needed.
2. Run script:

```bash
    $ ./script.sh
```

script.sh does not use any package manager so it should run on most distros. It
is developed on Fedora 20 but tested also on Ubuntu and Debian (using the
Vagrant method)

Prerequisites
-------------

script.sh does not install any packages except for Eclipse + Java packages so
for the non-Vagrant installation you need to manually install the needed
prerequisites on your machine.

This means primarily JDK 6.  Install package java-1.6.0-openjdk on fedora or
openjdk-6-jre on Ubuntu or Debian.  Note that JDK 6, not 7 (or 8) was up until
recently required, but refer to official Franca documentation for up to date
information.

The script downloads and installs Eclipse.  If you have an Eclipse environment
already that you want to use, you probably need to instead follow a manual
procedure using Franca documentation to get Franca into your environment.

Known bugs
----------

There is an odd bug for Unity/Ubuntu Desktop only that causes the Eclipse menus to
not display at all. It seems to happen on the first boot after installation
(and never again!) It affects also the HUD.  Simply closing and restarting
Eclipse seems to solve the problem.  If you find any additional information,
please feed it back.

