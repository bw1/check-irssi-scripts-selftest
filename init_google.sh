#!/bin/bash -ev
#
#  init for google
#
# main
#git clone https://github.com/jarun/googler.git
git clone https://github.com/pablojmarti/googler.git
gd=$PWD
cd /usr/local/bin
sudo ln -s $gd/googler/googler
#PATH=$PATH:~/bin

