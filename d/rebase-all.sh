#!/bin/sh

die() {
   echo Failed - stopping
   exit 1
}

for br in $(git branch --list | grep -v master | sed 's/\*//' ) ; do
   [ -n "$br" ] && {
      echo On branch: $br
      git checkout $br || die
      git rebase master || die
      git pull origin || die
   }
done

echo Checking out master 
git checkout master

