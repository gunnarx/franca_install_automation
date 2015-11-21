#!/bin/sh
# (C) Gunnar Andersson
# License: CC-BY 4.0 International
# (http://creativecommons.org/licenses/by/4.0/)
# pull requests welcome

# Set to "false" or "true" for debug printouts
DEBUG=false

debug() {
   $DEBUG && {
      1>&2 echo $@ | sed 's/^/*DEBUG*: /'
   }
}

die() {
   echo "Something went wrong.  Message: "
   echo "$1"
   exit 1
}

# This function sets variable $VAGRANT if we are running under vagrant provisioning
test_vagrant() {
   VAGRANT=""
   echo "$0" | fgrep -q "vagrant-shell" && VAGRANT="yes"
}

# Run command only if Vagrant environment
if_vagrant() {
   [ -n "$VAGRANT" ] && eval $@
}

# Run command only if NOT Vagrant environment
unless_vagrant() {
   [ -z "$VAGRANT" ] && $@
}

# Print an operation with *** in front of it
step() {
      echo $@ | sed 's/^/ *** /'
}

# Check condition is met or die
ensure() {
   $* || die "Condition not met: $*"
}

# Check that variable(s) have been defined
defined() {
   for v in $* ; do
      [ -n "$v" ] || "Variable $v not defined in CONFIG?"
   done
}

# Print a warning and pause 
# (it will not pause in Vagrant provisioning because there is no terminal)
warn() {
   echo "WARNING: $1"
   echo Hit return to continue
   unless_vagrant read
}

# This is kind of useless...
sanity_check_filename() {
   [ -z "$1" ] && die "Filename empty."
}

# dereference variable

# This is a kind of weird hack, but it evaluates the variable whose name is
# defined by the input variable.  
# example:   x=foo ; deref x, returns the value of $foo!
deref() {
   debug "dereffing $1"
   eval echo \$$1
}

download() {
   outfile=$(basename "$1")
   sanity_check_filename "$outfile"
   if [ -x "$(which curl 2>&1)" ] ; then
      # REMOVED the continuation because on file length unknown curl croaks...
      # TODO: Insert file/md5 check instead
      curl --location --progress-bar "$1" -o "$outfile" | tr '#' '.' || die "curl failed.  Is curl installed?"
   elif [ -x "$(which wget 2>&1)" ] ; then
      wget "$1" -O "$outfile" -c --no-check-certificate || die "wget failed.  Is wget installed?"
   else
      die "Download failed, can't find either curl or wget installed(?)"
   fi
   downloaded_file=$outfile
}

untar() {
   ensure [ -f "$1" ]
   targetdir="$2"
   # Use current directory as default targetdir if not specified
   [ -n "$targetdir" ] && targetdir=.
   tar xf "$1" -C "$2" || die "untar failed for $1"
}

md5_check() {
   item=$1
   file=$2
   arch=$3

   if [ -n "$arch" ] ; then
      wanted_md5=$(deref ${item}_MD5_${arch})
   else
      wanted_md5=$(deref ${item}_MD5)
   fi

   debug "Checking MD5 $wanted_md5 for $item"

   # As long as <item>_MD5 is a non-empty string, perform the check
   if [ -n "$wanted_md5" ] ; then
      md5=$(md5sum <"$file" | cut -b 1-32)
      if [ "$md5" != "$wanted_md5" ]  ; then
         die "MD5 checksum ($md5) did not match predefined md5 ($wanted_md5) for item $item.  Check CONFIG file."
      else
         debug "MD5 ok ($item)"
      fi
   fi
}

# Check hash on update site such that an update is noticed
# (warning only)
check_site_hash() {
   url=$(deref ${1}_UPDATE_SERVER)
   hash=$(deref ${1}_UPDATE_SITE_HASH)
   debug "checking update site hash: $hash"
   curl -s "$url/" | grep -q "$hash" || warn "Site hash ($hash) not found on update site.  Probably it has been updated."
}

