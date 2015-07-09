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
#         NAME: system-ldap.sh
#      CREATED: 27-10-2014
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
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
internaladdress=`cat <$log | grep "internaladdress =" | awk '{print $3}'`
cakey=`cat <$log | grep "cakey =" | awk '{print $3}'`
cacert=`cat <$log | grep "cacert =" | awk '{print $3}'`
serverkey=`cat <$log | grep "serverkey =" | awk '{print $3}'`
servercert=`cat <$log | grep "servercert =" | awk '{print $3}'`

# Whiptail input box where user can enter value
module='LDAP Administrator Password'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --passwordbox --nocancel "
When installed the $distro implimentation of OpenLDAP automatically configures LDAP based \
on the system Domain Name and creates a default LDAP Administrator.

LDAP Administrator: cn=admin,dc=$domain,dc=$suffix

Please a password for your LDAP Administrator, this will be used during the installation \
process and by other programs to work with this LDAP Server.

Please enter LDAP Administrator password:" 18 68  2>passwd1.temp

# Check for null entry
passwd1=`cat <passwd1.temp`
{
    if [ "$passwd1" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-ldap.sh
    else
		continue
    fi
}

# Display input box where user can re-enter value
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --passwordbox --nocancel "
Please re-enter the password for your LDAP Administrator.

LDAP Administrator: cn=admin,dc=$domain,dc=$suffix

Confirm LDAP Administrator password:" 12 68  2>passwd2.temp

# Check for null entry
passwd2=`cat <passwd2.temp`
{
    if [ "$passwd2" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-ldap.sh
    else
		continue
    fi
}
passwd1=`cat <passwd1.temp`
passwd2=`cat <passwd2.temp`

    # Check both values match
    {
    if [ "X$passwd1" = "X$passwd2" ] ; then
        echo $passwd2 | cat >ldap.passwd
        rm -rf passwd1.temp
        rm -rf passwd2.temp
    else
        {
	        if (whiptail --title "WARNING" --backtitle "$product for $distro $version - $url" --yesno "
    		    The passwords you have provided do not match! Start again?

Select YES to re-start installer or NO to exit." 10 68)
        	then
            	./system-ldap.sh
            	exit
        	else
            	rm -rf *.temp
            	exit
        	fi
        	}
    	fi
    }
# Remove temp password files
rm -rf passwd1.temp
rm -rf passwd2.temp
# Set the LDAP Admin password variable
ldappasswd=`cat <ldap.passwd`

# Whiptail input box where user can enter value
module='User UID Start'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
A user ID (UID) is a unique positive integer assigned by a Unix-like operating system \
to each user. Each user is identified to the system by its UID, and user names are \
generally used only as an interface for humans.

NOTE: If you are planning on installing Gitlab and enabling LDAP User Sign In. By default \
Gitlab assigns LDAP authencated users UID's from 10000 upwards.

Please enter the number would like Users UID to Start:"  18 68 "20000" 2>tmp-uidstart.temp

# Remove all characters besides numbers.
cat tmp-uidstart.temp | sed 's/[^0-9]//g' | cat >uidstart.temp
echo "" | cat >>uidstart.temp
# Set variable
uidstart=`cat <uidstart.temp`
	# Check for null entry
	{
    	if [ "$uidstart" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Get the first number of the starting UID
uidnumber=`cat uidstart.temp | cut -c1`
# Whiptail input box where user can enter value
module='User UID End'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
A user ID (UID) is a unique positive integer assigned by a Unix-like operating system \
to each user. Each user is identified to the system by its UID, and user names are \
generally used only as an interface for humans.

NOTE: If you are planning on installing Gitlab and enabling LDAP User Sign In.
By default Gitlab assigns LDAP authencated users UID's from 10000 upwards.

Please enter the number would like Users UID to End:"  18 68 "$uidnumber"'9999' 2>tmp-uidend.temp

# Remove all characters besides numbers.
cat tmp-uidend.temp | sed 's/[^0-9]//g' | cat >uidend.temp
echo "" | cat >>uidend.temp
# Set variable
uidend=`cat <uidend.temp`
	# Check for null entry
	{
    	if [ "$uidend" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Group GID Start'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The Group ID (GID), which by default is equal to the UID for all ordinary users, is a \
unique positive integer assigned by a Unix-like operating system to each system group.

Please enter the number would like Group GID to Start:"  12 68 "20000" 2>tmp-gidstart.temp

# Remove all characters besides numbers.
cat tmp-gidstart.temp | sed 's/[^0-9]//g' | cat >gidstart.temp
# Set variable
gidstart=`cat <gidstart.temp`
	# Check for null entry
	{
    	if [ "$gidstart" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Get the first number of the starting GID
gidnumber=`cat uidend.temp | cut -c1`
# Whiptail input box where user can enter value
module='Group GID End'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The Group ID (GID), which by default is equal to the UID for all ordinary users, is a \
unique positive integer assigned by a Unix-like operating system to each system group.

Please enter the number would like Group GID to End:"  12 68 "$gidnumber"'9999' 2>tmp-gidend.temp

# Remove all characters besides numbers.
cat tmp-gidend.temp | sed 's/[^0-9]//g' | cat >gidend.temp
# Set variable
gidend=`cat <gidend.temp`
	# Check for null entry
	{
    	if [ "$gidend" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Machine MID Start'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The Machine or Host ID (MID), is a unique positive integer assigned by a Unix-like operating \
system to each Machine or Host (Computer) witin the Network / Directory.

NOTE: If you plan on using Samba (Windows) domain hosts, then these systems will be added \
with their respective Machine ID (MID).

Please enter the number would like Machine MID to Start:"  16 68 "40000" 2>tmp-midstart.temp

# Remove all characters besides numbers.
cat tmp-midstart.temp | sed 's/[^0-9]//g' | cat >midstart.temp
# Set variable
midstart=`cat <midstart.temp`
	# Check for null entry
	{
    	if [ "$midstart" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Get the first number of the starting MID
midnumber=`cat midstart.temp | cut -c1`
# Whiptail input box where user can enter value
module='Machine MID End'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The Machine or Host ID (MID), is a unique positive integer assigned by a Unix-like operating \
system to each Machine or Host (Computer) witin the Network / Directory.

NOTE: If you plan on using Samba (Windows) domain hosts, then these systems will be added \
with their respective Machine ID (MID).

Please enter the number would like Machine MID to End:"  16 68 "$midnumber"'9999' 2>tmp-midend.temp

# Remove all characters besides numbers.
cat tmp-midend.temp | sed 's/[^0-9]//g' | cat >midend.temp
# Set variable
midend=`cat <midend.temp`
	# Check for null entry
	{
    	if [ "$midend" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Sudo LDAP - User'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
It is recommened you use a different user for administering network systems.

Please enter the name of the user that you would like to assign to the Network Administratiors \
group. This user will have admin rights (sudo) on every machine on the network without any \
further configuration.

NOTE: The installer has suggested a user name, however you can change this to what you prefer.

Please enter the name of the user you woud like to assign to the Network Administrators \
(sudo) Group:" 20 68 "netadmin" 2>netadmin.temp

# Set variable
netadmin=`cat <netadmin.temp`
	# Check for null entry
	{
    	if [ "$netadmin" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='Network Administrator Password'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --passwordbox --nocancel "
Please enter the password you would like to use for the Network Administrator.

Network Administrator: cn=$netadmin,dc=$domain,dc=$suffix

NOTE: For conveinece the installer has taken the LDAP Administrator password - this is NOT \
recommned in a production enviroment!

Please enter Network Administrator password:" 18 68 "$ldappasswd" 2>passwd1.temp

# Check for null entry
passwd1=`cat <passwd1.temp`
{
    if [ "$passwd1" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-ldap.sh
    else
		continue
    fi
}

# Display input box where user can re-enter value
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --passwordbox --nocancel "
Please re-enter the password for your Network Administrator.

Network Administrator: cn=$netadmin,dc=$domain,dc=$suffix

Confirm Network Administrator password:" 12 68 "$ldappaswd" 2>passwd2.temp

# Check for null entry
passwd2=`cat <passwd2.temp`
{
    if [ "$passwd2" = "" ] ; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-ldap.sh
    else
		continue
    fi
}
passwd1=`cat <passwd1.temp`
passwd2=`cat <passwd2.temp`

    # Check both values match
    {
    if [ "X$passwd1" = "X$passwd2" ] ; then
        echo $passwd2 | cat >netadmin.passwd
        rm -rf passwd1.temp
        rm -rf passwd2.temp
    else
        {
	        if (whiptail --title "WARNING" --backtitle "$product for $distro $version - $url" --yesno "
    		    The passwords you have provided do not match! Start again?

Select YES to re-start installer or NO to exit." 10 68)
        	then
            	./system-ldap.sh
            	exit
        	else
            	rm -rf *.temp
            	exit
        	fi
        	}
    	fi
    }
# Remove temp password files
rm -rf passwd1.temp
rm -rf passwd2.temp
# Set the LDAP Admin password variable
netadminpasswd=`cat <netadmin.passwd`

# Whiptail input box where user can enter value
module='Sudo LDAP - Group'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
The installer will also configure Sudo LDAP properties so that any network \
clients know which users/groups can use sudo and this can be centrally managed.

Please enter the name of the group that you would like Network Administratiors to be \
assigned to. This will enable users in this group to have admin rights (sudo) on every \
machine on the network without any further configuration – be careful who you assign to this group!

NOTE: It is better to use a different name to differentiate from the default “admin” or \
“sudo” group that exisists on the local system. 

Please enter the name for the Network Administrators (sudo) Group:" 24 68 "netadmins" 2>netadmingrp.temp

# Set variable
netadmingrp=`cat <netadmingrp.temp`
	# Check for null entry
	{
    	if [ "$netadmingrp" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-ldap.sh
        else
	    	continue
    	fi
	}

# Whiptail yes no - summarise and commit installation and configuration
module='LDAP Server Summary'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel \
"Your Open LDAP Directory server will be configured with the following...

Open LDAP Directory Server
LDAP Server    = ldap.$fullname
LDAP Server IP = $internaladdress
LDAP Admin     = cn=admin,dc="$domain",dc="$suffix"
Admin Password = $ldappasswd
User UID from  = $uidstart to $uidend
Group GID from = $gidstart to $gidend
Host MID from  = $midstart to $midend

Network Administrators Group = $netadmingrp
Network Administrator  = cn=$netadmin,dc=$domain,dc=$suffix
Administrator Password = $netadminpasswd

Select Yes to Continue or select No to exit." 24 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Make Installation log entries
echo "ldapadmin = cn=admin,dc="$domain",dc="$suffix"" | cat >>$log
echo "ldappasswd = $ldappasswd" | cat >>$log
echo "uidstart = $uidstart" | cat >>$log
echo "uidend = $uidend" | cat >>$log
echo "gidstart = $gidstart" | cat >>$log
echo "gidend = $gidend" | cat >>$log
echo "midstart = $midstart" | cat >>$log
echo "midend = $midend" | cat >>$log
echo "netadmin = $netadmin" | cat >>$log
echo "netadmingrp = $netadmingrp" | cat >>$log
echo "netadminpasswd = $netadminpasswd" | cat >>$log
# Read back LDAP Admin, as this entry has no .temp file
ldapadmin=`cat <$log | grep ldapadmin | awk '{print $3}'`

# Install and configure OpenLDAP server
clear
echo ""
echo "Installing LDAP Server"
sudo apt-get -y --force-yes install slapd ldap-utils

## Generate the base.ldif - DC & OU Containers are lowercase
echo ""
echo "Generating LDAP Configuration: base.ldif"
sleep 1
echo "dn: ou=users,dc=$domain,dc=$suffix" | cat >base.ldif
echo "objectClass: organizationalUnit" | cat >>base.ldif
echo "ou: users" | cat >>base.ldif
echo "description: LDAP Users" | cat >>base.ldif
echo "" | cat >>base.ldif
echo "dn: ou=groups,dc=$domain,dc=$suffix" | cat >>base.ldif
echo "objectClass: organizationalUnit" | cat >>base.ldif
echo "ou: groups" | cat >>base.ldif
echo "description: LDAP Groups" | cat >>base.ldif
echo "" | cat >>base.ldif
echo "dn: ou=computers,dc=$domain,dc=$suffix" | cat >>base.ldif
echo "objectClass: organizationalUnit" | cat >>base.ldif
echo "ou: computers" | cat >>base.ldif
echo "description: LDAP Computers" | cat >>base.ldif
echo ""
echo "Setting up LDAP Directory Information Tree..."
echo ""
echo "Adding base.ldif into LDAP Server"
echo ""
sudo ldapadd -x -D cn=admin,dc=$domain,dc=$suffix -w $ldappasswd -f base.ldif
sleep 1

# Generate the autofs.ldif Schema & enter into LDAP
echo "Generating LDAP Schema: autofs.ldif"
sleep 1
echo "dn: cn=autofs,cn=schema,cn=config" | cat >autofs.ldif
echo "objectClass: olcSchemaConfig" | cat >>autofs.ldif
echo "cn: autofs" | cat >>autofs.ldif
echo "olcAttributeTypes: {0}( 1.3.6.1.1.1.1.25 NAME 'automountInformation' DESC 'Inf" | cat >>autofs.ldif
echo " ormation used by the autofs automounter' EQUALITY caseExactIA5Match SYNTAX 1." | cat >>autofs.ldif
echo " 3.6.1.4.1.1466.115.121.1.26 SINGLE-VALUE )" | cat >>autofs.ldif
echo "olcObjectClasses: {0}( 1.3.6.1.1.1.1.13 NAME 'automount' DESC 'An entry in an " | cat >>autofs.ldif
echo " automounter map' SUP top STRUCTURAL MUST ( cn $ automountInformation $ object" | cat >>autofs.ldif
echo " class ) MAY description )" | cat >>autofs.ldif
echo "olcObjectClasses: {1}( 1.3.6.1.4.1.2312.4.2.2 NAME 'automountMap' DESC 'An gro" | cat >>autofs.ldif
echo " up of related automount objects' SUP top STRUCTURAL MUST ou )" | cat >>autofs.ldif
echo ""
echo "Adding autofs.ldif schema into LDAP Server"
echo ""
sudo ldapadd -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f autofs.ldif
sleep 1

# Generate automount.ldif
echo "Generating LDAP Configuration: automount.ldif"
sleep 1
echo "dn: ou=admin,dc=$domain,dc=$suffix" | cat >automount.ldif
echo "ou: admin" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: organizationalUnit" | cat >>automount.ldif
echo "description: Automount Admin Group Container" | cat >>automount.ldif
echo "" | cat >>automount.ldif
echo "dn: ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>automount.ldif
echo "ou: automount" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: organizationalUnit" | cat >>automount.ldif
echo "" | cat >>automount.ldif
echo "dn: ou=auto.master,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>automount.ldif
echo "ou: auto.master" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: automountMap" | cat >>automount.ldif
echo "" | cat >>automount.ldif
echo "dn: cn=/home,ou=auto.master,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>automount.ldif
echo "cn: /home" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: automount" | cat >>automount.ldif
echo "automountInformation: ldap:ou=auto.home,ou=automount,ou=admin,dc=$domain,dc=$suffix --timeout=60 --ghost" | cat >>automount.ldif
echo "" | cat >>automount.ldif
echo "dn: ou=auto.home,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>automount.ldif
echo "ou: auto.home" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: automountMap" | cat >>automount.ldif
echo "" | cat >>automount.ldif
echo "dn: cn=/,ou=auto.home,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>automount.ldif
echo "cn: /" | cat >>automount.ldif
echo "objectClass: top" | cat >>automount.ldif
echo "objectClass: automount" | cat >>automount.ldif
echo "automountInformation: -fstype=nfs4,rw,hard,intr,fsc,sec=krb5 $fqdn:/home/$" | cat >>automount.ldif
echo ""
echo "Adding automount.ldif into LDAP Server"
echo ""
sudo ldapadd -x -D cn=admin,dc=$domain,dc=$suffix -w $ldappasswd -f automount.ldif
sleep 1

# Generate the sudo.ldif schema
echo "Generating LDAP Schema: sudo.ldif"
sleep 1
echo "dn: cn=sudo,cn=schema,cn=config" | cat >sudo.ldif
echo "objectClass: olcSchemaConfig" | cat >>sudo.ldif
echo "cn: sudo" | cat >>sudo.ldif
echo "olcAttributeTypes: {0}( 1.3.6.1.4.1.15953.9.1.1 NAME 'sudoUser' DESC 'User(s) " | cat >>sudo.ldif
echo " who may  run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMa" | cat >>sudo.ldif
echo " tch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {1}( 1.3.6.1.4.1.15953.9.1.2 NAME 'sudoHost' DESC 'Host(s) " | cat >>sudo.ldif
echo " who may run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMat" | cat >>sudo.ldif
echo " ch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {2}( 1.3.6.1.4.1.15953.9.1.3 NAME 'sudoCommand' DESC 'Comma" | cat >>sudo.ldif
echo " nd(s) to be executed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1" | cat >>sudo.ldif
echo " 466.115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {3}( 1.3.6.1.4.1.15953.9.1.4 NAME 'sudoRunAs' DESC 'User(s)" | cat >>sudo.ldif
echo "  impersonated by sudo (deprecated)' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1" | cat >>sudo.ldif
echo " .4.1.1466.115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {4}( 1.3.6.1.4.1.15953.9.1.5 NAME 'sudoOption' DESC 'Option" | cat >>sudo.ldif
echo " s(s) followed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115" | cat >>sudo.ldif
echo " .121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {5}( 1.3.6.1.4.1.15953.9.1.6 NAME 'sudoRunAsUser' DESC 'Use" | cat >>sudo.ldif
echo " r(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466" | cat >>sudo.ldif
echo " .115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {6}( 1.3.6.1.4.1.15953.9.1.7 NAME 'sudoRunAsGroup' DESC 'Gr" | cat >>sudo.ldif
echo " oup(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.14" | cat >>sudo.ldif
echo " 66.115.121.1.26 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {7}( 1.3.6.1.4.1.15953.9.1.8 NAME 'sudoNotBefore' DESC 'Sta" | cat >>sudo.ldif
echo " rt of time interval for which the entry is valid' EQUALITY generalizedTimeMat" | cat >>sudo.ldif
echo " ch ORDERING generalizedTimeOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.24" | cat >>sudo.ldif
echo "  )" | cat >>sudo.ldif
echo "olcAttributeTypes: {8}( 1.3.6.1.4.1.15953.9.1.9 NAME 'sudoNotAfter' DESC 'End " | cat >>sudo.ldif
echo " of time interval for which the entry is valid' EQUALITY generalizedTimeMatch " | cat >>sudo.ldif
echo " ORDERING generalizedTimeOrderingMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.24 )" | cat >>sudo.ldif
echo "olcAttributeTypes: {9}( 1.3.6.1.4.1.15953.9.1.10 NAME 'sudoOrder' DESC 'an int" | cat >>sudo.ldif
echo " eger to order the sudoRole entries' EQUALITY integerMatch ORDERING integerOrd" | cat >>sudo.ldif
echo " eringMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.27 )" | cat >>sudo.ldif
echo "olcObjectClasses: {0}( 1.3.6.1.4.1.15953.9.2.1 NAME 'sudoRole' DESC 'Sudoer En" | cat >>sudo.ldif
echo " tries' SUP top STRUCTURAL MUST cn MAY ( sudoUser $ sudoHost $ sudoCommand $ s" | cat >>sudo.ldif
echo " udoRunAs $ sudoRunAsUser $ sudoRunAsGroup $ sudoOption $ sudoOrder $ sudoNotB" | cat >>sudo.ldif
echo " efore $ sudoNotAfter $ description ) )" | cat >>sudo.ldif
echo ""
echo "Adding sudo.ldif schema into LDAP Server"
echo ""
sudo ldapadd -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f sudo.ldif
sleep 1

# Generate the sudodefault.ldif
echo "Generating LDAP Configuration: sudodefault.ldif"
sleep 1
echo "dn: ou=sudoers,dc=$domain,dc=$suffix" | cat >sudodefault.ldif
echo "objectclass: organizationalUnit" | cat >>sudodefault.ldif
echo "objectclass: top" | cat >>sudodefault.ldif
echo "ou: sudoers" | cat >>sudodefault.ldif
echo "description: Network Administrators (Sudo) Groups" | cat >>sudodefault.ldif
echo "" | cat >>sudodefault.ldif
echo "dn: cn=defaults,ou=sudoers,dc=$domain,dc=$suffix" | cat >>sudodefault.ldif
echo "objectClass: top" | cat >>sudodefault.ldif
echo "objectClass: sudoRole" | cat >>sudodefault.ldif
echo "cn: defaults" | cat >>sudodefault.ldif
echo "description: Default sudoOptions go here" | cat >>sudodefault.ldif
echo "sudoOption: env_reset" | cat >>sudodefault.ldif
echo "sudoOption: mail_badpass" | cat >>sudodefault.ldif
echo "sudoOrder: 1" | cat >>sudodefault.ldif
echo "" | cat >>sudodefault.ldif
echo "dn: cn=root,ou=sudoers,dc=$domain,dc=$suffix" | cat >>sudodefault.ldif
echo "objectClass: top" | cat >>sudodefault.ldif
echo "objectClass: sudoRole" | cat >>sudodefault.ldif
echo "cn: root" | cat >>sudodefault.ldif
echo "sudoUser: root" | cat >>sudodefault.ldif
echo "sudoHost: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsUser: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsGroup: ALL" | cat >>sudodefault.ldif
echo "sudoCommand: ALL" | cat >>sudodefault.ldif
echo "sudoOrder: 2" | cat >>sudodefault.ldif
echo "" | cat >>sudodefault.ldif
echo "dn: cn=%admin,ou=sudoers,dc=$domain,dc=$suffix" | cat >>sudodefault.ldif
echo "objectClass: top" | cat >>sudodefault.ldif
echo "objectClass: sudoRole" | cat >>sudodefault.ldif
echo "cn: %admin" | cat >>sudodefault.ldif
echo "sudoUser: %admin" | cat >>sudodefault.ldif
echo "sudoHost: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsUser: ALL" | cat >>sudodefault.ldif
echo "sudoCommand: ALL" | cat >>sudodefault.ldif
echo "sudoOrder: 3" | cat >>sudodefault.ldif
echo "" | cat >>sudodefault.ldif
echo "dn: cn=%sudo,ou=sudoers,dc=$domain,dc=$suffix" | cat >>sudodefault.ldif
echo "objectClass: top" | cat >>sudodefault.ldif
echo "objectClass: sudoRole" | cat >>sudodefault.ldif
echo "cn: %sudo" | cat >>sudodefault.ldif
echo "sudoUser: %sudo" | cat >>sudodefault.ldif
echo "sudoHost: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsUser: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsGroup: ALL" | cat >>sudodefault.ldif
echo "sudoCommand: ALL" | cat >>sudodefault.ldif
echo "sudoOrder: 4" | cat >>sudodefault.ldif
echo "" | cat >>sudodefault.ldif
echo "dn: cn=%$netadmingrp,ou=sudoers,dc=$domain,dc=$suffix" | cat >>sudodefault.ldif
echo "objectClass: top" | cat >>sudodefault.ldif
echo "objectClass: sudoRole" | cat >>sudodefault.ldif
echo "cn: %$netadmingrp" | cat >>sudodefault.ldif
echo "sudoUser: %$netadmingrp" | cat >>sudodefault.ldif
echo "sudoHost: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsUser: ALL" | cat >>sudodefault.ldif
echo "sudoRunAsGroup: ALL" | cat >>sudodefault.ldif
echo "sudoCommand: ALL" | cat >>sudodefault.ldif
echo "sudoOrder: 5" | cat >>sudodefault.ldif
echo ""
echo "Adding sudodefault.ldif into LDAP server"
echo ""
sudo ldapadd -x -D cn=admin,dc=$domain,dc=$suffix -w $ldappasswd -f sudodefault.ldif
sleep 1

# LDAP Indices index.ldif
echo "Generating config for LDAP Indices, to improve perfromance"
sleep 1
echo "dn: olcDatabase={1}hdb,cn=config" | cat >index.ldif
echo "changetype: modify" | cat >>index.ldif
echo "add: olcDbIndex" | cat >>index.ldif
echo "olcDbIndex: uidNumber eq" | cat >>index.ldif
echo "olcDbIndex: gidNumber eq" | cat >>index.ldif
echo "olcDbIndex: loginShell eq" | cat >>index.ldif
echo "olcDbIndex: uid eq,pres,sub" | cat >>index.ldif
echo "olcDbIndex: memberUid eq,pres,sub" | cat >>index.ldif
echo "olcDbIndex: uniqueMember eq,pres" | cat >>index.ldif
echo "olcDbIndex: sudoHost eq,sub" | cat >>index.ldif
echo "olcDbIndex: sudoUser eq,sub" | cat >>index.ldif
echo ""
echo "Modifying LDAP Indices with: index.ldif"
echo ""
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f index.ldif
sleep 1

## Generate logging.ldif
echo "Generating LDAP logging configuration"
sleep 1
echo "dn: cn=config" | cat >logging.ldif
echo "changetype: modify" | cat >>logging.ldif
echo "add: olcLogLevel" | cat >>logging.ldif
echo "olcLogLevel: stats" | cat>>logging.ldif
echo ""
echo "Modifying LDAP logging with logging.ldif"
echo ""
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f logging.ldif

# create locations for ldap logs
sudo touch /var/lib/ldap/slapd.log
sudo chown openldap:openldap /var/lib/ldap/slapd.log
echo "LDAP logfile created at: /var/lib/ldap/slapd.log"
echo ""
sleep 5

# Make entries into /etc/dnsmasq.conf to make clients LDAP aware
echo "Making LDAP name entries into DNS server..."
sleep 1
echo "# LDAP Server Entry" | cat >>dnsmasq.conf
echo "# This maps ldap.$fullname to the server" | cat >>dnsmasq.conf
echo "address=/ldap.$fullname/$internaladdress" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "srv-host=_ldap._tcp.$fullname,ldap.$fullname,389" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "#" | cat >>dnsmasq.conf
sudo cp -v dnsmasq.conf /etc/dnsmasq.conf

# If /etc/ssl/$hostname.info file exists - setup LDAPS and LDAP over TLS
{
	if [ -f /etc/ssl/certs/"$hostname".cert ] ; then
		# Generate certinfo.ldif file
		echo ""
		echo "Found TLS Certificates, configuring LDAPS..."
		sleep 1
		echo "Generating LDAP Configuration: certinfo.ldif"
		sleep 1
		echo "dn: cn=config" | cat >certinfo.ldif
		echo "add: olcTLSCACertificateFile" | cat >>certinfo.ldif
		echo "olcTLSCACertificateFile: /etc/ssl/certs/$cacert" | cat >>certinfo.ldif
		echo "-" | cat >>certinfo.ldif
		echo "add: olcTLSCertificateFile" | cat >>certinfo.ldif
		echo "olcTLSCertificateFile: /etc/ssl/certs/$servercert" | cat >>certinfo.ldif
		echo "-" | cat >>certinfo.ldif
		echo "add: olcTLSCertificateKeyFile" | cat >>certinfo.ldif
		echo "olcTLSCertificateKeyFile: /etc/ssl/private/$serverkey" | cat >>certinfo.ldif
		# Telling slapd about TLS
		echo ""
		echo "Enabling LDAPS and LDAP over TLS connectivity..."
		sleep 1
		echo ""
		sudo ldapmodify -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f certinfo.ldif
		# Adding openldap user to the ssl-cert group
		sudo adduser openldap ssl-cert
		# enable LDAPS in /etc/default/slapd
		cat /etc/default/slapd \
		| sed 's/SLAPD_SERVICES="ldap:\/\/\/ ldapi:\/\/\/"/SLAPD_SERVICES="ldap:\/\/\/ ldaps:\/\/\/ ldapi:\/\/\/"/' \
		| cat >slapd
		# Tell LDAP about certificate to use
		cat /etc/ldap/ldap.conf \
		| sed 's/\/etc\/ssl\/certs\/ca-certificates.crt/\/etc\/ssl\/certs\/'$hostname'.cert/' \
		| cat >ldap.conf
		# Copying config file into place
		sudo cp -v /etc/default/slapd /etc/default/slapd-$date
		sudo mv -v slapd /etc/default/slapd
		sudo cp -v /etc/ldap/ldap.conf /etc/ldap/ldap.conf-$date
		sudo mv -v ldap.conf /etc/ldap/ldap.conf
	else
		echo "LDAPS and LDAP over TLS NOT CONFIGURED!!!"
		sleep 3 
	fi
}

# Indexing the database
echo ""
echo "Stopping LDAP server to index Database"
sleep 1
sudo service slapd stop
sudo su - openldap -c slapindex
sleep 1
sudo service slapd start
sleep 1

# Install and configure ldapscripts
echo ""
echo "Installing tools to help User and Group Management"
sleep 2
sudo apt-get -y --force-yes install ldapscripts
# backup file
sudo cp /etc/ldapscripts/ldapscripts.conf /etc/ldapscripts/ldapscripts.conf-$date
echo "Configuring LDAP Users UID from: $uidstart to $uidend"
sleep 1
echo "Configuring LDAP Groups GID from: $gidstart to $gidend"
sleep 1
echo "Configuring LDAP Machine MID form: $midstart to $midend"
sleep 1
echo "This will help prevent User UID clashes if you install Gitlab Server."
sleep 1
echo "Gitlab is configured to Auto create LDAP authenticated users starting"
sleep 1
echo "from the UID 10000 and upwards."
sleep 2

# Change contents of ldapscripts.conf file to match above conventions
cat /etc/ldapscripts/ldapscripts.conf \
| sed 's/#SERVER="ldap:\/\/localhost"/SERVER="ldap:\/\/localhost"/' \
| sed 's/#SUFFIX="dc=example,dc=com"/SUFFIX="dc='"$domain"',dc='"$suffix"'"/' \
| sed 's/#GSUFFIX="ou=Groups"/GSUFFIX="ou=groups"/' \
| sed 's/#USUFFIX="ou=Users"/USUFFIX="ou=users"/' \
| sed 's/#MSUFFIX="ou=Machines"/MSUFFIX="ou=computers"/' \
| sed 's/BINDDN="cn=Manager,dc=example,dc=com"/BINDDN="cn=admin,dc='"$domain"',dc='"$suffix"'"/' \
| sed 's/CREATEHOMES="no"/CREATEHOMES="yes"/' \
| sed 's/GIDSTART="10000" # Group ID/GIDSTART='"$gidstart"' # Group ID/' \
| sed 's/UIDSTART="10000" # User ID/UIDSTART='"$uidstart"' # User ID/' \
| sed 's/MIDSTART="20000" # Machine ID/MIDSTART='"$midstart"' # Machine ID/' \
| cat >ldapscripts.conf
# Copying config into place
sudo cp -v ldapscripts.conf /etc/ldapscripts/

# Setting Permissions for new users Directories
sudo cp /etc/adduser.conf /etc/adduser.conf-$date
cat /etc/adduser.conf | sed 's/DIR_MODE=0755/DIR_MODE=0700/' | cat >adduser.conf
sudo mv -v adduser.conf /etc/adduser.conf

# Setting password for ldapscripts
sh -c "echo -n '$ldappasswd' > ldap.temp"
cat ldap.temp | sed 's/^[ \t]*//;s/[ \t]*$//' | cat >ldapscripts.passwd
sudo mv -v ldapscripts.passwd /etc/ldapscripts/ldapscripts.passwd
sudo chmod 400 /etc/ldapscripts/ldapscripts.passwd

# Add Network Administrator Users and Group to LDAP server
echo "Adding Network Administrator User & Group to LDAP..."
sleep 2
echo "Adding Network Administrators Group: $netadmingrp"
sleep 1 
sudo ldapaddgroup $netadmingrp
echo "Adding Network Adminstrator: cn=$netadmin,dc=$domain,dc=$suffix"
sleep 1
sudo ldapadduser $netadmin $netadmingrp
echo "Setting password for Network Administrator"
sleep 1
sudo ldapsetpasswd $netadmin $netadminpasswd

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "LDAP Server: Enabled" | cat >>$notes
echo "LDAP Admin: cn=admin,dc="$domain",dc="$suffix"" | cat >>$notes
echo "LDAP Password: $ldappasswd" | cat >>$notes

# Removing .temp files
rm -rf *.temp