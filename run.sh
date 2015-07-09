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
#         NAME: install.sh
#      CREATED: 24-11-2014
#      REVISED: 26-06-2015
#       AUTHOR: Suki Parwana suki.parwana@gmail.com
#===============================================================================

#--- Common Variables ----------------------------------------------------------
product='Linux Config Tool'
distro='Ubuntu Server'
version='14.04 LTS'
url='www.linuxconfigtool.com'
auto='*Automatic Configuration*'
error='***Configuration Error***'
#--- Other Variables -----------------------------------------------------------
date=$(date -u +"%Y%m%d")
time=$(date -u +"%H:%M:%S")
# Capture console dimensions and set max size for whiptail
test -x /usr/bin/tty && console=`/usr/bin/tty`
test -z "$console" && console=/dev/console
size=$(stty size < $console)
screen_w=${size#*\ }
screen_h=${size%%\ *}
if [ "$screen_w" -gt 0 ]; then
	max_w=$((screen_w-6))
fi
if [ "$screen_h" -gt 0 ]; then
	max_h=$((screen_h-6))
fi

# Whiptail info box to begin Pre-Installation config.
module='Linux Server Configuration'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --scrolltext --msgbox "
$product is designed to help you quickly Setup and configure $distro $version. Using wherever \
possible only official packages, these installation routines will assit in configuring this \
system with:

 LOCALHOST NETWORKING
  - Setting Systems Fully Qualififed Domain Name.
  - Configuring up to x4 Network Interfaces using Inteface Bridging.
  - Setting this system as a Gateway for your network.
  - Installing System monitoring tools and services.

 NETWORK INFARSTRUCTURE
  DNS      - Domain Name Services.
  DHCP     - Dynamic Host Configuration Services.
  NTP      - Network Time Services.
  LDAP     - Open LDAP Directory Server.
  KERBEROS - To secure services and get closer to SSO.
  
 NETWORK SERVICES
  NFS   - Shares & Centralised Logins for Linux Clients.
  SMB   - Shares & Cnetralised Logins for Windows Clients.

 COLLABORATION TOOLS
  GITLAB  - Gitlab Version Control server, configured with LDAP.
  SPARKEL - Sparkel Share <-> Dazzle Server for easy collabaration.
  EGROUPWARE - Powerful and feature rich suite of tools & services.
  
 MONITORING TOOLS
  MUNIN  - System and network monitoring.
  WEBMIN - Configure & monitor your system easily.

all without the need for additional in-depth configuration knowledge.

Select OK to continue..."  24 $max_w 

# Whiptail info to show the Disclaimer and advise of Publishing License GPL v3
module='GPL v3 - Disclaimer'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --scrolltext --msgbox "
Copyright (C) 2014  Sukhpal Singh Parwana - suki.parwana@gmail.com

This program is free software: you can redistribute it and/or modify it under the terms \
of the GNU General Public License as published by the Free Software Foundation, either \
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; \
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this \
program.  If not, see http://www.gnu.org/licenses/.

- Other Notes -
All software, products and company names are trademarks™ or registered® trademarks of \
their respective authors/holders. Use of them does not imply any affiliation with or \
endorsement by them.
 
Select OK to continue..."  24 $max_w 

# Whiptail yes no - Display Yes No box for user to apply action or reject.
module='Question'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Ready to Begin Installation...

Installation scripts will now be executed on this system, do you want to continue?.

Select Yes to Continue or select No to exit." 12 68)
	then
		continue
	else
		exit
	fi
}
# Extract the scripts folder
#tar -zxvf scripts.tar.gz
# Change into scripts directory and begin install
cd scripts
# Make scripts executable and begin install
chmod +x *.sh
# Execute the install.sh script
./install.sh