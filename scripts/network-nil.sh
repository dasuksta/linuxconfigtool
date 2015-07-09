#!/bin/sh

#=== COPYRIGHT =================================================================
# Copyright (C) 2014  Sukhpal Singh Parwana aka. Suki Parwana
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#--- Other Notes ---------------------------------------------------------------
# All software, products and company names are trademarks™ or registered® 
# trademarks of their respective authors/holders. Use of them does not imply 
# any affiliation with or endorsement by them.
#
#--- Script Information --------------------------------------------------------
#         NAME: network-nil.sh
#      CREATED: 04-04-2014
#      REVISED: 22-05-2015
#       AUTHOR: Suki Parwana suki.parwana@gmail.com
#===============================================================================

#--- Common Variables ----------------------------------------------------------
product='Linux Config Tool'
distro='Ubuntu Server'
version='14.04 LTS'
url='www.linuxconfigtool.com'
auto='*Automatic Configuration*'
error='***Configuration Error***'
date=$(date -u +"%Y%m%d")
time=$(date -u +"%H:%M:%S")
#--- Other Variables -----------------------------------------------------------
log=network.info

# Whiptail Notice - No Network Interface found
whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --scrolltext "
A scan of your system has found NO active network interfaces, the Installer will now exit.

Please ensure your hardware is installed and operating correclty and re-run the installer." 10 68 \

rm -rf *.temp
exit