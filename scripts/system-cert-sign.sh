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
#         NAME: system-cert-sign.sh
#      CREATED: 22-11-2014
#      REVISED: 28-06-2015
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
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`

# Whiptail yes no - continue or cancel
module='Server Certificate'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel \
	"You can now use you CA to generate and sign Certificates for Network Hosts and Services, \
to deploy secured network services.

NOTE: This installer will offer defaults based on this host, please change to suit your needs.

Select Yes to Continue or select No to exit." 14 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Whiptail input box where user can enter value
module='Common Name'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the Common Name of the host, this will be used to identify your system.

It is alway better to go with the FQDN of the system, so you recognise the Certificate origin.

Please enter your CA Common name below:"  14 68 $fqdn 2>cname.temp

cname=`cat <cname.temp`
	# Check for null entry
	{
    	if [ "$cname" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-gnutls.sh
        else
	    	continue
    	fi
	}

# If /etc/ssl/$hostname.info file exists - read serial number and plus 1
{
	if [ -f /etc/ssl/"$hostname".info ] ; then
		number=`cat </etc/ssl/"$hostname".info | grep serial | awk '{print $3}'`
		expr $number + 1 cat >serial.temp
	else
		echo 1 >serial.temp
	fi
}
serial=`cat <serial.temp`

# Whiptail input box where user can enter value
module='Serial Number'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The serial number of the certificate. Should be incremented each time a new certificate is generated.

Please enter the Serial number below:"  12 68 $serial 2>serial.temp

serial=`cat <serial.temp`
	# Check for null entry
	{
    	if [ "$serial" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-gnutls.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Certificate Expiry'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
In how many days, counting from today, this certificate will expire? As a default 1 year has been selected.

Please enter the number of days this certificate will expire:"  12 68 365 2>expiry.temp

expiry=`cat <expiry.temp`
	# Check for null entry
	{
    	if [ "$expiry" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-gnutls.sh
        else
	    	continue
    	fi
	}

# Read in required values form previous CA Configuration
organization=`cat </etc/ssl/ca.info | grep organization | sed 's/^.*= //'`
unit=`cat </etc/ssl/ca.info | grep unit | sed 's/^.*= //'`
state=`cat </etc/ssl/ca.info | grep state | sed 's/^.*= //'`
country=`cat </etc/ssl/ca.info | grep country | sed 's/^.*= //'`
module='Server/Client Summary'

# Whiptail yes no - Summary and Yes No box for user to apply action or reject.
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel \
"Your Server/Client Certificate will be setup with the following...

Server/Client Certificate Summary
Organization = $organization
Department   = $unit
Country Code = $country
State/Region = $state
Common Name  = $cname
Serial No    = $serial
Expiry       = $expiry days

Select Yes to Continue or select No to exit." 20 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}
# Reading logfile for CA Cert & CA Key files
cakey=`cat <$log | grep cakey | awk '{print $3}'`
cacert=`cat <$log | grep cacert | awk '{print $3}'`

# Create Info file for Host Certificate
echo "organization = $organization" | cat >$hostname.info
echo "unit = $unit" | cat >>$hostname.info
echo "state = $state" | cat >>$hostname.info
echo "country = $country" | cat >>$hostname.info
echo "cn = $fqdn" | cat >>$hostname.info
echo "expiration_days = $expiry" | cat >>$hostname.info
echo "tls_www_server" | cat >>$hostname.info
echo "encryption_key" | cat >>$hostname.info
echo "signing_key" | cat >>$hostname.info

# Copying file into place
sudo cp -v $hostname.info /etc/ssl/
# Generating Private Key for server/client - Using Hostname to keep things organised

sudo certtool --generate-privkey --sec-param normal --outfile /etc/ssl/private/"$hostname".key

# Creating Server Certificate
sudo certtool --generate-certificate --load-privkey /etc/ssl/private/"$hostname".key \
--load-ca-certificate /etc/ssl/certs/$cacert --load-ca-privkey /etc/ssl/private/$cakey \
--template /etc/ssl/"$hostname".info --outfile /etc/ssl/certs/"$hostname".cert

# Tightening up file permissions
sudo chgrp ssl-cert /etc/ssl/private/"$hostname".key
sudo chmod g+r /etc/ssl/private/"$hostname".key
sudo chmod o-r /etc/ssl/private/"$hostname".key

# Writing Server Certificates to logfile
echo "serverkey = "$hostname".key" | cat >>$log
echo "servercert = "$hostname".cert" | cat >>$log

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "Host Certificate: Signed" | cat >>$notes
echo "Host Key: "$hostname".key" | cat >>$notes
echo "Host Cert: "$hostname".cert" | cat >>$notes

# Removing .temp files
rm -rf *.temp
sleep 2