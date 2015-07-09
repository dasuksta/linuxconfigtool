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
#         NAME: service-nfs.sh
#      CREATED: 26-11-2014
#      REVISED: 21-06-2015
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
internalnetwork=`cat <$log | grep "internalnetwork =" | awk '{print $3}'`
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
kdcadmin=`cat <$log | grep "kdcadmin =" | awk '{print $3}'`

# Suggest primary share location
echo "/mnt/data" | cat >mainshare.temp
mainshare=`cat <mainshare.temp`

# Whiptail input box where user can enter value
module='Primary Share Location'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the location of Primary Network Share

Please enter the location within the Local file system of the the Primary Network Share, \
that will be Exported to *NIX clients using NFS (Network File System), and with Windows \
clients, if you opt to setup Samba.

NOTE: The /home directory of this system be shared by default to the internal network, you \
can change this by editing the /etc/exports file.

NFS Server: $fqdn
Internal Network: $internalnetwork/24
Suggested Export Path: $mainshare

Please enter the Local Filsystem Share Path:" 24 68 $mainshare 2>mainshare.temp

# FUNCTION CHECK - for NULL entry
mainshare=`cat <mainshare.temp`
{
   	if [ "$mainshare" = "" ] ; then
  		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-nfs.sh
    else
		continue
    fi
}

# Create primary share location folder and create test files
sudo mkdir -p $mainshare
sudo mkdir "$mainshare"/test_folder
sudo touch "$mainshare"/test_file.txt
sudo chmod -Rv 777 $mainshare
# Make log entry for primary share
echo "mainshare = $mainshare" | cat >>$log

# Set global read/write/execute permissions from primary share root down...
#cut -d '/' -f2 mainshare.temp | cat >mountroot.temp
#mountroot=`cat <mountroot.temp`
#sudo chmod -Rv 777 /$mountroot/*

echo ""
echo "Installing NFS server..."
sleep 1
sudo apt-get -y --force-yes install nfs-kernel-server nfs-common

echo ""
echo "Creating NFS export folders folder"
sleep 1
sudo mkdir /export
sudo mkdir /export/home
sudo mkdir /export/data

# Grab /etc/fstab and make entry to mount exports
cat /etc/fstab | cat >fstab
echo "/home    /export/home   none    bind  0  0" | cat >>fstab
echo "$mainshare	/export/data	none	bind	0  0" | cat >>fstab
sudo cp fstab /etc/fstab
sudo chown root:root /etc/fstab
sudo chmod 644 /etc/fstab

# Generate /etc/exports config file
echo "/export *(rw,fsid=0,crossmnt,insecure,async,no_subtree_check,sec=krb5p:krb5i:krb5)" | cat >exports
echo "/export/home *(rw,insecure,async,no_subtree_check,sec=krb5p:krb5i:krb5)" | cat >>exports
echo "/export/data *(rw,insecure,async,no_subtree_check,sec=krb5p:krb5i:krb5)" | cat >>exports
sudo cp -v /etc/exports /etc/exports-$date
sudo cp -v exports /etc/exports
sudo chmod 644 /etc/exports

# Generate LDAP entry for mount
echo "dn: cn=/data,ou=auto.master,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >datamount.ldif
echo "cn: $mainshare" | cat >>datamount.ldif
echo "objectClass: top" | cat >>datamount.ldif
echo "objectClass: automount" | cat >>datamount.ldif
echo "automountInformation: ldap:ou=auto.data,ou=automount,ou=admin,dc=$domain,dc=$suffix --timeout=60 --ghost" | cat >>datamount.ldif
echo "" | cat >>datamount.ldif
echo "dn: ou=auto.data,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>datamount.ldif
echo "ou: auto.data" | cat >>datamount.ldif
echo "objectClass: top" | cat >>datamount.ldif
echo "objectClass: automountMap" | cat >>datamount.ldif
echo "" | cat >>datamount.ldif
echo "dn: cn=/,ou=auto.data,ou=automount,ou=admin,dc=$domain,dc=$suffix" | cat >>datamount.ldif
echo "cn: /" | cat >>datamount.ldif
echo "objectClass: top" | cat >>datamount.ldif
echo "objectClass: automount" | cat >>datamount.ldif
echo "automountInformation: -fstype=nfs4,rw,hard,intr,fsc,sec=krb5 $fqdn:/data" | cat >>datamount.ldif
echo ""
echo "Adding datamount.ldif into LDAP Server"
echo ""
sudo ldapadd -x -D cn=admin,dc=$domain,dc=$suffix -w $ldappasswd -f datamount.ldif
sleep 2

# make changes to the /etc/default/nfs-common file
cat /etc/default/nfs-common | sed 's/NEED_GSSD=/NEED_GSSD=yes/' | cat >nfs-common
sudo cp -v /etc/default/nfs-common /etc/default/nfs-default-$date
sudo cp -v nfs-common /etc/default/nfs-common
sudo chown root:root /etc/default/nfs-common
sudo chmod 644 /etc/default/nfs-common

# Make changes to /etc/default/nfs-kernel-server file
cat /etc/default/nfs-kernel-server \
| sed 's/RPCNFSDCOUNT=8/RPCNFSDCOUNT=16/' \
| sed 's/NEED_SVCGSSD=""/NEED_SVCGSSD="yes"/' \
| cat >nfs-kernel-server
sudo cp -v /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server-$date
sudo cp -v nfs-kernel-server /etc/default/nfs-kernel-server
sudo chown root:root /etc/default/nfs-kernel-server
sudo chmod 644  /etc/default/nfs-kernel-server
sleep 2

echo ""
echo "adding nfs kerberos principal"
sleep 1
sudo kadmin.local -q "addprinc -randkey nfs/$fqdn"
echo ""
sudo kadmin.local -q "ktadd nfs/$fqdn"
sleep 2

# Generating client.info reference file for ubuntu-client.sh script
echo "server = $hostname" | cat >client.info
echo "domain = $domain" | cat >>client.info
echo "suffix = $suffix" | cat >>client.info
echo "fullname = $fullname" | cat >>client.info
echo "fqdn = $fqdn" | cat >>client.info
echo "gidstart = $gidstart" | cat >>client.info
echo "realm = $realm" | cat >>client.info
echo "kdc = $kdc" | cat >>client.info
echo "admin_server = $admin_server" | cat >>client.info
echo "kdcadmin = $kdcadmin" | cat >>client.info
echo "mainshare = $mainshare" | cat >>client.info

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "NFS Server: Enabled" | cat >>$notes
echo "Main Data Path: $mainshare" | cat >>$notes

sleep 2