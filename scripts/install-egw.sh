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
#         NAME: install-egw.sh
#      CREATED: 19-11-2014
#      REVISED: 06-07-2015
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

# Whiptail menu to select interface configuration method.
module='Egroupware File Storage'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
How would you like to store Database Backups & Files uploaded into Egroupware?

DEFAULT - This will store Egroupware Backups & files in the default system location of:/var/lib/egroupware
If you are going to use this location please ensure your system has enough storage space \
as depening on what you use Egroupware for this location can get filled quickly.

CUSTOM - You choose where to locate the \"egroupware\" folder and files. Your Primary \
storage location will be the default, but you can change this to a different mountpoint \
with more stroage.

HELP: If you are unsure, please consult your network administrator or system docuemntation." 24 68 2 \
\
DEFAULT ": Backups & Files stored in /var/lib/egroupware." \
\
CUSTOM ": Backups & Files stored in custom location" \
2>egwstorage.temp

# Set variable
egwstorage=`cat <egwstorage.temp`
# Change output text into lowercase
echo $egwstorage | sed 's/\(.*\)/\L\1/' | cat >egwstorage.temp
# Update variable
egwstorage=`cat <egwstorage.temp`
{
	if [ "$egwstorage" = "custom" ]; then
	# Read Main Share location and suggest location one level up
	echo $mainshare | sed 's%/[^/]*$%/%' | cat >egwpath.temp
	egwpath=`cat <egwpath.temp`
	
	# Whiptail input box where user can enter value
	module='Egroupware Filepath'
	whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the filepath Location

Please enter the Absolute System Filepath Location for storing Egroupware Database Backups \
& Files Uploaded in to Egropuware.

Note: A folder called \"egroupware\" will be created here to house the required files & settings.

Please enter the absolute system filepath below:" 18 68 $egwpath 2>egwfiles.temp

		# Check for null entry
		egwfiles=`cat <egwfiles.temp`
		{
    		if [ "$egwfiles" = "" ] ; then
    			whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
	    		rm -rf *.temp
            	exit
        	else
	    		continue
    		fi
		}
	else
		continue
	fi
}


# Adding Egroupware Repo - this is to install the latest version and dependencies 
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/server:/eGroupWare/xUbuntu_14.04/ /' >>/etc/apt/sources.list.d/egroupware-epl.list"
# Adding Repo Key
wget http://download.opensuse.org/repositories/server:eGroupWare/xUbuntu_14.04/Release.key
sudo apt-key add - < Release.key

# Installing Egroupware
sudo apt-get update
sudo apt-get -y --force-yes install egroupware-epl

echo ""
echo "Going to download and install and remaining PEAR packages"
echo "needed to run Egroupware without any warnings..."
sleep 2
echo "Depending on your download speed, this could take a while..."
sleep 1
echo "please wait..."

# Grab the needed Pear packages and any dependencies
sudo pear install --alldeps pear.horde.org/Horde_Imap_Client

echo "Setting values into php.ini"
sudo cp /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini-$date
## upload max filesize - 64M is apparently the MAX
sudo sed -E -i "s/(upload_max_filesize.*=)(.*)/\1 64M/" /etc/php5/apache2/php.ini
## set-up time zone - went with a default of Europe/London so it's GMT
sudo sed -E -i "s/(^.*date.timezone.*=)/date.timezone = Europe\/London/" /etc/php5/apache2/php.ini
## set-up Mbstring func_overload - Not need as 0 is default, but here in case things change
#sudo sed -E -i "s/^.*mbstring.func_overload.*/mbstring.func_overload = 0/" /etc/php5/apache2/php.ini

# Setting Permissions to allow Egroupware Chat application
sudo chown www-data:www-data /usr/share/egroupware/phpfreechat/phpfreechat/data/public

# If custom location was selected for storing EGW files, move things about.
{
	if [ "$egwstorage" = "custom" ]; then
		sudo cp -rfp /var/lib/egroupware $egwfiles
		sudo mv -v /var/lib/egroupware /var/lib/egroupware-$date
		sudo ln -s "$egwfiles"egroupware /var/lib/
		echo "egwstroage = custom" | cat >>$log
		echo "egwfiles = $egwfiles" cat >>$log
	else
		continue
	fi
}
# Make Logfile entries
echo "egwstorage = default" | cat >>$log
echo "egwfiles = /var/lib/egroupware" | cat >>$log
echo ""
echo "Egroupware Installation Complete"
echo "Please configure your Egroupware server at:"
echo "http://$internaladdress/egroupware/setup.php"
sleep 2

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "Egroupware Server: Enabled" | cat >>$notes
echo "File Path: $egwfiles" | cat >>$notes
echo "Header Admin: <COMPLETE MANUALLY> " | cat >>$notes
echo "Password: <COMPLETE MANUALLY>" | cat >>$notes
echo "Admin User: <COMPLETE MANUALLY>" | cat >>$notes
echo "Password: <COMPLETE MANUALLY>" | cat >>$notes

# Removing .temp files
rm -rf *.temp