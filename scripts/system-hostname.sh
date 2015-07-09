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
#         NAME: system-hostname.sh
#      CREATED: 23-11-2009
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
cwd=`cat <$log | grep "cwd =" | awk '{print $3}'`
sysadmin=`cat <$log | grep "sysadmin =" | awk '{print $3}'`

# Capture current system Hostname
hostname | cat >hostname.temp
hostname=`cat <hostname.temp`

# Whiptail inputbox to enter system hostname
module='System Hostname'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the Hostname for this System

The Hostname is a single unique word that identifies your system to the network. If you do \
not know what the hostname for this system should be, please consult your network administrator.

NOTE: You MUST NOT have two systems with identical hostnames within the same network or domain.

Hostname Examples: server, mail-serv, webserver etc...

Please enter the system hostname below:" 20 68 $hostname 2>hostname.temp

# Check for null entry
hostname=`cat <hostname.temp`
{
    if [ "$hostname" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./system-hostname.sh
    else
		continue
    fi
}
# Remove everthing after the first period and remove everything besides 
# Alpha upper & lower case numeric, underscore and hyphen
echo $hostname | sed -e "s/\..*//" | sed 's/[^-|_|a-z|A-Z|0-9]//g' | cat >hostname.temp

# Capture current system hostname
hostname | cat >hostnamecur.temp
hostnamecur=`cat <hostnamecur.temp`
# Capture current system FQDN
hostname -f | cat >hostnamefull.temp
hostnamefull=`cat <hostnamefull.temp`
# Remove the matching string -- Second Sed Pipe removes first period
sed 's/'$hostnamecur'//g' $hostnamefull | sed 's/\.//' | cat >domaincur.temp
domaincur=`cat <domaincur.temp`
# Check for null entry
{    
    if [ "$domaincur" = "" ] ; then
    	# if null entry found set domain as network.local
	    echo "network.local" | cat >dns1.temp
	    # re-read to update variable
	    domaincur=`cat <domaincur.temp`
	else
		continue
	fi
}

# Whiptail inputbox to enter system domainname
module='System Domain-Name'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter your Domain Name

The domain name is the TWO PART identifier for your network domain, and is appended to \
the right of your hostname and is often something that ends in .com .net .org or .local.
e.g. domain: network.com, example.net, private-net.local

NOTE: It is good pracitice to append the same domain to all computers in this network or domain.

Please enter the new system domain below:" 20 68 "$domaincur" 2>domainname.temp

domainname=`cat <domainname.temp`
# Check for NULL entry
{
    if [ "$domainname" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./system-hostname.sh
    else
		continue
    fi
}

# Load system variable for hostname
hostname=`cat <hostname.temp`
# Enter system hostname into installation info
echo "hostname = `cat <hostname.temp`" | cat >>$log
# Domain name logic
# Step 1 - Clean the Hostname entry of special characters
# Remove special characters besides Alpha upper & lower case numeric, underscore and hyphen.
echo $domainname | sed 's/[^-|_|.|a-z|A-Z|0-9]//g' | cat >domainname.temp
# Reload system variable for domain name
domainname=`cat <domainname.temp`
# Step 2 - Remove everything after the FIRST Period, leaving calculated "Domain Name"
echo $domainname | sed -e 's/\..*//' | cat >domain.temp
# Reload system variable for domain name
domain=`cat <domain.temp`
# Step 3 - From the Full Domain Name including Suffix remove matching Domain Name
# leaving behind only the Domain Suffix!
# Sed removes the matching string - Second Sed Pipe removes first period
echo $domainname | sed 's/'$domain'//g' | sed 's/\.//' | cat >suffix.temp
# Step 4 - Join hostname & domain to give fqdn
echo "$hostname.$domainname" | cat >fqdn.temp 
# Write system hostname configurations to log file
echo "domain = `cat <domain.temp`" | cat >>$log
echo "suffix = `cat <suffix.temp`" | cat >>$log
echo "fullname = `cat <domainname.temp`" | cat >>$log
echo "fqdn = `cat <fqdn.temp`" | cat >>$log

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "Installation Notes - $hostname.$domainname" | cat >$notes
echo "============================================================" | cat >>$notes
echo "Sudo User: $sysadmin" | cat >>$notes
echo "Password: " | cat >>$notes
# Removing .temp files
rm -rf *.temp