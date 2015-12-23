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

# Not sure really why I still do this check... It's legacy :)
step "Preliminary check DBus EMF model on update site"
check_site_hash            DBUS_EMF
check_site_latest_version  DBUS_EMF

install DBUS_EMF

install KRENDERING

install FRANCA

. download_examples.sh

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

. check_java_version.sh

cd "$ORIGDIR"

