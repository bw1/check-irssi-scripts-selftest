#!/bin/bash -e
#
#  init for ontv2
#
sudo apt-get --quiet install xmltv >/dev/null
echo all |tv_grab_ch_search --configure
tv_grab_ch_search --output ~/.xmltv/current.xml --days 1
#tv_count -i ~/.xmltv/current.xml
