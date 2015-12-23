#!/bin/bash
# (C) 2014 Gunnar Andersson
# License: CC-BY 4.0 Intl. (http://creativecommons.org/licenses/by/4.0/)
# Git repository: https://github.com/gunnarx/franca_install_automation
# pull requests welcome

# --------------------------------------------------------------------------
# ECLIPSE INSTALLATION PART
# --------------------------------------------------------------------------

# Support 32 or 64 bit choice automatically
OSTYPE=$(uname -o)
MACHINE=$(uname -m)

# Check that a few necessary variables are defined
defined ECLIPSE_INSTALLER_$MACHINE ECLIPSE_INSTALL_DIR DOWNLOAD_DIR DBUS_EMF_UPDATE_SITE_URL FRANCA_ARCHIVE_URL KRENDERING_SITE_URL

# If running in Vagrant, override the download dir defined in CONFIG
if_vagrant DOWNLOAD_DIR=/vagrant

# Create installation and workspace dirs
if [ -d "$ECLIPSE_INSTALL_DIR/eclipse" ] ; then
   if [ -z "$VAGRANT" ] ; then  # No need to warn in vagrant case
      echo
      echo "NOTE the eclipse installation dir exists ($ECLIPSE_INSTALL_DIR/eclipse)!"
      echo "It is usually not a problem but to make a clean install you may want to remove it"
      warn "Remove installation dir if you want to make a clean install."
   fi
fi

mkdir -p "$ECLIPSE_INSTALL_DIR" || die "Can't create target dir ($ECLIPSE_INSTALL_DIR)"

if [ -d "$ECLIPSE_WORKSPACE_DIR" ] ; then
   if [ -z "$VAGRANT" ] ; then  # No need to warn in vagrant case
      echo
      echo "NOTE the workspace dir in CONFIG exists ($ECLIPSE_WORKSPACE_DIR)!"
      echo "I will unpack a few example files into $ECLIPSE_WORKSPACE_DIR !"
      warn "If your workspace content is important you may want to back up your files!"
   fi
fi

mkdir -p "$ECLIPSE_WORKSPACE_DIR" || die "Fail creating $ECLIPSE_WORKSPACE_DIR"

if [ "$OSTYPE" = "GNU/Linux" -a "$MACHINE" = "i686" ]; then
    ECLIPSE_INSTALLER=$ECLIPSE_INSTALLER_i686
elif [ "$OSTYPE" = "GNU/Linux" -a "$MACHINE" = "x86_64" ]; then
    ECLIPSE_INSTALLER=$ECLIPSE_INSTALLER_x86_64
elif [ "$OSTYPE" = "???" -a "$MACHINE" = "???" ]; then
    # TODO: Handle case (MacOSX, etc.)
    #ECLIPSE_INSTALLER=???
    #ECLIPSE_MD5=???
    :
else
    die "ERROR: Unknown (OSTYPE=$OSTYPE, MACHINE=$MACHINE)"
fi

# Get Eclipse archive
section "Installing: Eclipse"
cd "$DOWNLOAD_DIR"
step "Downloading Eclipse installer"
download "$ECLIPSE_INSTALLER" $(deref ECLIPSE_MD5_$MACHINE) # This sets a variable named $downloaded_file

# Downloaded? - check MD5 and then unpack
[ -f "$downloaded_file" ] || die "ECLIPSE not found (not downloaded?)."
md5_check ECLIPSE "$downloaded_file" $MACHINE
step "Unpacking Eclipse to $ECLIPSE_INSTALL_DIR"
untar "$downloaded_file" "$ECLIPSE_INSTALL_DIR" || die


