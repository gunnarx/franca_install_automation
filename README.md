Automated Eclipse/Franca environment installation
=================================================

Scripts related to [Franca IDL](https://code.google.com/a/eclipselabs.org/p/franca/) installation.

VM or bare metal?
-----------------

If you are installing on your machine directly, skip to 
"Installation on bare metal"

If you want to create a Virtual Machine read on.

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
                     (This is huge. Also read KNOWN BUGS)

All images are x86 64-bit versions.

There are tags describing franca-version, eclipse-version, and operating
system, as well as *-stable tags

The stable tags are an easy way to get the latest stable, but generally
branches should be kept in working state, and the more specific tags are
also there only if that combination has been tested at least once.

LXDE desktops are lightweight.  Debian build is quick booting and lightweight
but lacks the nicer Virtualbox integration.  Ubuntu with LXDE is also
good and with full integration.

If you prefer, a full Ubuntu desktop is available but 14.04 with Unity is
heavier on resources.  The memory for this VM is set to 2.5GB as opposed to 1.5
on the others.  With that setting it runs alright.  Installation is _much_
slower though.

WARNING: There is a huge amount of packages being installed as part of
ubuntu-desktop, including things like LibreOffice... This flavor takes
a lot of time and bandwidth to initialize and is only recommended if you
really need it.

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
These are from the current/ directory, so these are not guaranteed to be
unchanged.  They will be updated by Ubuntu, and hopefully will not break.
(Note however that the first time you run, you will download the
*current* latest copy, but after that Vagrant caches the base box for
you, so you will not get upstream changes unless you remove it from your
Vagrant setup)

Ubuntu images include Virtualbox guest additions (automatic window
resize etc.) which make the result nice to work with.

The Debian base system is fetched from Puppet Labs with a fixed version
number so presumably the system on this URL will not change, but it is
out of our hands.
This Debian image does not include the Virtualbox integration for
desktop/window resize, etc. (but the  shared folder functionality
apparently works, since it is required for Vagrant to work).


Instructions for Virtual Machine creation
-----------------------------------------

1. Install Vagrant. For example (for Debian or Ubuntu): 
   ```bash
   $ sudo apt-get install vagrant
   ```
   or (for Fedora):
   ```bash
   $ sudo yum install vagrant
   ```
   Alternatively, download and install files from http://www.vagrantup.com/

2. Install VirtualBox. For example (for Debian or Ubuntu): 
   ```bash
   $ sudo apt-get install virtualbox
   ```
   Alternatively, download and install files from http://www.virtualbox.org/

3. Run `vagrant up`: 

   NOTE: I ran into a strange bug where a new machine claimed to be
   provisioned already (this should not happen...) but for that reason we
   can always give the explicit `--provision` flag.  It shouldn't be
   necessary, but it works so do it:
   ```bash
   $ vagrant up --provision
   ```

   The first time it will download the VM "base box" system from the URL.
   The base box is cached in your vagrant environment. (~/.vagrant
   currently)

   Feel free to add an alternative box of another distro, but the
   provisioning code that uses apt-get might need changes then.  Pull
   requests welcome.

   NOTE: There will be some errors towards the end of the provisioning
   which seem to be due to vagrant provisioning not running in a normal
   interactive shell. You can ignore those errors.  Of course you may have
   some other error that I have not seen yet, but using vagrant and a known
   base box this should be quite foolproof.

4. After provisioning, stop the VM which is now running headless.
   Update: Actually the gui=true flag is now in Vagrantfile.  Nonetheless,
   rebooting is recommended at this stage:

   ```bash
    $ vagrant halt
   ```

5. Then locate your VM in VirtualBox GUI and boot it normally

   You should soon see an graphical shell asking you to select user.

   Login as `vagrant`, password `vagrant`

6. Enjoy testing Franca environment!

   Use the default workspace directory at `/home/vagrant/workspace`.
   Just hit OK.

7. To run Franca examples you must manually import them into the workspace.

   The instructions can be found towards the end of `script.sh`.


Tweaking settings
------------------

   The VM is configured with 1.5 GB RAM (2.5 GB for Unity).  You may want to
   modify that setting in Vagrantfile or change the VM settings manually in
   VirtualBox if you are doing large builds.  I am not sure what is required
   except that 512MB was not enough, and 1.5GB worked for running Franca tests.

Sharing files
-------------

NOTE: In a Vagrant box you can share files through the /vagrant directory:

* On host: It is this directory, where you have Vagrantfile and this README.
* On Virtual Machine: Mounted at /vagrant

You can also get a direct command line on the VM using `vagrant ssh`, but
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

This means JDK 7 as of now, but refer to official Franca documentation for
up to date information.  Install package java-1.7.0-openjdk on fedora or
openjdk-7-jre on Ubuntu or Debian.  (The vagrant script does this
automatically)

The script downloads and installs Eclipse.  If you have an Eclipse environment
already that you want to use, you probably need to instead follow a manual
procedure using Franca documentation to get Franca into your environment.

Known bugs
----------

1. Franca 0.9.2 includes a bug that prevents the opening the Wizard for
creating a new Franca file.  For example by using "File->New Franca
Interface"

Workaround: Choose "File->New" instead and manually give it a .fidl suffix.  
Proceed editing as usual.

At first I thought it was a problem with this installation but it
is a bug in Franca tooling and tracked here:
http://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=149

2. There is an odd bug for Unity/Ubuntu Desktop only that causes the Eclipse menus to
not display at all. It seems to happen on the first boot after installation
(and never again!) It affects also the HUD.  Simply closing and restarting
Eclipse seems to solve the problem.  If you find any additional information,
please feed it back.



