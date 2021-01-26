#!/bin/bash -ev
#
#  init for google
#
# main
#mkdir ~/bin
git clone https://github.com/jarun/googler.git
$d=$PWD
cd ~/bin
ln -s $PWD/googler/googler
#PATH=$PATH:~/bin
