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
#         NAME: install-dazzle.sh
#      CREATED: 01-11-2014
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
date=$(date -u +"%Y%m%d")
time=$(date -u +"%H:%M:%S")
#--- Other Variables -----------------------------------------------------------
log=install.info
cwd=`cat <$log | grep cwd | awk '{print $3}'`
sysadmin=`cat <$log | grep "sysadmin =" | awk '{print $3}'`
hostname=`cat <$log | grep "hostname =" | awk '{print $3}'`
domain=`cat <$log | grep "domain =" | awk '{print $3}'`
suffix=`cat <$log | grep "suffix =" | awk '{print $3}'`
fullname=`cat <$log | grep "fullname =" | awk '{print $3}'`
internaladdress=`cat <$log | grep "internaladdress =" | awk '{print $3}'`
kerberos=`cat <$log | grep "kerberos =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
cakey=`cat <$log | grep "cakey =" | awk '{print $3}'`
cacert=`cat <$log | grep "cacert =" | awk '{print $3}'`
ldapadmin=`cat <$log | grep "ldapadmin =" | awk '{print $3}'`
ldappasswd=`cat <$log | grep "ldappasswd =" | awk '{print $3}'`
uidstart=`cat <$log | grep "uidstart =" | awk '{print $3}'`
uidend=`cat <$log | grep "uidend =" | awk '{print $3}'`
gidstart=`cat <$log | grep "gidstart =" | awk '{print $3}'`
gidend=`cat <$log | grep "gidend =" | awk '{print $3}'`
midstart=`cat <$log | grep "midstart =" | awk '{print $3}'`
midend=`cat <$log | grep "midend =" | awk '{print $3}'`
netadmin=`cat <$log | grep "netadmin =" | awk '{print $3}'`
netadmingrp=`cat <$log | grep "netadmingrp =" | awk '{print $3}'`
netadminpasswd=`cat <$log | grep "netadminpasswd =" | awk '{print $3}'`
realm=`cat <$log | grep "realm =" | awk '{print $3}'`
kdc=`cat <$log | grep "kdc =" | awk '{print $3}'`
admin_server=`cat <$log | grep "admin_server =" | awk '{print $3}'`
mainshare=`cat <$log | grep "mainshare =" | awk '{print $3}'`

# Read Main Share location add trailing slash so the "dazzle" folder is created as
# $mainshare\dazzle and not $mansharedazzle
echo $mainshare | sed 's/$/\//' | cat >dazzlehome.temp
dazzlehome=`cat <dazzlehome.temp`

# Whiptail input box where user can enter value
module='Sparkel Share & Dazzle Server'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Sparkle Share <- to -> Dazzle Server 

SparkleShare creates a special folder on your computer. You can add remotely hosted folders \
(\"projects\") to this folder. These projects will be automatically kept in sync with \
both the host and all of your peers when someone adds, removes or edits a file.

Dazzle is the Server side component of Sparkel Share, Setting Dazzle's Home directory will \
be the location on your server where all project files reside, it is a good idea to place \
these special \"project\" folders on you main storage location.

Besed on your Primary Share location the installer has suggested the filesystem path where \
Sparkle <- to -> Dazzle Project folder (called \"dazzle\") will be stored.

Please enter the location for Dazzle Project folder:" 26 68 $dazzlehome 2>dazzlehome.temp

# Check for null entry
dazzlehome=`cat <dazzlehome.temp`
{
   	if [ "$dazzlehome" = "" ] ; then
   		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./install-dazzle.sh
    else
		continue
    fi
}
sleep 3
# Check for dazzle.sh script
{
   	if [ -f dazzle.sh ] ; then 
   		continue
   	else
   		whiptail --title "DAZZLE.SH Script MISSING!!!" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The \"dazzle.sh\" script is missing, this is required for the $module module to be \
installed and configured. The installer will attempt to fetch that latest version and \
complete installation.

You can manually download the latest version form: https://github.com/hbons/Dazzle/blob/master/dazzle.sh" 14 68

		# Attempt to fetch the latest script
		clear
		echo "Connecting to: https://raw.githubusercontent.com/hbons/Dazzle/master"
		echo "pulling down dazzle.sh script"
		curl https://raw.githubusercontent.com/hbons/Dazzle/master/dazzle.sh --output dazzle.sh
        # Re-Start Module
        #./install-dazzle.sh
        	{
   				if [ -f dazzle.sh ] ; then
   					continue
   				else
   					echo "dazzle.sh script not found - exiting..."
   					exit
   				fi
   			}
    fi
}

# Dazzle relies on GIT - so installing that first.
sudo apt-get -y --force-yes install git liberror-perl git-man git-core

# Editing the Stock Dazzle script from: https://github.com/hbons/Dazzle/blob/master/dazzle.sh
# The first Sed changes the dazzle user form "storage" to "dazzle"
# The second takes the specified filesystem path and sets it as the Home directory for the dazzle user.
# The third replaces the Fetch External IP to Internal FQDN
#cat dazzle.sh | sed 's/DAZZLE_USER="${DAZZLE_USER:-storage}"/DAZZLE_USER="${DAZZLE_USER:-dazzle}"/' \
#| sed 's#DAZZLE_HOME="${DAZZLE_HOME:-/home/$DAZZLE_USER}"#DAZZLE_HOME="${DAZZLE_HOME:-'$dazzlehome'$DAZZLE_USER}"#' \
#| sed 's/IP=`curl --silent http:\/\/ifconfig.me\/ip`/IP='$fqdn'/' \
#| cat >dazzle

# Editing the Stock Dazzle script from: https://github.com/hbons/Dazzle/blob/master/dazzle.sh
# The first takes the specified filesystem path and sets it as the Home directory for the dazzle user.
# The second replaces the Fetch External IP to Internal FQDN
cat dazzle.sh \
| sed 's#DAZZLE_HOME="${DAZZLE_HOME:-/home/$DAZZLE_USER}"#DAZZLE_HOME="${DAZZLE_HOME:-'$dazzlehome'$DAZZLE_USER}"#' \
| sed 's/IP=`curl --silent http:\/\/ifconfig.me\/ip`/IP='$fqdn'/' \
| cat >dazzle

# Placing the dazzle script int place
sudo mv -v dazzle /usr/local/bin/dazzle
sudo chmod +x /usr/local/bin/dazzle
echo "Setting up Dazzle..."
sleep 1
sudo dazzle setup
echo "dazzlehome = $dazzlehome" | cat >>$log
sleep 2

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "Dazzle Server: Enabled" | cat >>$notes
echo "Dazzle UNIX User & Group: stroage" | cat >>$notes
echo "Dazzle Storage Path: $dazzlehome" | cat >>$notes

# Removing .temp files
rm -rf *.temp