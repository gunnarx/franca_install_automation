#!/bin/sh

die() {
   echo Failed - stopping
   exit 1
}

echo Fetching from origin
git fetch origin
for br in $(git branch --list | grep -v master | grep -v deprecated= | sed 's/\*//' ) ; do
   [ -n "$br" ] && {
      git checkout $br || die
      echo -n "Merge origin/$br " ; git merge origin/$br
      echo -n "Merge master " ; git merge master -m "Merge master branch"
   }
done

echo Checking out master 
git checkout master

