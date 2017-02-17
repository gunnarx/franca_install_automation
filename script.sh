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

install MWE

install MDT_OCL

install EMF_VALIDATION

install EMF_TRANSACTION

install GMF_NOTATION

install GMF_RUNTIME

install XTEND

install XPAND

section "Installing: SPHINX (archive file)"
step "Downloading Sphinx update site archive (.zip)"
download "$SPHINX_ARCHIVE_URL" "$SPHINX_ARCHIVE_MD5"
unpack_site_archive SPHINX "$downloaded_file"

# It's not very nice - whoever set up the creation of zip-file for sphinx
# from their CI system did not use a sane root for the archive, so this
# huge ugly path is inside the zip...
# So let's first move the content out of there...
cd "$UNPACK_DIR"
mv home/hudson/genie.sphinx/.hudson/jobs/sphinx-0.9-mars-publish/workspace/releng/org.eclipse.sphinx.releng.builds/updates/* . || die "path fix for zipfile failed -- has it changed in the archive? - please check script for details"
rm -r home || die "some weird non-writable file can't be deleted?"

SPHINX_UPDATE_SITE_URL="file://$UNPACK_DIR"
step "Installing Sphinx"
_install_update_site SPHINX
rm -rf "$UNPACK_DIR"

# TBD - Orbit not yet required (have not reached this dependency yet?)
#step "Installing ICU4J/Orbit"
#install_online_update_site       ORBIT

# Not sure really why I still do this check... It's legacy :)
step "Preliminary check DBus EMF model on update site"
check_site_hash            DBUS_EMF
check_site_latest_version  DBUS_EMF

install DBUS_EMF

install KRENDERING

install FRANCA

# ARTOP needs special download with login, therefore the user is required
# to provide the site archive locally.  We will ask for it here.
install_local_file ARTOP

install IONAS

. download_franca_examples.sh

cat <<MSG

Instructions for IONAS
----------------------

Unpack the package from AUTOSAR "CONC_610_...IntegrationOfNonARSystems" separately.
To import relevant files into Workspace, go to the Workspace, then select

Instructions:
-------------

*** THE EXAMPLES ARE TEMPORARILY NOT INCLUDED BECAUSE OF 404 URL
*** REFER TO https://github.com/franca for information and download
*** them and place them in the workspace _directory_
*** them and place them in the workspace _directory.

The examples are now in your workspace _directory_ but not yet known to your
project browser.  When you have started eclipse, go to Workspace, then select
   File -> Import...
   Expand the "General" category (folder)
      and then "Existing Projects into Workspace".  Press Next.
   Enable the check box "Copy Project into Workspace"
   Select the directory "Test" from the unpacked AUTOSAR archive and hit OK.
   Hit Finish to import/copy into workspace.

At the moment, i don't know any more instructions for ionas usage, sorry.
MSG

echo
echo "All Done. You may now start eclipse by running: $ECLIPSE_INSTALL_DIR/eclipse/eclipse"

cd "$MYDIR"
. ./check_java_version.sh

cd "$ORIGDIR"

