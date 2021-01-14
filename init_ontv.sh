#!/bin/bash -ev
#
#  init for ontv2
#
# main
sudo cpanm --quiet Term::ReadKey
sudo cpanm --quiet XML::LibXML
sudo cpanm --quiet XML::Parser
sudo cpanm --quiet XML::TreePP
sudo cpanm --quiet XML::Twig
sudo cpanm --quiet XML::Writer
sudo cpanm --quiet Date::Manip
sudo cpanm --quiet DateTime
sudo cpanm --quiet File::Slurp
# graper
#sudo cpanm --quiet 
# script
sudo cpanm --quiet DateTime::Format::Strptime

#sudo apt-get --quiet install xmltv >/dev/null
git clone https://github.com/XMLTV/xmltv.git
cd xmltv
echo yes |perl Makefile.PL
make -j4
sudo make install
echo all |tv_grab_ch_search --configure
tv_grab_ch_search --output ~/.xmltv/current.xml --days 1
tv_grab_ch_search --version
#tv_count -i ~/.xmltv/current.xml
