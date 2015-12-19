#!/bin/bash
# (C) 2014 Gunnar Andersson
# License: CC-BY 4.0 Intl. (http://creativecommons.org/licenses/by/4.0/)
# Git repository: https://github.com/gunnarx/franca_install_automation
# pull requests welcome

echo "***************************************************************"
echo " script.sh starting"
echo "***************************************************************"

# Set to "false" or "true" for debug printouts
DEBUG=false
MD5SUM=md5sum   # On MacOS X, the binary is "md5"
PREFERRED_JAVA_VERSION=1.7

debug() {
   $DEBUG && {
      echo -n '*DEBUG*: ' 1>&2
      echo $@ 1>&2
   }
}

die() {
   echo "Something went wrong.  Message: "
   echo "$@"
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
# Print a major header
section() {
      # Using printf because "echo -n" is not fully portable
      printf '********************************************************************\n'
      printf '*** ' ; echo $@
      printf '********************************************************************\n'
}

# Print an operation with *** in front of it
step() {
      printf '*** ' ; echo "$@"
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
# example:   x=foo ; deref x, returns the value of $foo !
deref() {
   debug "dereffing $1"
   eval echo \$$1
}

get_md5() {
   $MD5SUM "$1" | cut -b 1-32
}

match_md5() {
   f=$1
   expect_md5=$2
   # Succeed if expected is not defined, or if sum matches
   [ -z "$expect_md5" -o "$(get_md5 $f)" = "$expect_md5" ]
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
   if match_md5 $file $wanted_md5 ; then
      debug "MD5 ok ($item)"
      true
   else
      die "MD5 checksum ($md5) did not match predefined md5 ($wanted_md5) for item $item.  Check CONFIG file."
   fi
}


download() {
   cd "$DOWNLOAD_DIR"
   $DEBUG && set -x
   downloaded_file=
   outfile=$(basename "$1")
   expected_md5=$2
   sanity_check_filename "$outfile"
   # If already exists, we check md5 to know if it is complete and OK
   if [ -f "$outfile" ] ; then
      echo -n "File exists: $PWD/$outfile, checking..."
      if [ -n "$expected_md5" ] ; then
         if match_md5 $outfile $expected_md5 ; then
            echo "OK"
            downloaded_file="$outfile"
         else
            echo
            echo "File completeness MD5 check: expected $expected_md5, not matched"
         fi
      else
         echo "No MD5 given, can't check file completeness"
      fi
   else
      debug "File not downloaded yet"
   fi
   if [ -z "$downloaded_file" ] ; then
      echo Downloading...
#      wget -c "$1" -O "$outfile" -c --no-check-certificate || die "wget failed.  Is wget installed?"
      curl -L -# -O "$1"  || die "curl failed.  Is curl installed?"
      downloaded_file=$outfile
   fi
   $DEBUG && set +x
}

untar() {
   ensure [ -f "$1" ]
   targetdir="$2"
   # Use current directory as default targetdir if not specified
   [ -n "$targetdir" ] && targetdir=.
   tar xf "$1" -C "$2" || die "untar failed for $1"
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
      echo Listing all versions for your information:
      curl -s "$url/" | egrep '[0-9]\.[0-9]\.[0-9]' | sed 's/^/DEBUG: /'
   }

   latest=$(curl -s "$url/" | egrep '[0-9]\.[0-9]\.[0-9]' | sed 's/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/' | sort -n | tail -1)
   debug "latest: $latest"
   if [ "$latest" != "$version" ] ; then
      warn "There appears to be a later version than $version for $1"
   fi
}

_install_update_site() {
   # http://stackoverflow.com/questions/7163970/how-do-you-automate-the-installation-of-eclipse-plugins-with-command-line
   # http://help.eclipse.org/indigo/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Frunning_eclipse.htm
   # http://help.eclipse.org/helios/index.jsp?topic=/org.eclipse.platform.doc.isv/guide/p2_director.html

   cd "$MYDIR"

   site="$(deref ${1}_UPDATE_SITE_URL)"
   features="$(deref ${1}_FEATURES)"

   debug "Installing from update site $1"

   $DEBUG && set -x
   $INSTALL_DIR/eclipse/eclipse -nosplash \
      -application org.eclipse.equinox.p2.director \
      -repository "$site" \
      -destination $INSTALL_DIR/eclipse \
      -installIU "$features"

   if [ $? -eq 0 ] ; then
      echo "Success"
   else
      echo "Fail"
   fi

   $DEBUG && set +x
}

get_local_file() {

   file="$1"
   cd "$MYDIR"

   step "Find $1 software archive locally"
   done=false
   [ -f "./$file" ] && { path="./$file" ; done=true ; }
   while ! $done ; do
      echo "I need the file $file to be provided by you locally."
      echo "Please provide a path to the file (or the directory it is in)."
      echo "Path that is relative to current directory ($PWD) is ok."
      echo -n "Path: "
      read path
      path="${path/\~/$HOME}"  # We need to expand ~ manually
      [ -d "$path" -a -f "$path/$file" ] && path="$path/$file"
      [ -f "$path" ] && done=true
      [ ! -e "$path" ] && { echo "Let's see..." ; ls -l "$path" ; echo "No - try again." ; }
      [ -d "$path" -a ! -f "$path/$file" ] && { echo "No, can't find the file there - try again" ; }
   done

   cp "$path" "$DOWNLOAD_DIR"
   downloaded_file="$file"
   cd - >/dev/null
}

unpack_site_archive() {
   step "Unpacking archive $2 for $1"
   UNPACK_DIR=$DOWNLOAD_DIR/tmp.$$.$1
   mkdir -p "$UNPACK_DIR"            || die "mkdir UNPACK_DIR ($UNPACK_DIR) failed"
   cd "$UNPACK_DIR"                  || die "cd to UNPACK_DIR ($UNPACK_DIR) failed"
   unzip -q "$DOWNLOAD_DIR/$downloaded_file" || die "unzip $DOWNLOAD_DIR/$downloaded_file failed"
   cd - >/dev/null
}

install_site_archive() {
   section "Installing: $1 (site archive)"
   step "Downloading update site archive (.zip) for $1"
   url=$(deref ${1}_ARCHIVE_URL)
   download "$url" "$(deref ${1}_ARCHIVE_MD5)"
   md5_check "$1" "$downloaded_file"
   _install_archive "$1"
}

install_online_update_site() {
   section "Installing: $1 (online site)"
   _install_update_site "$1"
}

_install_archive() {
   unpack_site_archive "$1" "$downloaded_file"
   step "Installing $1 from local update site (unpacked archive)"
   eval ${1}_UPDATE_SITE_URL="file://$UNPACK_DIR"
   _install_update_site "$1"
   cd "$MYDIR"
   rm -rf "$UNPACK_DIR"
}

install_local_file() {
   cd "$MYDIR"
   section "Installing local file for $1"
   archivefile=$(deref ${1}_ARCHIVE)
   get_local_file "$archivefile"
   _install_archive "$1"

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

ORIGDIR="$PWD"
SCRIPTDIR=$(dirname "$0")
cd "$SCRIPTDIR"
MYDIR="$PWD"

# Special case for vagrant: We know the script is in /vagrant
# $0 is in this case the name of the shell instead of the name of the script
test_vagrant
if_vagrant echo Using vagrant : $0
if_vagrant MYDIR=/vagrant

cd "$MYDIR"

# Include config
[ -f ./CONFIG ] || die "CONFIG file missing?"
. ./CONFIG      || die "Failure when sourcing CONFIG"

# Support 32 or 64 bit choice automatically
OSTYPE=$(uname -o)
MACHINE=$(uname -m)

# Check that a few necessary variables are defined
defined ECLIPSE_INSTALLER_$MACHINE INSTALL_DIR DOWNLOAD_DIR DBUS_EMF_UPDATE_SITE_URL FRANCA_ARCHIVE_URL KRENDERING_SITE_URL

# Override CONFIG for the download dir if running in Vagrant
if_vagrant DOWNLOAD_DIR=/vagrant

# Create install and workspace dirs
if [ -d "$INSTALL_DIR/eclipse" ] ; then
   if [ -z "$VAGRANT" ] ; then  # No need to warn in vagrant case
      echo
      echo "NOTE the eclipse installation dir exists ($INSTALL_DIR/eclipse)!"
      echo "It is usually not a problem but to make a clean install you may want to remove it"
      warn "Remove installation dir if you want to make a clean install."
   fi
fi

mkdir -p "$INSTALL_DIR" || die "Can't create target dir ($INSTALL_DIR)"

if [ -d "$WORKSPACE_DIR" ] ; then
   if [ -z "$VAGRANT" ] ; then  # No need to warn in vagrant case
      echo
      echo "NOTE the workspace dir in CONFIG exists ($WORKSPACE_DIR)!"
      echo "I will unpack a few example files into $WORKSPACE_DIR !"
      warn "If your workspace content is important you may want to back up your files!"
   fi
fi

mkdir -p "$WORKSPACE_DIR" || die "Fail creating $WORKSPACE_DIR"

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
section "Installing: Eclipse"
cd "$DOWNLOAD_DIR"
step "Downloading Eclipse installer"
download "$ECLIPSE_INSTALLER" $(deref ECLIPSE_MD5_$MACHINE) # This sets a variable named $downloaded_file

# File exists?, correct MD5?, then unpack
[ -f "$downloaded_file" ] || die "ECLIPSE not found (not downloaded?)."
md5_check ECLIPSE "$downloaded_file" $MACHINE
step "Unpacking Eclipse to $INSTALL_DIR"
untar "$downloaded_file" "$INSTALL_DIR"

install_online_update_site MWE

install_site_archive       MDT_OCL

install_site_archive       EMF_VALIDATION

install_site_archive       EMF_TRANSACTION

#install_online_update_site  EMF_RUNTIME
#install_site_archive EMF_RUNTIME

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
section "Checking DBus EMF model on update site"
check_site_hash            DBUS_EMF
check_site_latest_version  DBUS_EMF

install_online_update_site DBUS_EMF

install_online_update_site KRENDERING

install_site_archive       FRANCA

# ARTOP needs special download with login, therefore the user is required
# to provide the site archive locally.  We will ask for it here.
install_local_file         ARTOP

install_online_update_site IONAS

section Downloading Franca examples
cd "$WORKSPACE_DIR"                    || die "cd to WORKSPACE_DIR ($WORKSPACE_DIR) failed"
download "$EXAMPLES_URL" "$EXAMPLES_MD5"
step Checking MD5 sum for example
md5_check EXAMPLES "$downloaded_file"
EXAMPLES_FILE="$downloaded_file"

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
echo "All Done. You may now start eclipse by running: $INSTALL_DIR/eclipse/eclipse"

java -version >/dev/null 2>&1 || warn "Could not run java executable to check version!?"
java -version 2>&1 | fgrep -q $PREFERRED_JAVA_VERSION || warn "Your java version is not $PREFERRED_JAVA_VERSION? -- some of the eclipse features may _silently_ fail. WARNING\!"
