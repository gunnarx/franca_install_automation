#!/bin/bash
# (C) 2014 Gunnar Andersson
# License: MPLv2 - see project dir.
# Git repository: https://github.com/gunnarx/franca_install_automation
# pull requests welcome

# Set to "true" for debug printouts
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

# Absolute path - assume everything is relative to "$MYDIR"
# There are some potential bugs here... - hopefully it works
# using Plan B.  Probably there are better ways than this hack.
absolute_path() { 
  olddir="$PWD"
  cd "$MYDIR"
  # Readlink should handle relative and absolute paths.
  x=$(readlink -f "$1")       #... but fails for example for dir/file if dir does not exist!
  [ -z "$x" ] && x="$PWD/$1"  # Plan B - if it was a relative path but readlink failed...
  echo "$x"
  cd "$olddir"
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

# FIXME: this can be cleaned up.  Quick fix is to make dirs here
# whether they are relative or not...
mkdir -p "$ECLIPSE_INSTALL_DIR"
mkdir -p "$ECLIPSE_WORKSPACE_DIR"

# Just in case, adjust directories to absolute if defined as relative
ECLIPSE_INSTALL_DIR=$(absolute_path "$ECLIPSE_INSTALL_DIR")
ECLIPSE_WORKSPACE_DIR=$(absolute_path "$ECLIPSE_WORKSPACE_DIR")
DOWNLOAD_DIR=$(absolute_path "$DOWNLOAD_DIR")

# Install eclipse (shared)
. ./install_eclipse.sh

# --------------------------------------------------------------------------
# PACKAGE INSTALLATION (varies between installed variant / git branches)
# --------------------------------------------------------------------------

install DBUS_EMF

install KRENDERING

install FRANCA

. ./download_franca_examples.sh

cat <<MSG

Instructions:
-------------

The examples are now in your workspace _directory_ inside franca/examples but
not yet known to your project browser.  When you have started eclipse, go to
Workspace, then select
   File -> Import...
   Expand the "General" category (folder)
      and then "Existing Projects into Workspace".  Press Next.
   Select option "Select root directory" and press "Browse..." Go into the franca
   directory inside workspace dir and select the "examples" directory.  Press
   OK. 5 projects should be listed and you can import all of them by copy, or
   reference.

   Finally you may now run the tests by:

   Go into "org.franca.examples.basic" package
   under /src, open "org.franca.examples.basic.tests"

   Right click on for example AllTests.java and select Run As "JUnit Test".
   You should get a green bar result* and some generated code on the console. 
   *If the JUnit window becomes hidden, find it again.

   But from now on you should instead read the Franca documentation for up
   to date instructions on this stuff.
MSG

echo
echo "All Done. You may now start eclipse by running: $ECLIPSE_INSTALL_DIR/eclipse/eclipse"

cd "$MYDIR"
. ./check_java_version.sh

cd "$ORIGDIR"

