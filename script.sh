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

# Helper functions (shared)
. functions.sh

# Include config
[ -f ./CONFIG ] || die "CONFIG file missing?"
. ./CONFIG      || die "Failure when sourcing CONFIG"

# Install eclipse (shared)
. install_eclipse.sh

cd "$MYDIR"

# --------------------------------------------------------------------------
# PACKAGE INSTALLATION (varies between installed variant / git branches)
# --------------------------------------------------------------------------

install_online_update_site MWE

install_site_archive       MDT_OCL

install_site_archive       EMF_VALIDATION

install_site_archive       EMF_TRANSACTION

install_site_archive       GMF_NOTATION

install_site_archive       GMF_RUNTIME

install_online_update_site XTEND

install_site_archive       XPAND

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

install_online_update_site DBUS_EMF

install_online_update_site KRENDERING

install_site_archive       FRANCA

# ARTOP needs special download with login, therefore the user is required
# to provide the site archive locally.  We will ask for it here.
install_local_file         ARTOP

install_online_update_site IONAS

. download_franca_examples.sh

cat <<MSG

Instructions for IONAS
----------------------

Unpack the package from AUTOSAR "CONC_610_...IntegrationOfNonARSystems" separately.
To import relevant files into Workspace, go to the Workspace, then select
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

. check_java_version.sh

cd "$ORIGDIR"

