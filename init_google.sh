#!/bin/bash -ev
#
#  init for google
#
# main
#mkdir ~/bin
git clone https://github.com/jarun/googler.git
gd=$PWD
cd ~/bin
ln -s $gd/googler/googler
#PATH=$PATH:~/bin
