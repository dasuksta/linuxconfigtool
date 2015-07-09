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
#         NAME: client-ubuntu.sh
#      CREATED: 08-06-2015
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
log=client.info
server=`cat <$log | grep "server =" | awk '{print $3}' | grep server`
domain=`cat <$log | grep "domain =" | awk '{print $3}'`
suffix=`cat <$log | grep "suffix =" | awk '{print $3}'`
fullname=`cat <$log | grep "fullname =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
gidstart=`cat <$log | grep "gidstart =" | awk '{print $3}'`
realm=`cat <$log | grep "realm =" | awk '{print $3}'`
kdc=`cat <$log | grep "kdc =" | awk '{print $3}'`
admin_server=`cat <$log | grep "admin_server =" | awk '{print $3}'`
kdcadmin=`cat <$log | grep "kdcadmin =" | awk '{print $3}'`
mainshare=`cat <$log | grep "mainshare =" | awk '{print $3}'`

# Suggest New Name
echo "localadmin" | cat >localadmin.temp
localadmin=`cat <localadmin.temp`

# Whiptail input box where user can enter value
module='Create New Local Administrator'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Users who access this system, will have their Home Directory (the place were their files \
& settings are stored) centralised on: $fqdn

Creating a new local system administrator will allow you to access and adminster this \
system in case of any loss of connectivity or failure of remote services.

The Home directory will be created on this system at:/local/$localadmin

Please enter username of the New Local Administrator below:" 20 68 $localadmin 2>localadmin.temp

# Check for NULL entry
localadmin=`cat <localadmin.temp`
{
   	if [ "$localadmin" = "" ] ; then
   		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
    	rm -rf *.temp
           	exit
       	else
    	continue
   	fi
}

# Check for Existing User on system
users=$(id -u)
{
   	if [ "$localadmin" = "$users" ] ; then
   		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
That User already exixits on the system, restart! The installer will now exit and remove any changes." 10 68
    		rm -rf *.temp
           	exit
       	else
    		continue
   	fi
}

# Remove everthing after the first period and remove
# everyhting besides Alpha upper & lower case numeric, underscore and hyphen.
echo $localadmin | sed -e "s/\..*//" | sed 's/[^-|_|a-z|A-Z|0-9]//g' | cat >localadmin.temp
# Update variable to use.
localadmin=`cat <localadmin.temp`
# Making Local Administrator and setting Home Directory
clear
echo ""
echo "Creating Local Administrator: $localadmin"
sleep 2
sudo adduser $localadmin
sudo adduser $localadmin sudo
sudo mkdir -p /local/$localadmin
sudo chown $localadmin:$localadmin /local/$localadmin
sudo usermod -m -d /local/$localadmin $localadmin

# Capture current system Hostname
hostname | cat >hostname.temp
hostname=`cat <hostname.temp`

# Whiptail input box where user can enter hostname value
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
        echo "exiting setup..."
        exit
    else
		continue
    fi
}

# Take hostname and write new /etc/hostname & /etc/hosts files
echo "$hostname" | cat >hostname

echo "# $brand - Configuration generated on:$timestamp" | cat >hosts
echo "127.0.0.1	localhost" | cat >>hosts
echo "127.0.1.1	$hostname.$fullname	$hostname" | cat >>hosts # <-- DYNAMIC ENTRY
echo "" | cat >>hosts
echo "# The following lines are desirable for IPv6 capable hosts" | cat >>hosts
echo "::1     ip6-localhost ip6-loopback" | cat >>hosts
echo "fe00::0 ip6-localnet" | cat >>hosts
echo "ff00::0 ip6-mcastprefix" | cat >>hosts
echo "ff02::1 ip6-allnodes" | cat >>hosts
echo "ff02::2 ip6-allrouters" | cat >>hosts

sudo cp /etc/hosts /etc/hosts-$date
sudo cp hosts /etc/hosts
sudo cp hostname /etc/hostname

# Setting new hostname
#hostnamectl set-hostname $hostname

echo "Generating Configuration: krb5.conf"
sleep 1
echo "[libdefaults]" | cat >krb5.conf
echo "	default_realm = $realm" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "" | cat >>krb5.conf
echo "# The following krb5.conf variables are only for MIT Kerberos." | cat >>krb5.conf
echo "	krb4_config = /etc/krb.conf" | cat >>krb5.conf
echo "	krb4_realms = /etc/krb.realms" | cat >>krb5.conf
echo "	kdc_timesync = 1" | cat >>krb5.conf
echo "	ccache_type = 4" | cat >>krb5.conf
echo "	forwardable = true" | cat >>krb5.conf
echo "	proxiable = true" | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "# The following encryption type specification will be used by MIT Kerberos" | cat >>krb5.conf
echo "# if uncommented.  In general, the defaults in the MIT Kerberos code are" | cat >>krb5.conf
echo "# correct and overriding these specifications only serves to disable new" | cat >>krb5.conf
echo "# encryption types as they are added, creating interoperability problems." | cat >>krb5.conf
echo "#" | cat >>krb5.conf
echo "# Thie only time when you might need to uncomment these lines and change" | cat >>krb5.conf
echo "# the enctypes is if you have local software that will break on ticket" | cat >>krb5.conf
echo "# caches containing ticket encryption types it doesn't know about (such as" | cat >>krb5.conf
echo "# old versions of Sun Java)." | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "#	default_tgs_enctypes = des3-hmac-sha1" | cat >>krb5.conf
echo "#	default_tkt_enctypes = des3-hmac-sha1" | cat >>krb5.conf
echo "#	permitted_enctypes = des3-hmac-sha1" | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "# The following libdefaults parameters are only for Heimdal Kerberos." | cat >>krb5.conf
echo "	v4_instance_resolve = false" | cat >>krb5.conf
echo "	v4_name_convert = {" | cat >>krb5.conf
echo "		host = {" | cat >>krb5.conf
echo "			rcmd = host" | cat >>krb5.conf
echo "			ftp = ftp" | cat >>krb5.conf
echo "		}" | cat >>krb5.conf
echo "		plain = {" | cat >>krb5.conf
echo "			something = something-else" | cat >>krb5.conf
echo "		}" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	fcc-mit-ticketflags = true" | cat >>krb5.conf
echo "        " | cat >>krb5.conf
echo "[realms]" | cat >>krb5.conf
echo "  	$realm = {" | cat >>krb5.conf
echo "        	kdc = $kdc" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "        	admin_server = $admin_server" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "        	default_domain = $fullname" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "        	database_module = openldap_ldapconf" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "  	}" | cat >>krb5.conf
echo "	ATHENA.MIT.EDU = {" | cat >>krb5.conf
echo "		kdc = kerberos.mit.edu:88" | cat >>krb5.conf
echo "		kdc = kerberos-1.mit.edu:88" | cat >>krb5.conf
echo "		kdc = kerberos-2.mit.edu:88" | cat >>krb5.conf
echo "		admin_server = kerberos.mit.edu" | cat >>krb5.conf
echo "		default_domain = mit.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	MEDIA-LAB.MIT.EDU = {" | cat >>krb5.conf
echo "		kdc = kerberos.media.mit.edu" | cat >>krb5.conf
echo "		admin_server = kerberos.media.mit.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	ZONE.MIT.EDU = {" | cat >>krb5.conf
echo "		kdc = casio.mit.edu" | cat >>krb5.conf
echo "		kdc = seiko.mit.edu" | cat >>krb5.conf
echo "		admin_server = casio.mit.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	MOOF.MIT.EDU = {" | cat >>krb5.conf
echo "		kdc = three-headed-dogcow.mit.edu:88" | cat >>krb5.conf
echo "		kdc = three-headed-dogcow-1.mit.edu:88" | cat >>krb5.conf
echo "		admin_server = three-headed-dogcow.mit.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	CSAIL.MIT.EDU = {" | cat >>krb5.conf
echo "		kdc = kerberos-1.csail.mit.edu" | cat >>krb5.conf
echo "		kdc = kerberos-2.csail.mit.edu" | cat >>krb5.conf
echo "		admin_server = kerberos.csail.mit.edu" | cat >>krb5.conf
echo "		default_domain = csail.mit.edu" | cat >>krb5.conf
echo "		krb524_server = krb524.csail.mit.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	IHTFP.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.ihtfp.org" | cat >>krb5.conf
echo "		admin_server = kerberos.ihtfp.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	GNU.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.gnu.org" | cat >>krb5.conf
echo "		kdc = kerberos-2.gnu.org" | cat >>krb5.conf
echo "		kdc = kerberos-3.gnu.org" | cat >>krb5.conf
echo "		admin_server = kerberos.gnu.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	1TS.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.1ts.org" | cat >>krb5.conf
echo "		admin_server = kerberos.1ts.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	GRATUITOUS.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.gratuitous.org" | cat >>krb5.conf
echo "		admin_server = kerberos.gratuitous.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	DOOMCOM.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.doomcom.org" | cat >>krb5.conf
echo "		admin_server = kerberos.doomcom.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	ANDREW.CMU.EDU = {" | cat >>krb5.conf
echo "		kdc = vice28.fs.andrew.cmu.edu" | cat >>krb5.conf
echo "		kdc = vice2.fs.andrew.cmu.edu" | cat >>krb5.conf
echo "		kdc = vice11.fs.andrew.cmu.edu" | cat >>krb5.conf
echo "		kdc = vice12.fs.andrew.cmu.edu" | cat >>krb5.conf
echo "		admin_server = vice28.fs.andrew.cmu.edu" | cat >>krb5.conf
echo "		default_domain = andrew.cmu.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	CS.CMU.EDU = {" | cat >>krb5.conf
echo "		kdc = kerberos.cs.cmu.edu" | cat >>krb5.conf
echo "		kdc = kerberos-2.srv.cs.cmu.edu" | cat >>krb5.conf
echo "		admin_server = kerberos.cs.cmu.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	DEMENTIA.ORG = {" | cat >>krb5.conf
echo "		kdc = kerberos.dementia.org" | cat >>krb5.conf
echo "		kdc = kerberos2.dementia.org" | cat >>krb5.conf
echo "		admin_server = kerberos.dementia.org" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "	stanford.edu = {" | cat >>krb5.conf
echo "		kdc = krb5auth1.stanford.edu" | cat >>krb5.conf
echo "		kdc = krb5auth2.stanford.edu" | cat >>krb5.conf
echo "		kdc = krb5auth3.stanford.edu" | cat >>krb5.conf
echo "		master_kdc = krb5auth1.stanford.edu" | cat >>krb5.conf
echo "		admin_server = krb5-admin.stanford.edu" | cat >>krb5.conf
echo "		default_domain = stanford.edu" | cat >>krb5.conf
echo "	}" | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "[domain_realm]" | cat >>krb5.conf
echo "	.$fullname = $realm" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "	$fullname = $realm" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "	.mit.edu = ATHENA.MIT.EDU" | cat >>krb5.conf
echo "	mit.edu = ATHENA.MIT.EDU" | cat >>krb5.conf
echo "	.media.mit.edu = MEDIA-LAB.MIT.EDU" | cat >>krb5.conf
echo "	media.mit.edu = MEDIA-LAB.MIT.EDU" | cat >>krb5.conf
echo "	.csail.mit.edu = CSAIL.MIT.EDU" | cat >>krb5.conf
echo "	csail.mit.edu = CSAIL.MIT.EDU" | cat >>krb5.conf
echo "	.whoi.edu = ATHENA.MIT.EDU" | cat >>krb5.conf
echo "	whoi.edu = ATHENA.MIT.EDU" | cat >>krb5.conf
echo "	.stanford.edu = stanford.edu" | cat >>krb5.conf
echo "	.slac.stanford.edu = SLAC.STANFORD.EDU" | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "[login]" | cat >>krb5.conf
echo "	krb4_convert = true" | cat >>krb5.conf
echo "	krb4_get_tickets = false" | cat >>krb5.conf

sudo cp -v /etc/krb5.conf /etc/krb5.conf-$date
sudo cp -v krb5.conf /etc/krb5.conf

# Install client packages
sudo apt-get update
sudo apt-get -y --force-yes install sssd libsss-sudo krb5-user nfs-common autofs

# Generate sssd.conf file 
echo "[sssd]" | cat >>sssd.conf
echo "config_file_version = 2" | cat >>sssd.conf
echo "reconnection_retries = 3" | cat >>sssd.conf
echo "sbus_timeout = 30" | cat >>sssd.conf
echo "services = nss, pam, sudo" | cat >>sssd.conf
echo "domains = $fullname" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "[nss]" | cat >>sssd.conf
echo "filter_groups = root" | cat >>sssd.conf
echo "filter_users = root" | cat >>sssd.conf
echo "reconnection_retries = 3" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "[pam]" | cat >>sssd.conf
echo "reconnection_retries = 3" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "[domain/$fullname]" | cat >>sssd.conf
echo "; Using enumerate = true leads to high load and slow response" | cat >>sssd.conf
echo "enumerate = false" | cat >>sssd.conf
echo "cache_credentials = false" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "id_provider = ldap" | cat >>sssd.conf
echo "auth_provider = krb5" | cat >>sssd.conf
echo "chpass_provider = krb5" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "ldap_uri = ldap://ldap.$fullname" | cat >>sssd.conf
echo "ldap_search_base = dc=$domain,dc=$suffix" | cat >>sssd.conf
echo "ldap_sudo_search_base = ou=sudoers,dc=$domain,dc=$suffix" | cat >>sssd.conf
echo "ldap_tls_reqcert = never" | cat >>sssd.conf
echo " " | cat >>sssd.conf
echo "krb5_kdcip = $kdc" | cat >>sssd.conf
echo "krb5_realm = $realm" | cat >>sssd.conf
echo "krb5_changepw_principle = kadmin/changepw" | cat >>sssd.conf
echo "krb5_auth_timeout = 15" | cat >>sssd.conf
echo "krb5_renewable_lifetime = 5d" | cat >>sssd.conf

sudo cp -v sssd.conf /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo service sssd restart

# re configure kerberos
#sudo dpkg-reconfigure krb5-config

# Create a kerberos principal for NFS on the client
echo ""
echo "Creating Kerberos Principal NFS for $hostname.$fullname"
read -p "Press Enter to continue..." key
kadmin -p $kdcadmin/admin -q "addprinc -randkey nfs/$hostname.$fullname"

# Add principal created on the server, to keytab file on client:
sudo kadmin -p $kdcadmin/admin -q "ktadd nfs/$hostname.$fullname"

# Configure NFS
cat /etc/default/nfs-common | sed 's/NEED_GSSD=/NEED_GSSD=yes/' | cat >nfs-common
sudo cp -v /etc/default/nfs-common /etc/default/nfs-default-$date
sudo cp -v nfs-common /etc/default/nfs-common
sudo chown root:root /etc/default/nfs-common
sudo chmod 644 /etc/default/nfs-common

# Configure AutoFS
cat /etc/default/autofs | sed 's/BROWSE_MODE="no"/BROWSE_MODE="yes"/' \
| sed 's/#MOUNT_NFS_DEFAULT_PROTOCOL=3/MOUNT_NFS_DEFAULT_PROTOCOL=4/' \
| sed 's/#LOGGING="none"/LOGGING="verbose"/' | cat >autofs
sudo cp -v /etc/default/autofs /etc/default/autofs-$date
sudo cp -v autofs /etc/default/autofs
sudo chown root:root /etc/default/autofs
sudo chmod 644 /etc/default/autofs

# Configure auto.master config file
sudo cp -v /etc/auto.master /etc/auto.master-$date
sudo echo "/home	/etc/auto.home" | cat >auto.master
sudo echo "/mnt	/etc/auto.data" | cat >>auto.master
sudo cp -v auto.master /etc/auto.master
sudo chown root:root /etc/auto.master
sudo chmod 644 /etc/auto.master

# Make auto.home config file
echo "*   -fstype=nfs4,rw,hard,intr,sec=krb5   $fqdn:/home/&" | cat >auto.home
sudo cp -v auto.home /etc/auto.home
sudo chown root:root /etc/auto.home
sudo chmod 644 /etc/auto.home

# Make auto.data for main data share
echo "data   -fstype=nfs4,rw,hard,intr,sec=krb5   $fqdn:/data" | cat >auto.data
sudo cp -v auto.data /etc/auto.data
sudo chown root:root /etc/auto.data
sudo chmod 644 /etc/auto.data

# Setting LDAP sudo users to access graphical apps for adminstration
echo "[Configuration]" | cat >51-ubuntu-admin.conf
echo "AdminIdentities=unix-group:sudo;unix-group:admin;unix-group:$gidstart" | cat >>51-ubuntu-admin.conf
sudo cp -v sudo 51-ubuntu-admin.conf /etc/polkit-1/localauthority.conf.d/51-ubuntu-admin.conf
sudo chown root:root /etc/polkit-1/localauthority.conf.d/51-ubuntu-admin.conf
sudo chmod 644 /etc/polkit-1/localauthority.conf.d/51-ubuntu-admin.conf

# Configure Login Screen
echo "[SeatDefaults]" | cat >lightdm.conf
echo "user-session=ubuntu" | cat >>lightdm.conf
echo "greeter-session=unity-greeter" | cat >>lightdm.conf
echo "greeter-show-manual-login=true" | cat >>lightdm.conf
echo "greeter-hide-users=false" | cat >>lightdm.conf
echo "allow-guest=false" | cat >>lightdm.conf
sudo cp -v lightdm.conf /etc/lightdm/lightdm.conf
sudo chown root:root /etc/lightdm/lightdm.conf
sudo chmod 644 /etc/lightdm/lightdm.conf

echo "Client config complete..."
read -p "Press Enter to reboot..." key

currentuser=$(id -un)
echo "!#/bin/sh" | cat >K99_removeuser
echo "userdel -r $currentuser" | cat >>K99_removeuser
echo "rm -rf /etc/rc6.d/K99_removeuser" cat >>K99_removeuser
sudo cp -v K99_removeuser /etc/rc6.d/
sudo chmod +x /etc/rc6.d/K99_removeuser

sudo reboot