check_site_latest_version() {
   url=$(deref ${1}_UPDATE_SERVER)
   version=$(deref ${1}_VERSION)
   $DEBUG && {
      echo DEBUG: All versions:
      curl -s "$url/" | egrep '[0-9]\.[0-9]\.[0-9]' | sed 's/^/DEBUG: /'
   }

   latest=$(curl -s "$url/" | egrep '[0-9]\.[0-9]\.[0-9]' | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/' | sort -n | tail -1)
   debug "latest: $latest"
   if [ "$latest" != "$version" ] ; then
      warn "There appears to be a later version than $version for $1"
   fi
}

install_update_site() {
   # http://stackoverflow.com/questions/7163970/how-do-you-automate-the-installation-of-eclipse-plugins-with-command-line
   # http://help.eclipse.org/indigo/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Frunning_eclipse.htm
   # http://help.eclipse.org/helios/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html

   site=$(deref ${1}_UPDATE_SITE_URL)
   features=$(deref ${1}_FEATURES)

   $DEBUG && set -x
   $INSTALL_DIR/eclipse/eclipse -nosplash \
      -application org.eclipse.equinox.p2.director \
      -repository "$site" \
      -destination $INSTALL_DIR/eclipse \
      -installIU "$features"
}

get_local_file() {

   file="$1"
   cd "$MYDIR"

   step "Get $1 software archive locally"
   done=false
   [ -f "./$file" ] && { path="./$file" ; done=true ; }
   while ! $done ; do
      echo "I need the file $file to be provided by you locally."
      echo "Please provide a path to the file (relative to CWD is ok but avoid ~/ \$HOME or similar)"
      echo "You are now in $PWD"
      echo -n "Path: "
      read path
      [ -d "$path" -a -f "$path/$file" ] && path="$path/$file"
      [ -f "$path" ] && done=true
      [ ! -f "$path" ] && { echo "Let's see..." ; ls -l "$path" ; echo "No - try again." ; }
   done

   cp "$path" "$DOWNLOAD_DIR"
   downloaded_file="$file"
   cd - >/dev/null
}

unpack_site_archive() {
   step "Unpacking archive $2 for $1"
   UNPACK_DIR=$DOWNLOAD_DIR/tmp.$$
   mkdir -p "$UNPACK_DIR"            || die "mkdir UNPACK_DIR ($UNPACK_DIR) failed"
   cd "$UNPACK_DIR"                  || die "cd to UNPACK_DIR ($UNPACK_DIR) failed"
   unzip -q "$DOWNLOAD_DIR/$downloaded_file" || die "unzip $DOWNLOAD_DIR/$downloaded_file failed"
   cd - >/dev/null
}

install_site_archive() {
   step "Downloading update site archive (.zip) for $1"
   archive=$(deref ${1}_ARCHIVE)
   url=$(deref ${1}_ARCHIVE_URL)
   download "$url" "$archive"
   md5_check "$1" "$downloaded_file"
   unpack_site_archive "$1" "$downloaded_file"

   step "Installing $1 from local update site (unpacked archive)"
   eval ${1}_UPDATE_SITE_URL="file://$UNPACK_DIR"
   install_update_site $1

   cd "$DOWNLOAD_DIR"
   rm -rf "$UNPACK_DIR"
}

user_pass() {
   site=$1
   echo "Please write your login for update site $site"
   echo "User name: "
   read user
   echo "Password: "
   read pass
   eval ${1}_USER="$user"
   eval ${1}_PASS="$pass"
}


MYDIR=$(dirname "$0")
ORIGDIR="$PWD"

# Special case for vagrant: We know the script is in /vagrant
# $0 is in this case the name of the shell instead of the name of the script
test_vagrant
if_vagrant echo Using vagrant : $0
if_vagrant MYDIR=/vagrant

cd "$MYDIR"

# Include config
. ./CONFIG

OSTYPE=$(uname -o)
MACHINE=$(uname -m)

# Check that a few necessary variables are defined
defined ECLIPSE_INSTALLER_$MACHINE INSTALL_DIR DOWNLOAD_DIR DBUS_EMF_UPDATE_SITE_URL GEF4_UPDATE_SITE_URL FRANCA_ARCHIVE_URL

# Override CONFIG for the download dir if running in Vagrant
if_vagrant DOWNLOAD_DIR=/vagrant

# Create install and workspace dirs
mkdir -p "$INSTALL_DIR" || die "Can't create target dir ($INSTALL_DIR)"
if [ -d "$WORKSPACE_DIR" ] ; then
   echo
   echo "NOTE the workspace dir in CONFIG exists ($WORKSPACE_DIR)!"
   echo "I will unpack files into $WORKSPACE_DIR !"
   warn "Remove it to make a clean installation or back up your files!"
else
   mkdir -p "$WORKSPACE_DIR"
fi

# Support 32 or 64 bit choice automatically
OSTYPE=$(uname -o)
MACHINE=$(uname -m)

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
    echo "ERROR: Unknown (OSTYPE=$OSTYPE, MACHINE=$MACHINE)" >/dev/stderr
    exit 1
fi

# Get Eclipse archive
cd "$DOWNLOAD_DIR"
step "Downloading Eclipse installer"
download "$ECLIPSE_INSTALLER"  # This sets a variable named $downloaded_file

# File exists?, correct MD5?, then unpack
[ -f "$downloaded_file" ] || die "ECLIPSE not found (not downloaded?)."
step Checking MD5 sum for Eclipse
step "Unpacking Eclipse"
md5_check ECLIPSE "$downloaded_file" $MACHINE
untar "$downloaded_file" "$INSTALL_DIR"

# TBD - Orbit not yet required (have not reached this dependency yet?)
#step "Installing ICU4J/Orbit"
#install_update_site       ORBIT

install_site_archive EMF_VALIDATION

install_site_archive EMF_TRANSACTION

step "Installing EMF Workspace from update site"
install_update_site  EMF

step "Installing DBus EMF model from update site"
check_site_hash           DBUS_EMF
check_site_latest_version DBUS_EMF
install_update_site       DBUS_EMF

# Temporarily removed because of GEF4 failure (UI install for 0.9.1 is broken because of this)
#step "Installing GEF4 from update site"
#install_update_site       GEF4

step "Downloading Sphinx update site archive (.zip)"
download "$SPHINX_ARCHIVE_URL" "$SPHINX_ARCHIVE"
md5_check SPHINX_ARCHIVE "$downloaded_file"
unpack_site_archive SPHINX "$downloaded_file"

# It's not very nice - whoever set up the creation of zip-file for sphinx
# from their CI system did not use a sane root for the archive, so this
# huge ugly path is inside the zip... 
# So let's first move the content out of there...
cd "$UNPACK_DIR"
mv home/hudson/genie.sphinx/.hudson/jobs/sphinx-0.8-luna-publish/workspace/releng/org.eclipse.sphinx.releng.builds/updates/* . || die "path fix for zipfile failed -- has it changed in the archive? - please check script for details"
rm -r home || die "some weird non-writable file can't be deleted?"
cd -

SPHINX_UPDATE_SITE_URL="file://$UNPACK_DIR"
step "Installing Sphinx"
install_update_site SPHINX
rm -rf "$UNPACK_DIR"

step "Downloading Franca update site archive (.zip)"
download "$FRANCA_ARCHIVE_URL" "$FRANCA_ARCHIVE"
md5_check FRANCA_ARCHIVE "$downloaded_file"

# I can't get install directly from zip file to work using command line
# invocation --installIU).  Is it supposed to work?)
# Anyhow for now unpack zip manually, then install. That works. 

step Unpacking Franca update site archive
UNPACK_DIR=$DOWNLOAD_DIR/tmp.$$
mkdir -p "$UNPACK_DIR"            || die "mkdir UNPACK_DIR ($UNPACK_DIR) failed"
cd "$UNPACK_DIR"                  || die "cd to UNPACK_DIR ($UNPACK_DIR) failed"
unzip -q "$DOWNLOAD_DIR/$downloaded_file" || die "unzip $DOWNLOAD_DIR/$downloaded_file failed"
cd - >/dev/null

FRANCA_UPDATE_SITE_URL="file://$UNPACK_DIR"
step Installing Franca
install_update_site FRANCA
rm -rf "$UNPACK_DIR"

step "Installing ARTOP tools"
get_local_file "$ARTOP_ARCHIVE"
unpack_site_archive ARTOP "$downloaded_file"
ARTOP_UPDATE_SITE_URL="file:///$UNPACK_DIR"
install_update_site ARTOP


step "Installing IONAS packages from update site"
install_update_site       IONAS

echo STOPPPHERE
exit

step Downloading Franca examples

cd "$WORKSPACE_DIR"                    || die "cd to WORKSPACE_DIR ($WORKSPACE_DIR) failed"
download "$EXAMPLES_URL"
EXAMPLES_FILE="$downloaded_file"

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
   and select Run As "JUnit Test".

   But from now on you should instead read the Franca documentation for up to
   date instructions on this stuff.
MSG

echo
echo "All Done. You may now start eclipse by running: $INSTALL_DIR/eclipse/eclipse"

