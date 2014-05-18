#!/bin/sh
branch=$(git status -b -s | grep '##' | cut -c 4-) 
ver=kepler 
arch=x86_64 
variant=linux-gtk 
francaver=0.8.11

tag=franca_$francaver-$ver-$variant-$arch-$branch

set -x
echo git tag $tag
set +x

