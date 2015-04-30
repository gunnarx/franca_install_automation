#!/bin/sh
branch=$(git status -b -s | grep '##' | cut -c 4-)
ver=luna-SR2
arch=x86_64
variant=linux-gtk
francaver=0.9.1

tag=franca_$francaver-$ver-$variant-$arch-$branch

git tag -f $tag

