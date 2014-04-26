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

   Branches / flavors:
   -------------------

   precise64-lxde  -- Ubuntu Precise Pangolin 12.04 LTS, with LXDE desktop
   trusty64-lxde   -- Ubuntu Trusty Tahr 14.04 LTS, with LXDE desktop
   debian_7.3-lxde -- Debian 7.3, with LXDE desktop
   trusty64-unity  -- Ubuntu Trusty Tahr 14.04 LTS, with standard Ubuntu (Unity) desktop

   All images are 64 bit versions.

   LXDE desktops are lightweight.  Debian build is very quick booting and
   lightweight but lacks the nicer Virtualbox integration.  Ubuntu with LXDE
   is almost as good.

   If you prefer, the full Ubuntu desktop is available but 14.04 with Unity is
   much heavier on resources and it runs noticeably slower so I would recommend
   LXDE for good performance in a VM.

   Sources:

   The Ubuntu base systems are from Ubuntu's provided official "cloud" images.
   They are from the current/ directory, so they will be updated, but hopefully
   will not break.
      (Note however that the first time you run, you will download the
       currently latest copy but after that Vagrant caches the base system,
       so it will not be changed unless you remove it from your Vagrant setup)

      - Ubuntu images includes Virtualbox guest additions

   The Debian base system is fetched from Puppet Labs with a fixed version.
   Presumably it does not change.

      - This image does not include Virtualbox guest additions (i.e. no automatic window resize etc.)


Instructions for Virtual Machine creation
-----------------------------------------

1. Get Vagrant

   for example:
   $ sudo apt-get install vagrant
    or
   $ sudo yum install vagrant

2. Install the latest VirtualBox

3. Run Vagrant up:

   $ vagrant up

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

   $ vagrant halt

5. Locate your VM in VirtualBox GUI and boot it normally (i.e. not headless)

   You should see an LXDE graphical shell asking you to select user.

   Login as vagrant, password vagrant

6. Enjoy testing Franca environment!

   Note: The workspace is prepared at /home/vagrant/workspace,
   but this is also eclipse default, so just hit OK

7. To run Franca examples you must manually import them into the
   workspace. The instructions can be found towards the end of script.sh


Tweaking settings
------------------

   The VM is configured with 1.5 GB RAM.  You may want to modify that setting
   in Vagrantfile or change the VM settings manually in VirtualBox if you are
   doing large builds.  I am not sure what is required except that 512MB was
   not enough, and 1.5G worked fine for running Franca tests.

Sharing files
-------------

   Note, in a Vagrant box you can share files through the /vagrant directory:
   On host: it's THIS directory, where you have Vagrantfile and this README
   On Virtual Machine:   Mounted at /vagrant

   You can also get a direct command line on the VM using vagrant ssh, but
   that's not too useful for running eclipse:

   $ vagrant ssh

   Read Vagrant documentation to learn more: http://www.vagrantup.com/

Installation on bare metal
--------------------------

You may use ./script.sh (and CONFIG) directly on any machine (VM or
bare metal) without using Vagrant, to simply automate the Franca installation.
Make sure to modify the install location and workspace name in CONFIG to your
liking.

Edit CONFIG if needed.
and run:
$ ./script.sh

script.sh does not use any package manager so it should run on most distros. It
is developed on Fedora 20 but tested also on Ubuntu and Debian (using the
Vagrant method)

script.sh does not install any packages except for Eclipse + libraries so you
need to manually ensure the needed prerequisites.  Mostly this means JDK 6
however.  Install for example java-1.6.0-openjdk on fedora or openjdk-6-jre on
Ubuntu or Debian.  Note that JDK 6, not 7 (or 8) was up until recently required
(but refer to official Franca documentation for up to date information).

The script downloads and installs Eclipse.  If you have an Eclipse environment
already, you probably need to instead follow a manual procedure using Franca
documentation to get Franca into your "standard" Eclipse.

