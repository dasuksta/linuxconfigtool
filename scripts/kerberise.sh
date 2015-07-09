#!/bin/sh
#===============================================================================
#         NAME: kerberise.sh
#  DESCRIPTION: Input box for users UID so Kerberos Principal can be created.
#      CREATED: 12-06-2015
#      REVISED: 25-06-2015
#       AUTHOR: Suki Parwana suki.parwana@gmail.com
#-------------------------------------------------------------------------------

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
path=/usr/local/bin
log=$path/server.info
sysadmin=`cat <$log | grep "sysadmin =" | awk '{print $3}'`
hostname=`cat <$log | grep "hostname =" | awk '{print $3}'`
domain=`cat <$log | grep "domain =" | awk '{print $3}'`
suffix=`cat <$log | grep "suffix =" | awk '{print $3}'`
fullname=`cat <$log | grep "fullname =" | awk '{print $3}'`
internaladdress=`cat <$log | grep "internaladdress =" | awk '{print $3}'`
kerberos=`cat <$log | grep "kerberos =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
realm=`cat <$log | grep "realm =" | awk '{print $3}'`

# Whiptail inout box to enter UID of user to kerberise
module='Kerberise User'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Kerberos Realm: $realm - Enter the UID (username) of the LDAP user to create a Kerberos \
Principal. Entering a Kerberos password for this user will create the required Kerberos \
entries whin your LDAP directory.

Please Note: this utility will NOT check users are valid, if the user dosen't exits \
principal will not be created.

Please enter user UID (username) to Kerberise:" 16 68 "" 2>useruid.temp

# Set variable
useruid=`cat <useruid.temp`
	# Check for NULL entry
	{
    	if [ "$useruid" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will NOT be restarted." 10 68
			rm -rf useruid.temp
	        exit
        else
	    	continue
    	fi
	}
clear
echo "Creating Kerberos Principal for:"
echo "uid=$useruid,ou=users,dc=$domain,dc=$suffix"
read -p "Press Enter to continue..." key
sudo kadmin.local -q "addprinc -x dn="uid=$useruid,ou=users,dc=$domain,dc=$suffix" $useruid"
echo ""
echo "Logging into localhost via SSH session for user: $useruid"
sleep 1
echo "Doing this will avoid login failure errors from Windows hosts"
sleep 1
ssh $useruid@localhost echo 'OK'
sleep 1
# Ask to Exit or Re-Run routine
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Creation of User Principal and system creation complete.
Do you want to Kerberise another user? " 10 68)
	then
		$path/./kerberise
	else
		rm -rf useruid.temp
		exit
	fi
}