#!/bin/bash -ev
#
#  init for ontv2
#
#sudo apt-get --quiet install xmltv >/dev/null
git clone https://github.com/XMLTV/xmltv.git
echo yes |perl Makefile.PL
make -j4
sudo make install
echo all |tv_grab_ch_search --configure
tv_grab_ch_search --output ~/.xmltv/current.xml --days 1
tv_grab_ch_search --version
#tv_count -i ~/.xmltv/current.xml
