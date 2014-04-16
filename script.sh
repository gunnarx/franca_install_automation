#!/bin/sh

MYDIR=$(dirname "$0")
pushd "$MYDIR" >/dev/null

die() {
   echo "Something went wrong.  Message: "
   echo "$1"
}

source ./CONFIG
wget -c "$ECLIPSE" -O "$(basename $ECLIPSE)" || die "wget failed. Is wget installed?"

popd
