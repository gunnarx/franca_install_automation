#!/bin/bash
# (C) 2014 Gunnar Andersson
# License: CC-BY 4.0 Intl. (http://creativecommons.org/licenses/by/4.0/)
# Git repository: https://github.com/gunnarx/franca_install_automation
# pull requests welcome

# Set to "false" or "true" for debug printouts
DEBUG=false

echo "***************************************************************"
echo " script.sh starting"
echo "***************************************************************"

# This function sets variable $VAGRANT if we are running under vagrant provisioning
test_vagrant() {
   VAGRANT=""
   echo "$0" | fgrep -q "vagrant-shell" && VAGRANT="yes"
}

# Run command only if Vagrant environment
if_vagrant() {
   [ -n "$VAGRANT" ] && eval $@
}


# Set up some variables
ORIGDIR="$PWD"
D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

# Special case for vagrant: We know the script is in /vagrant
# $0 is in that case the name of the shell instead of the name of the script
test_vagrant
if_vagrant echo Using vagrant : $0
if_vagrant MYDIR=/vagrant

cd "$MYDIR"

# Helper functions (shared)
. ./functions.sh

# Include config
[ -f ./CONFIG ] || die "CONFIG file missing?"
. ./CONFIG      || die "Failure when sourcing CONFIG"

# If running in Vagrant, override the download dir defined in CONFIG
if_vagrant DOWNLOAD_DIR=/vagrant

# Install eclipse (shared)
. ./install_eclipse.sh

# --------------------------------------------------------------------------
# PACKAGE INSTALLATION (varies between installed variant / git branches)
# --------------------------------------------------------------------------

install DBUS_EMF

install FRANCA

install CDT

install COMMON_API_CPP

. download_franca_examples.sh

cat <<MSG

Instructions:
-------------
The examples are now in your workspace _directory_ but not yet known to your
project browser.  When you have started eclipse, go to Workspace, then select
   File -> Import...
   Expand the "General" category (folder)
      and then "Existing Projects into Workspace".  Press Next.
   Select option "Select Archive File" and press "Browse..."
   Select the .zip file containing $EXAMPLES_FILE and hit OK.
   Hit Finish to import/copy into workspace.

   Finally you may now run tests by going into
   "org.franca.examples.basic" package
   under /src, open "org.franca.examples.basic.tests"

   Right click on for example AllTests.java
   and select Run As "JUnit Test".  You should get a green bar result.

   But from now on you should instead read the Franca documentation for up
   to date instructions on this stuff.
MSG

echo
echo "All Done. You may now start eclipse by running: $ECLIPSE_INSTALL_DIR/eclipse/eclipse"

cd "$MYDIR"
. ./check_java_version.sh

cd "$ORIGDIR"
