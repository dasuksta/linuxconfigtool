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


sudo apt-get -y --force-yes install samba libpam-smbpass

echo "Creating Kerberos principals for Samba"
echo ""
sudo kadmin.local -q "addprinc -randkey cifs/$fqdn"
sleep 1
echo ""
sudo kadmin.local -q "addprinc -randkey cifs/$hostname"
sleep 1
echo ""
sudo kadmin.local -q "ktadd -k /etc/krb5.keytab -e rc4-hmac:normal cifs/$fqdn"
sleep 1
echo ""
sudo kadmin.local -q "ktadd -k /etc/krb5.keytab -e rc4-hmac:normal cifs/$hostname"
sleep 1

# Generate smb.conf
echo "#" | cat >smb.conf
echo "# Sample configuration file for the Samba suite for Debian GNU/Linux." | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "# This is the main Samba configuration file. You should read the" | cat >>smb.conf
echo "# smb.conf(5) manual page in order to understand the options listed" | cat >>smb.conf
echo "# here. Samba has a huge number of configurable options most of which " | cat >>smb.conf
echo "# are not shown in this example" | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "# Some options that are often worth tuning have been included as" | cat >>smb.conf
echo "# commented-out examples in this file." | cat >>smb.conf
echo "#  - When such options are commented with \";\", the proposed setting" | cat >>smb.conf
echo "#    differs from the default Samba behaviour" | cat >>smb.conf
echo "#  - When commented with \"#\", the proposed setting is the default" | cat >>smb.conf
echo "#    behaviour of Samba but the option is considered important" | cat >>smb.conf
echo "#    enough to be mentioned here" | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "# NOTE: Whenever you modify this file you should run the command" | cat >>smb.conf
echo "# \"testparm\" to check that you have not made any basic syntactic " | cat >>smb.conf
echo "# errors. " | cat >>smb.conf
echo "" | cat >>smb.conf
echo "#======================= Global Settings =======================" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "[global]" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "## Browsing/Identification ###" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Change this to the workgroup/NT-domain name your Samba server will part of" | cat >>smb.conf
echo "   workgroup = $fullname" | cat >>smb.conf
echo "   security = user" | cat >>smb.conf
echo "   realm = $realm" | cat >>smb.conf
echo "   kerberos method = system keytab" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# server string is the equivalent of the NT Description field" | cat >>smb.conf
echo "	server string = %h server (Samba, Ubuntu)" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Windows Internet Name Serving Support Section:" | cat >>smb.conf
echo "# WINS Support - Tells the NMBD component of Samba to enable its WINS Server" | cat >>smb.conf
echo "#   wins support = no" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# WINS Server - Tells the NMBD components of Samba to be a WINS Client" | cat >>smb.conf
echo "# Note: Samba can be either a WINS Server, or a WINS Client, but NOT both" | cat >>smb.conf
echo ";   wins server = w.x.y.z" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This will prevent nmbd to search for NetBIOS names through DNS." | cat >>smb.conf
echo "   dns proxy = no" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "#### Networking ####" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# The specific set of interfaces / networks to bind to" | cat >>smb.conf
echo "# This can be either the interface name or an IP address/netmask;" | cat >>smb.conf
echo "# interface names are normally preferred" | cat >>smb.conf
echo ";   interfaces = 127.0.0.0/8 eth0" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Only bind to the named interfaces and/or networks; you must use the" | cat >>smb.conf
echo "# 'interfaces' option above to use this." | cat >>smb.conf
echo "# It is recommended that you enable this feature if your Samba machine is" | cat >>smb.conf
echo "# not protected by a firewall or is a firewall itself.  However, this" | cat >>smb.conf
echo "# option cannot handle dynamic or non-broadcast interfaces correctly." | cat >>smb.conf
echo ";   bind interfaces only = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "#### Debugging/Accounting ####" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This tells Samba to use a separate log file for each machine" | cat >>smb.conf
echo "# that connects" | cat >>smb.conf
echo "   log file = /var/log/samba/log.%m" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Cap the size of the individual log files (in KiB)." | cat >>smb.conf
echo "   max log size = 1000" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# If you want Samba to only log through syslog then set the following" | cat >>smb.conf
echo "# parameter to 'yes'." | cat >>smb.conf
echo "#   syslog only = no" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# We want Samba to log a minimum amount of information to syslog. Everything" | cat >>smb.conf
echo "# should go to /var/log/samba/log.{smbd,nmbd} instead. If you want to log" | cat >>smb.conf
echo "# through syslog you should set the following parameter to something higher." | cat >>smb.conf
echo "   syslog = 0" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Do something sensible when Samba crashes: mail the admin a backtrace" | cat >>smb.conf
echo "   panic action = /usr/share/samba/panic-action %d" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "####### Authentication #######" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Server role. Defines in which mode Samba will operate. Possible" | cat >>smb.conf
echo "# values are \"standalone server\", \"member server\", \"classic primary" | cat >>smb.conf
echo "# domain controller\", \"classic backup domain controller\", \"active" | cat >>smb.conf
echo "# directory domain controller\". " | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "# Most people will want \"standalone sever\" or \"member server\"." | cat >>smb.conf
echo "# Running as \"active directory domain controller\" will require first" | cat >>smb.conf
echo "# running \"samba-tool domain provision\" to wipe databases and create a" | cat >>smb.conf
echo "# new domain." | cat >>smb.conf
echo "   server role = classic primary domain controller" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# If you are using encrypted passwords, Samba will need to know what" | cat >>smb.conf
echo "# password database type you are using.  " | cat >>smb.conf
echo "   passdb backend = tdbsam" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "   obey pam restrictions = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This boolean parameter controls whether Samba attempts to sync the Unix" | cat >>smb.conf
echo "# password with the SMB password when the encrypted SMB password in the" | cat >>smb.conf
echo "# passdb is changed." | cat >>smb.conf
echo "   unix password sync = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# For Unix password sync to work on a Debian GNU/Linux system, the following" | cat >>smb.conf
echo "# parameters must be set (thanks to Ian Kahan <<kahan@informatik.tu-muenchen.de> for" | cat >>smb.conf
echo "# sending the correct chat script for the passwd program in Debian Sarge)." | cat >>smb.conf
echo "   passwd program = /usr/bin/passwd %u" | cat >>smb.conf
echo "   passwd chat = *Enter\\\snew\\\s*\\\spassword:* %n\\\n *Retype\\\snew\\\s*\\\spassword:* %n\\\n *password\\\supdated\\\ssuccessfully* ." | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This boolean controls whether PAM will be used for password changes" | cat >>smb.conf
echo "# when requested by an SMB client instead of the program listed in" | cat >>smb.conf
echo "# 'passwd program'. The default is 'no'." | cat >>smb.conf
echo "   pam password change = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This option controls how unsuccessful authentication attempts are mapped" | cat >>smb.conf
echo "# to anonymous connections" | cat >>smb.conf
echo "   map to guest = bad user" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "########## Domains ###########" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "#" | cat >>smb.conf
echo "# The following settings only takes effect if 'server role = primary" | cat >>smb.conf
echo "# classic domain controller', 'server role = backup domain controller'" | cat >>smb.conf
echo "# or 'domain logons' is set " | cat >>smb.conf
echo "domain logons = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# It specifies the location of the user's" | cat >>smb.conf
echo "# profile directory from the client point of view) The following" | cat >>smb.conf
echo "# required a [profiles] share to be setup on the samba server (see" | cat >>smb.conf
echo "# below)" | cat >>smb.conf
echo ";   logon path = \\\\\\%N\\\profiles\\\%U" | cat >>smb.conf
echo "# Another common choice is storing the profile in the user's home directory" | cat >>smb.conf
echo "# (this is Samba's default)" | cat >>smb.conf
echo "   logon path = \\\\\\%N\\\%U\\\profile" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# The following setting only takes effect if 'domain logons' is set" | cat >>smb.conf
echo "# It specifies the location of a user's home directory (from the client" | cat >>smb.conf
echo "# point of view)" | cat >>smb.conf
echo "   logon drive = H:" | cat >>smb.conf
echo "   logon home = \\\\\\%N\\\%U" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# The following setting only takes effect if 'domain logons' is set" | cat >>smb.conf
echo "# It specifies the script to run during logon. The script must be stored" | cat >>smb.conf
echo "# in the [netlogon] share" | cat >>smb.conf
echo "# NOTE: Must be store in 'DOS' file format convention" | cat >>smb.conf
echo "   logon script = logon.cmd" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This allows Unix users to be created on the domain controller via the SAMR" | cat >>smb.conf
echo "# RPC pipe.  The example command creates a user account with a disabled Unix" | cat >>smb.conf
echo "# password; please adapt to your needs" | cat >>smb.conf
echo "; add user script = /usr/sbin/adduser --quiet --disabled-password --gecos \"\" %u" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This allows machine accounts to be created on the domain controller via the " | cat >>smb.conf
echo "# SAMR RPC pipe.  " | cat >>smb.conf
echo "# The following assumes a \"machines\" group exists on the system" | cat >>smb.conf
echo " add machine script  = /usr/sbin/useradd -g machines -c \"%u machine account\" -d /var/lib/samba -s /bin/false %u" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# This allows Unix groups to be created on the domain controller via the SAMR" | cat >>smb.conf
echo "# RPC pipe.  " | cat >>smb.conf
echo "; add group script = /usr/sbin/addgroup --force-badname %g" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "############ Misc ############" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Using the following line enables you to customise your configuration" | cat >>smb.conf
echo "# on a per machine basis. The %m gets replaced with the netbios name" | cat >>smb.conf
echo "# of the machine that is connecting" | cat >>smb.conf
echo ";   include = /home/samba/etc/smb.conf.%m" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Some defaults for winbind (make sure you're not using the ranges" | cat >>smb.conf
echo "# for something else.)" | cat >>smb.conf
echo ";   idmap uid = 10000-20000" | cat >>smb.conf
echo ";   idmap gid = 10000-20000" | cat >>smb.conf
echo ";   template shell = /bin/bash" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Setup usershare options to enable non-root users to share folders" | cat >>smb.conf
echo "# with the net usershare command." | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Maximum number of usershare. 0 (default) means that usershare is disabled." | cat >>smb.conf
echo ";   usershare max shares = 100" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Allow users who've been granted usershare privileges to create" | cat >>smb.conf
echo "# public shares, not just authenticated ones" | cat >>smb.conf
echo "   usershare allow guests = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "#======================= Share Definitions =======================" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Un-comment the following (and tweak the other settings below to suit)" | cat >>smb.conf
echo "# to enable the default home directory shares. This will share each" | cat >>smb.conf
echo "# user's home directory as \\\\\\server\\\username" | cat >>smb.conf
echo "[homes]" | cat >>smb.conf
echo "   comment = Home Directories" | cat >>smb.conf
echo "   browseable = no" | cat >>smb.conf
echo "   read only = no" | cat >>smb.conf
echo "   valid users = %S" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# By default, the home directories are exported read-only. Change the" | cat >>smb.conf
echo "# next parameter to 'no' if you want to be able to write to them." | cat >>smb.conf
echo ";   read only = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# File creation mask is set to 0700 for security reasons. If you want to" | cat >>smb.conf
echo "# create files with group=rw permissions, set next parameter to 0775." | cat >>smb.conf
echo ";   create mask = 0700" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Directory creation mask is set to 0700 for security reasons. If you want to" | cat >>smb.conf
echo "# create dirs. with group=rw permissions, set next parameter to 0775." | cat >>smb.conf
echo ";   directory mask = 0700" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# By default, \\\\\\server\\\username shares can be connected to by anyone" | cat >>smb.conf
echo "# with access to the samba server." | cat >>smb.conf
echo "# Un-comment the following parameter to make sure that only \"username\"" | cat >>smb.conf
echo "# can connect to \\\\\\server\\\username" | cat >>smb.conf
echo "# This might need tweaking when using external authentication schemes" | cat >>smb.conf
echo ";   valid users = %S" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Un-comment the following and create the netlogon directory for Domain Logons" | cat >>smb.conf
echo "# (you need to configure Samba to act as a domain controller too.)" | cat >>smb.conf
echo "[netlogon]" | cat >>smb.conf
echo "   comment = Network Logon Service" | cat >>smb.conf
echo "   path = /home/samba/netlogon" | cat >>smb.conf
echo "   guest ok = yes" | cat >>smb.conf
echo "   read only = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Un-comment the following and create the profiles directory to store" | cat >>smb.conf
echo "# users profiles (see the \"logon path\" option above)" | cat >>smb.conf
echo "# (you need to configure Samba to act as a domain controller too.)" | cat >>smb.conf
echo "# The path below should be writable by all users so that their" | cat >>smb.conf
echo "# profile directory may be created the first time they log on" | cat >>smb.conf
echo ";[profiles]" | cat >>smb.conf
echo ";   comment = Users profiles" | cat >>smb.conf
echo ";   path = /home/samba/profiles" | cat >>smb.conf
echo ";   guest ok = no" | cat >>smb.conf
echo ";   browseable = no" | cat >>smb.conf
echo ";   create mask = 0600" | cat >>smb.conf
echo ";   directory mask = 0700" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "[printers]" | cat >>smb.conf
echo "   comment = All Printers" | cat >>smb.conf
echo "   browseable = no" | cat >>smb.conf
echo "   path = /var/spool/samba" | cat >>smb.conf
echo "   printable = yes" | cat >>smb.conf
echo "   guest ok = no" | cat >>smb.conf
echo "   read only = yes" | cat >>smb.conf
echo "   create mask = 0700" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "# Windows clients look for this share name as a source of downloadable" | cat >>smb.conf
echo "# printer drivers" | cat >>smb.conf
echo "[print$]" | cat >>smb.conf
echo "   comment = Printer Drivers" | cat >>smb.conf
echo "   path = /var/lib/samba/printers" | cat >>smb.conf
echo "   browseable = yes" | cat >>smb.conf
echo "   read only = yes" | cat >>smb.conf
echo "   guest ok = no" | cat >>smb.conf
echo "# Uncomment to allow remote administration of Windows print drivers." | cat >>smb.conf
echo "# You may need to replace 'lpadmin' with the name of the group your" | cat >>smb.conf
echo "# admin users are members of." | cat >>smb.conf
echo "# Please note that you also need to set appropriate Unix permissions" | cat >>smb.conf
echo "# to the drivers directory for these users to have write rights in it" | cat >>smb.conf
echo ";   write list = root, @lpadmin" | cat >>smb.conf
# Adding main NFS share location and Public shares to /etc/samba/smb.conf
echo "" | cat >>smb.conf
echo "[data]" | cat >>smb.conf
echo "   comment = Data Share" | cat >>smb.conf
echo "   path = $mainshare" | cat >>smb.conf
echo "   available = yes" | cat >>smb.conf
echo "   browsable = yes" | cat >>smb.conf
echo "   writable = yes" | cat >>smb.conf
echo "   create mask = 0700" | cat >>smb.conf
echo "   hide dot files = yes" | cat >>smb.conf
echo "   hide files = *~" | cat >>smb.conf
echo "   vfs objects = recycle" | cat >>smb.conf
echo "   recycle:repository = .recycle" | cat >>smb.conf
echo "   recycle:keeptree = yes" | cat >>smb.conf
echo "   recycle:versions = yes" | cat >>smb.conf
echo "" | cat >>smb.conf
echo "[public]" | cat >>smb.conf
echo "  comment = Public Share" | cat >>smb.conf
echo "  path = /mnt/public" | cat >>smb.conf
echo "  public = yes" | cat >>smb.conf
echo "  browsable = yes" | cat >>smb.conf
echo "  guest ok = yes" | cat >>smb.conf
echo "  create mask = 0777" | cat >>smb.conf
echo "  hide dot files = yes" | cat >>smb.conf
echo "  hide files = /*~/" | cat >>smb.conf
echo "  vfs objects = recycle" | cat >>smb.conf
echo "  recycle:repository = .recycle" | cat >>smb.conf
echo "  recycle:keeptree = yes" | cat >>smb.conf
echo "  recycle:versions = yes" | cat >>smb.conf

# Make Public share
sudo mkdir /mnt/public
sudo chmod 777 /mnt/public

# Removing Startup scripts form the Newer Smaba4 PDC stuff"
sudo update-rc.d -f samba remove
sudo update-rc.d -f samba-ad-dc remove
sleep 2

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf-$date
sudo cp smb.conf /etc/samba/smb.conf

echo ""
echo "Creating file locations for Win logins"
sleep 1
sudo mkdir -p /home/samba/netlogon
sudo touch /home/samba/netlogon/logon.cmd

echo ""
echo "Restarting Samba services"
sleep 1 
sudo service smbd restart
sudo service nmbd restart

echo ""
echo "Adding the \"machines\" group to LDAP"
sleep 1
sudo ldapaddgroup machines

echo ""
echo "Mapping the UINX Group: $netadmingrp to Windows Group: Domain Admins"
sleep 1
sudo net groupmap add ntgroup="Domain Admins" unixgroup=$netadmingrp rid=512 type=d

echo ""
echo "To add Windows systems to the Network Domain, we need to grant"
echo "privileges to the Network Administrator: $netadmin"
echo ""
sleep 1
# Creating script to be executed over local ssh - giving Network Administrator
# permissions to add systems.
echo "#!/bin/sh" | cat >smbrights.sh
echo "net rpc rights grant -U $netadmin \"$fullname\\\Domain Admins\" SeMachineAccountPrivilege SePrintOperatorPrivilege SeAddUsersPrivilege SeDiskOperatorPrivilege SeRemoteShutdownPrivilege" | cat >>smbrights.sh
# Copy the generate smbrights.sh script into $netadmins home
sudo cp smbrights.sh /home/$netadmin
sudo chown $netadmin:$netadmingrp /home/$netadmin/smbrights.sh
sudo chmod +x /home/$netadmin/smbrights.sh 

ssh $netadmin@localhost './smbrights.sh'

sleep 2
# cp *.reg /mnt/public/

#net rpc rights grant -U $netadmin "$fullname\Domain Admins" SeMachineAccountPrivilege SePrintOperatorPrivilege SeAddUsersPrivilege SeDiskOperatorPrivilege SeRemoteShutdownPrivilege
#smbpriv=`cat <smbpriv.temp`
#ssh $netadmin@localhost '$smbpriv'

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "SMB Server: Enabled" | cat >>$notes
echo "Domain Admins UNIX Group: $netadmingrp" | cat >>$notes
echo "Main Data Path: $mainshare" | cat >>$notes
echo "Public Share Path: /mnt/public" | cat >>$notes
echo ""

# Removing .temp files
rm -rf *.temp