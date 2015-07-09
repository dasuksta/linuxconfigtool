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
#         NAME: system-cert-ca.sh
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

# Whiptail input box where user can enter value
module='Name of Organisation'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Enter the name of the Company or Orginsation to be used, if this installation is not for \
an Organisation, then the systems Hostname or FQDN can be used.

Please enter Company or Organisation Name below:" 14 68 $fullname 2>organization.temp

# Check for null entry
organization=`cat <organization.temp`
{
    if [ "$organization" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./system-cert-ca.sh
    else
		continue
    fi
}

# Whiptail input box where user can enter value
module='Organisational Unit or Department'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Enter the name of Orginsational Unit or Department responsibe for issuing Certificates for \
Services and Clients on your Network.

Please enter Orginsational Unit or Department below:" 14 68 "ICT Department" 2>unit.temp

# Check for null entry
unit=`cat <unit.temp`
{
    if [ "$unit" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./system-cert-ca.sh
    else
		continue
    fi
}

# Whiptail input box where user can enter value
module='Country Code'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter you Country as a two digit code, for example if you were in Great Britan, you would enter:GB

Please enter your Country Code below:"  12 68 "GB" 2>countrycode.temp

# Strip input - remove all text after first two letters and capitalise
cat countrycode.temp | cut -c-2 | sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' \
| cat >country.temp

country=`cat <country.temp`
	# Check for null entry
	{
    	if [ "$country" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./system-cert-ca.sh
        else
	    	continue
    	fi
	}


# Whiptail input box where user can enter value
module='State / Region'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the name of your local Geopraphical State or Municipal Region.

Please enter your State/Region name below:"  12 68 "Local State" 2>state.temp

state=`cat <state.temp`
	# Check for null entry
	{
    	if [ "$state" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./system-cert-ca.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Common Name'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the Common Name of your Certififctae Authority, this will be used to identify yout CA.
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
    	    ./system-cert-ca.sh
        else
	    	continue
    	fi
	}

# If /etc/ssl/ca.info file exists - read serial number and plus 1
{
	if [ -f /etc/ssl/ca.info ] ; then
		number=`cat </etc/ssl/ca.info | grep serial | awk '{print $3}'`
		expr $number + 1 cat >serial.temp
	else
		echo 1 >serial.temp
	fi
}
serial=`cat <serial.temp`

# Whiptail input box where user can enter value
module='Serial Number'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The serial number of the certificate should be incremented each time a new certificate is generated.

Please enter the Serial number below:"  12 68 $serial 2>serial.temp

serial=`cat <serial.temp`
	# Check for null entry
	{
    	if [ "$serial" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./system-cert-ca.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Certificate Expiry'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
In how many days, counting from today, this certificate will expire? A default 3560 days (10 years) has been pre-entered.

Please enter the number of days this certificate will expire:"  12 68 3650 2>expiry.temp

expiry=`cat <expiry.temp`
	# Check for null entry
	{
    	if [ "$expiry" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./system-cert-ca.sh
        else
	    	continue
    	fi
	}

# Whiptail menu to select encryption keysize
module='Encryption Keysize'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --nocancel --menu "
Please Select the bit-size of the key that will be generated. This number is the size of \
the key, in bits. The greater the number of bits in the key the more secure it is \
considered, provided a strong password is used!

NOTE: The larger the size of key, the greater the processing time & overhead.

Please select the Encryption Key Size (bits):" 22 68 4 \
\
LOW ": 1248 bit RSA private key...." \
\
NORMAL ": 2432 bit RSA private key.... " \
\
HIGH ": 3248 bit RSA private key...." \
\
ULTRA ": 15424 bit RSA private key...." \
\
2>keysize.temp

keysize=`cat <keysize.temp`
# Change output text into lowercase
echo $keysize | sed 's/\(.*\)/\L\1/' | cat >keysize.temp

# Whiptail yes no - apply changes to system or cancel
module='CA Summary'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel \
"Your Certificate Authority will be setup with the following...

GnuTLS Certificate Authority
Organization = $organization
Department   = $unit
Country Code = $country
State/Region = $state
Common Name  = $cname
Serial No    = $serial
Expiry       = $expiry days
Encryption   = $keysize

Select Yes to Continue or select No to exit." 20 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Install GNU TLS and configure LDAP over TLS
sudo apt-get -y --force-yes install gnutls-bin ssl-cert

# Create Temp file to Define CA
echo "organization = $organization" | cat >ca.info
echo "unit = $unit" | cat >>ca.info
echo "state = $state" | cat >>ca.info
echo "country = $country" | cat >>ca.info
echo "cn = $fqdn" | cat >>ca.info
echo "serial = $serial" | cat >>ca.info
echo "expiration_days = $expiry" | cat >>ca.info
echo "ca" | cat >>ca.info
echo "cert_signing_key" | cat >>ca.info
echo "crl_signing_key" | cat >>ca.info

# Copy CA Information into place
sudo cp -v ca.info /etc/ssl/

# Create Private key for CA
sudo certtool --generate-privkey --sec-param $keysize --outfile /etc/ssl/private/ca."$fullname".key

# Signing the CA Certificate
sudo certtool --generate-self-signed --load-privkey /etc/ssl/private/ca."$fullname".key \
--template /etc/ssl/ca.info --outfile /etc/ssl/certs/ca."$fullname".cert

# Tightening up file permissions for the CA key
sudo chmod 600 /etc/ssl/private/ca."$fullname".key

# Making installation log entries
echo "cakey = ca."$fullname".key" | cat >>$log
echo "cacert = ca."$fullname".cert" | cat >>$log

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "Certificate Authority: Enabled" | cat >>$notes
echo "Key: ca."$fullname".key" | cat >>$notes
echo "Certificate: ca."$fullname".cert" | cat >>$notes

sleep 2
./system-cert-sign.sh