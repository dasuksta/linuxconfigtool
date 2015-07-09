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
#         NAME: install-lam.sh
#      CREATED: 25-10-2014
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

# Whiptail input box where user can enter value
module='LAM Administrator'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
LDAP Account Manager (LAM) requires a user account for adminstering the LDAP server. For \
security reasons, both the local System Administrator and LDAP Administrator cannot be used.

For conveince the installer has suggested the Network Administrator to be configured as the \
LDAP Account Manager admin user, however you can change this to what you prefer.

Please enter LDAP Account Manager admin user" 18 68 "$netadmin" 2>lamadmin.temp

# Set variable
lamadmin=`cat <lamadmin.temp`
	# Check for null entry
	{
    	if [ "$lamadmin" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./install-lam.sh
        else
	    	continue
    	fi
	}

# Whiptail input box where user can enter value
module='LAM Administrator Password'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --passwordbox --nocancel "
Please enter the password you would like to use for the LDAP Account Manager Administrator.

LAM Administrator: cn=$lamadmin,dc=$domain,dc=$suffix

NOTE: For conveinece the installer has taken the Network Administrator password - this is NOT \
recommned in a production enviroment!

Please enter Network Administrator password:" 18 68 "$netadminpasswd" 2>passwd1.temp

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

# whiptail input box where user can re-enter value
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
        echo $passwd2 | cat >lamadmin.passwd
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
lampasswd=`cat <lamadmin.passwd`

# Whiptail input box where user can enter value
module='LDAP Account Manager Group'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
LDAP Account Manager can also be assigned its own unique group, this might be helpful in \
larger deployments where access can be disrubited for different system administrators.

NOTE: For conveinece the LAM Admininstrator the installer has selecetd the Network \
Administrators Group, however you can change this to what you prefer.

Please enter the name for the LAM Administrators Group:" 16 68 "$netadmingrp" 2>lamgroup.temp

# Set variable
lamgroup=`cat <lamgroup.temp`
	# Check for null entry
	{
    	if [ "$lamgroup" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./install-lam.sh
        else
	    	continue
    	fi
	}

# Whiptail info box to show configuration and apply changes
module='LDAP Account Manager'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --msgbox "
LDAP Account Manager configuration summary, you will be able to access the LDAP Account \
Manager interface thorugh any browser with access to this system and will be configured \
with the following...

LAM Admin Username = $lamadmin
LAM Admin Password = $lampasswd
LAM Admin Group    = $lamgroup
LAM url:http//$fqdn/lam or http://$internaladdress/lam

NOTE: It is recommended you change the default LAM Module Settings password \
form:\"lam\" to one of your choice.

Select OK to continue..."  20 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Make Installation log entries
echo "lamadmin = $lamadmin" | cat >>$log
echo "lampasswd = $lampasswd" | cat >>$log
echo "lamgroup = $lamgroup" | cat >>$log

# Configure LDAP NSS packages to enable LDAP users to Authenticate localhost.
# ** NOTE: This config is NEEDED to enable LDAP Account Manager **
# Generate /etc/ldap.conf for server
echo "###DEBCONF###" | cat >>ldap.conf
echo "##" | cat >>ldap.conf
echo "## Configuration of this file will be managed by debconf as long as the" | cat >>ldap.conf
echo "## first line of the file says '###DEBCONF###'" | cat >>ldap.conf
echo "##" | cat >>ldap.conf
echo "## You should use dpkg-reconfigure to configure this file via debconf" | cat >>ldap.conf
echo "##" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "#" | cat >>ldap.conf
echo "# @(#)$Id: ldap.conf,v 1.38 2006/05/15 08:13:31 lukeh Exp $" | cat >>ldap.conf
echo "#" | cat >>ldap.conf
echo "# This is the configuration file for the LDAP nameservice" | cat >>ldap.conf
echo "# switch library and the LDAP PAM module." | cat >>ldap.conf
echo "#" | cat >>ldap.conf
echo "# PADL Software" | cat >>ldap.conf
echo "# http://www.padl.com" | cat >>ldap.conf
echo "#" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Your LDAP server. Must be resolvable without using LDAP." | cat >>ldap.conf
echo "# Multiple hosts may be specified, each separated by a " | cat >>ldap.conf
echo "# space. How long nss_ldap takes to failover depends on" | cat >>ldap.conf
echo "# whether your LDAP client library supports configurable" | cat >>ldap.conf
echo "# network or connect timeouts (see bind_timelimit)." | cat >>ldap.conf
echo "#host 127.0.0.1" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The distinguished name of the search base." | cat >>ldap.conf
echo "base dc=$domain,dc=$suffix" | cat >>ldap.conf # <-- DYNAMIC ENTRY
echo "" | cat >>ldap.conf
echo "# Another way to specify your LDAP server is to provide an" | cat >>ldap.conf
echo "uri ldap://$fqdn/" | cat >>ldap.conf # <-- DYNAMIC ENTRY
echo "# Unix Domain Sockets to connect to a local LDAP Server." | cat >>ldap.conf
echo "#uri ldap://127.0.0.1/" | cat >>ldap.conf
echo "#uri ldaps://127.0.0.1/" | cat >>ldap.conf
echo "#uri ldapi://%2fvar%2frun%2fldapi_sock/" | cat >>ldap.conf
echo "# Note: %2f encodes the '/' used as directory separator" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The LDAP version to use (defaults to 3" | cat >>ldap.conf
echo "# if supported by client library)" | cat >>ldap.conf
echo "ldap_version 3" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The distinguished name to bind to the server with." | cat >>ldap.conf
echo "# Optional: default is to bind anonymously." | cat >>ldap.conf
echo "#binddn cn=proxyuser,dc=padl,dc=com" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The credentials to bind with. " | cat >>ldap.conf
echo "# Optional: default is no credential." | cat >>ldap.conf
echo "#bindpw secret" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The distinguished name to bind to the server with" | cat >>ldap.conf
echo "# if the effective user ID is root. Password is" | cat >>ldap.conf
echo "# stored in /etc/ldap.secret (mode 600)" | cat >>ldap.conf
echo "rootbinddn cn=admin,dc=$domain,dc=$suffix" | cat >>ldap.conf # <-- DYNAMIC ENTRY
echo "" | cat >>ldap.conf
echo "# The port." | cat >>ldap.conf
echo "# Optional: default is 389." | cat >>ldap.conf
echo "#port 389" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The search scope." | cat >>ldap.conf
echo "#scope sub" | cat >>ldap.conf
echo "#scope one" | cat >>ldap.conf
echo "#scope base" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Search timelimit" | cat >>ldap.conf
echo "#timelimit 30" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Bind/connect timelimit" | cat >>ldap.conf
echo "#bind_timelimit 30" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Reconnect policy: hard (default) will retry connecting to" | cat >>ldap.conf
echo "# the software with exponential backoff, soft will fail" | cat >>ldap.conf
echo "# immediately." | cat >>ldap.conf
echo "#bind_policy hard" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Idle timelimit; client will close connections" | cat >>ldap.conf
echo "# (nss_ldap only) if the server has not been contacted" | cat >>ldap.conf
echo "# for the number of seconds specified below." | cat >>ldap.conf
echo "#idle_timelimit 3600" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Filter to AND with uid=%s" | cat >>ldap.conf
echo "#pam_filter objectclass=account" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# The user ID attribute (defaults to uid)" | cat >>ldap.conf
echo "#pam_login_attribute uid" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Search the root DSE for the password policy (works" | cat >>ldap.conf
echo "# with Netscape Directory Server)" | cat >>ldap.conf
echo "#pam_lookup_policy yes" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Check the 'host' attribute for access control" | cat >>ldap.conf
echo "# Default is no; if set to yes, and user has no" | cat >>ldap.conf
echo "# value for the host attribute, and pam_ldap is" | cat >>ldap.conf
echo "# configured for account management (authorization)" | cat >>ldap.conf
echo "# then the user will not be allowed to login." | cat >>ldap.conf
echo "#pam_check_host_attr yes" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Check the 'authorizedService' attribute for access" | cat >>ldap.conf
echo "# control" | cat >>ldap.conf
echo "# Default is no; if set to yes, and the user has no" | cat >>ldap.conf
echo "# value for the authorizedService attribute, and" | cat >>ldap.conf
echo "# pam_ldap is configured for account management" | cat >>ldap.conf
echo "# (authorization) then the user will not be allowed" | cat >>ldap.conf
echo "# to login." | cat >>ldap.conf
echo "#pam_check_service_attr yes" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Group to enforce membership of" | cat >>ldap.conf
echo "#pam_groupdn cn=PAM,ou=Groups,dc=padl,dc=com" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Group member attribute" | cat >>ldap.conf
echo "#pam_member_attribute uniquemember" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Specify a minium or maximum UID number allowed" | cat >>ldap.conf
echo "#pam_min_uid 0" | cat >>ldap.conf
echo "#pam_max_uid 0" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Template login attribute, default template user" | cat >>ldap.conf
echo "# (can be overriden by value of former attribute" | cat >>ldap.conf
echo "# in user's entry)" | cat >>ldap.conf
echo "#pam_login_attribute userPrincipalName" | cat >>ldap.conf
echo "#pam_template_login_attribute uid" | cat >>ldap.conf
echo "#pam_template_login nobody" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# HEADS UP: the pam_crypt, pam_nds_passwd," | cat >>ldap.conf
echo "# and pam_ad_passwd options are no" | cat >>ldap.conf
echo "# longer supported." | cat >>ldap.conf
echo "#" | cat >>ldap.conf
echo "# Do not hash the password at all; presume" | cat >>ldap.conf
echo "# the directory server will do it, if" | cat >>ldap.conf
echo "# necessary. This is the default." | cat >>ldap.conf
#echo "pam_password md5" | cat >>ldap.conf
echo "pam_password ssha" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Hash password locally; required for University of" | cat >>ldap.conf
echo "# Michigan LDAP server, and works with Netscape" | cat >>ldap.conf
echo "# Directory Server if you're using the UNIX-Crypt" | cat >>ldap.conf
echo "# hash mechanism and not using the NT Synchronization" | cat >>ldap.conf
echo "# service. " | cat >>ldap.conf
echo "#pam_password crypt" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Remove old password first, then update in" | cat >>ldap.conf
echo "# cleartext. Necessary for use with Novell" | cat >>ldap.conf
echo "# Directory Services (NDS)" | cat >>ldap.conf
echo "#pam_password clear_remove_old" | cat >>ldap.conf
echo "#pam_password nds" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# RACF is an alias for the above. For use with" | cat >>ldap.conf
echo "# IBM RACF" | cat >>ldap.conf
echo "#pam_password racf" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Update Active Directory password, by" | cat >>ldap.conf
echo "# creating Unicode password and updating" | cat >>ldap.conf
echo "# unicodePwd attribute." | cat >>ldap.conf
echo "#pam_password ad" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Use the OpenLDAP password change" | cat >>ldap.conf
echo "# extended operation to update the password." | cat >>ldap.conf
echo "#pam_password exop" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Redirect users to a URL or somesuch on password" | cat >>ldap.conf
echo "# changes." | cat >>ldap.conf
echo "#pam_password_prohibit_message Please visit http://internal to change your password." | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# RFC2307bis naming contexts" | cat >>ldap.conf
echo "# Syntax:" | cat >>ldap.conf
echo "# nss_base_XXX		base?scope?filter" | cat >>ldap.conf
echo "# where scope is {base,one,sub}" | cat >>ldap.conf
echo "# and filter is a filter to be &'d with the" | cat >>ldap.conf
echo "# default filter." | cat >>ldap.conf
echo "# You can omit the suffix eg:" | cat >>ldap.conf
echo "# nss_base_passwd	ou=People," | cat >>ldap.conf
echo "# to append the default base DN but this" | cat >>ldap.conf
echo "# may incur a small performance impact." | cat >>ldap.conf
echo "#nss_base_passwd		ou=People,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_shadow		ou=People,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_group		ou=Group,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_hosts		ou=Hosts,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_services	ou=Services,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_networks	ou=Networks,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_protocols	ou=Protocols,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_rpc			ou=Rpc,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_ethers		ou=Ethers,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_netmasks	ou=Networks,dc=padl,dc=com?ne" | cat >>ldap.conf
echo "#nss_base_bootparams	ou=Ethers,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_aliases		ou=Aliases,dc=padl,dc=com?one" | cat >>ldap.conf
echo "#nss_base_netgroup	ou=Netgroup,dc=padl,dc=com?one" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# attribute/objectclass mapping" | cat >>ldap.conf
echo "# Syntax:" | cat >>ldap.conf
echo "#nss_map_attribute	rfc2307attribute	mapped_attribute" | cat >>ldap.conf
echo "#nss_map_objectclass	rfc2307objectclass	mapped_objectclass" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# configure --enable-nds is no longer supported." | cat >>ldap.conf
echo "# NDS mappings" | cat >>ldap.conf
echo "#nss_map_attribute uniqueMember member" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Services for UNIX 3.5 mappings" | cat >>ldap.conf
echo "#nss_map_objectclass posixAccount User" | cat >>ldap.conf
echo "#nss_map_objectclass shadowAccount User" | cat >>ldap.conf
echo "#nss_map_attribute uid msSFU30Name" | cat >>ldap.conf
echo "#nss_map_attribute uniqueMember msSFU30PosixMember" | cat >>ldap.conf
echo "#nss_map_attribute userPassword msSFU30Password" | cat >>ldap.conf
echo "#nss_map_attribute homeDirectory msSFU30HomeDirectory" | cat >>ldap.conf
echo "#nss_map_attribute homeDirectory msSFUHomeDirectory" | cat >>ldap.conf
echo "#nss_map_objectclass posixGroup Group" | cat >>ldap.conf
echo "#pam_login_attribute msSFU30Name" | cat >>ldap.conf
echo "#pam_filter objectclass=User" | cat >>ldap.conf
echo "#pam_password ad" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# configure --enable-mssfu-schema is no longer supported." | cat >>ldap.conf
echo "# Services for UNIX 2.0 mappings" | cat >>ldap.conf
echo "#nss_map_objectclass posixAccount User" | cat >>ldap.conf
echo "#nss_map_objectclass shadowAccount user" | cat >>ldap.conf
echo "#nss_map_attribute uid msSFUName" | cat >>ldap.conf
echo "#nss_map_attribute uniqueMember posixMember" | cat >>ldap.conf
echo "#nss_map_attribute userPassword msSFUPassword" | cat >>ldap.conf
echo "#nss_map_attribute homeDirectory msSFUHomeDirectory" | cat >>ldap.conf
echo "#nss_map_attribute shadowLastChange pwdLastSet" | cat >>ldap.conf
echo "#nss_map_objectclass posixGroup Group" | cat >>ldap.conf
echo "#nss_map_attribute cn msSFUName" | cat >>ldap.conf
echo "#pam_login_attribute msSFUName" | cat >>ldap.conf
echo "#pam_filter objectclass=User" | cat >>ldap.conf
echo "#pam_password ad" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# RFC 2307 (AD) mappings" | cat >>ldap.conf
echo "#nss_map_objectclass posixAccount user" | cat >>ldap.conf
echo "#nss_map_objectclass shadowAccount user" | cat >>ldap.conf
echo "#nss_map_attribute uid sAMAccountName" | cat >>ldap.conf
echo "#nss_map_attribute homeDirectory unixHomeDirectory" | cat >>ldap.conf
echo "#nss_map_attribute shadowLastChange pwdLastSet" | cat >>ldap.conf
echo "#nss_map_objectclass posixGroup group" | cat >>ldap.conf
echo "#nss_map_attribute uniqueMember member" | cat >>ldap.conf
echo "#pam_login_attribute sAMAccountName" | cat >>ldap.conf
echo "#pam_filter objectclass=User" | cat >>ldap.conf
echo "#pam_password ad" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# configure --enable-authpassword is no longer supported" | cat >>ldap.conf
echo "# AuthPassword mappings" | cat >>ldap.conf
echo "#nss_map_attribute userPassword authPassword" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# AIX SecureWay mappings" | cat >>ldap.conf
echo "#nss_map_objectclass posixAccount aixAccount" | cat >>ldap.conf
echo "#nss_base_passwd ou=aixaccount,?one" | cat >>ldap.conf
echo "#nss_map_attribute uid userName" | cat >>ldap.conf
echo "#nss_map_attribute gidNumber gid" | cat >>ldap.conf
echo "#nss_map_attribute uidNumber uid" | cat >>ldap.conf
echo "#nss_map_attribute userPassword passwordChar" | cat >>ldap.conf
echo "#nss_map_objectclass posixGroup aixAccessGroup" | cat >>ldap.conf
echo "#nss_base_group ou=aixgroup,?one" | cat >>ldap.conf
echo "#nss_map_attribute cn groupName" | cat >>ldap.conf
echo "#nss_map_attribute uniqueMember member" | cat >>ldap.conf
echo "#pam_login_attribute userName" | cat >>ldap.conf
echo "#pam_filter objectclass=aixAccount" | cat >>ldap.conf
echo "#pam_password clear" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Netscape SDK LDAPS" | cat >>ldap.conf
echo "#ssl on" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Netscape SDK SSL options" | cat >>ldap.conf
echo "#sslpath /etc/ssl/certs" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# OpenLDAP SSL mechanism" | cat >>ldap.conf
echo "# start_tls mechanism uses the normal LDAP port, LDAPS typically 636" | cat >>ldap.conf
echo "#ssl start_tls" | cat >>ldap.conf
echo "#ssl on" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# OpenLDAP SSL options" | cat >>ldap.conf
echo "# Require and verify server certificate (yes/no)" | cat >>ldap.conf
echo "# Default is to use libldap's default behavior, which can be configured in" | cat >>ldap.conf
echo "# /etc/openldap/ldap.conf using the TLS_REQCERT setting.  The default for" | cat >>ldap.conf
echo "# OpenLDAP 2.0 and earlier is "no", for 2.1 and later is "yes"." | cat >>ldap.conf
echo "#tls_checkpeer yes" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# CA certificates for server certificate verification" | cat >>ldap.conf
echo "# At least one of these are required if tls_checkpeer is "yes"" | cat >>ldap.conf
echo "#tls_cacertfile /etc/ssl/ca.cert" | cat >>ldap.conf
echo "#tls_cacertdir /etc/ssl/certs" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Seed the PRNG if /dev/urandom is not provided" | cat >>ldap.conf
echo "#tls_randfile /var/run/egd-pool" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# SSL cipher suite" | cat >>ldap.conf
echo "# See man ciphers for syntax" | cat >>ldap.conf
echo "#tls_ciphers TLSv1" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Client certificate and key" | cat >>ldap.conf
echo "# Use these, if your server requires client authentication." | cat >>ldap.conf
echo "#tls_cert" | cat >>ldap.conf
echo "#tls_key" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Disable SASL security layers. This is needed for AD." | cat >>ldap.conf
echo "#sasl_secprops maxssf=0" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# Override the default Kerberos ticket cache location." | cat >>ldap.conf
echo "#krb5_ccname FILE:/etc/.ldapcache" | cat >>ldap.conf
echo "" | cat >>ldap.conf
echo "# SASL mechanism for PAM authentication - use is experimental" | cat >>ldap.conf
echo "# at present and does not support password policy control" | cat >>ldap.conf
echo "#pam_sasl_mech DIGEST-MD5" | cat >>ldap.conf
echo "nss_initgroups_ignoreusers backup,bin,daemon,dnsmasq,games,gnats,irc,landscape,libuuid,list,lp,mail,man,messagebus,news,ntp,openldap,proxy,root,sshd,statd,sync,sys,syslog,uucp,www-data" | cat >>ldap.conf

#copying in place before configuring packages
sudo cp -v ldap.conf /etc/ldap.conf
sudo rm -rf ldap.conf

echo ""
echo "Installing pre dependencies LDAP NSS packages to enable LAM"
sleep 1
sudo apt-get -y --force-yes install libnss-ldap
sudo auth-client-config -t nss -p lac_ldap
sudo pam-auth-update

# Install LDAP Account Manager
echo ""
echo "Installing LDAP Account Manager & additional tools"
sleep 1
sudo apt-get -y --force-yes install ldap-account-manager ldap-account-manager-lamdaemon quota

# Generate LDAP Permissions for LDAP Account Manager
# Load variable with presence of kerberos value in logile
kerberos=`cat <$log | grep realm | awk '{print $1}'`

# Generate ldif to modify Directory read access
echo "Generating LDAP Configuration: $lamadmin.ldif"
sleep 1
echo "dn: olcDatabase={1}hdb,cn=config" | cat >$lamadmin.ldif
echo "changetype: modify" | cat >>$lamadmin.ldif
echo "replace: olcAccess" | cat >>$lamadmin.ldif
# If kerberos is installed modify ldif to contain krbPrincipalKey
{
	if [ "$kerberos" = "realm" ] ; then
		echo "olcAccess: {0}to attrs=userPassword,shadowLastChange,krbPrincipalKey by self write by anonymous auth by dn="cn=admin,dc=$domain,dc=$suffix" write by dn="uid=$lamadmin,ou=users,dc=$domain,dc=$suffix" write  by * none" | cat >>$lamadmin.ldif
	else
		echo "olcAccess: {0}to attrs=userPassword,shadowLastChange by self write by anonymous auth by dn="cn=admin,dc=$domain,dc=$suffix" write by dn="uid=$lamadmin,ou=users,dc=$domain,dc=$suffix" write  by * none" | cat >>$lamadmin.ldif
	fi
}
echo "olcAccess: {1}to dn.base="" by * read" | cat >>$lamadmin.ldif
echo "olcAccess: {2}to * by self write by dn="cn=admin,dc=$domain,dc=$suffix" write by dn="uid=$lamadmin,ou=users,dc=$domain,dc=$suffix" write by * read" | cat >>$lamadmin.ldif
echo ""
echo "Adding $lamadmin.ldif into LDAP server"
echo ""
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f $lamadmin.ldif
sleep 1

# Generate lam config file
echo "# LDAP Account Manager configuration" | cat >lam.conf
echo "#" | cat >>lam.conf
echo "# Please do not modify this file manually. The configuration can be done completely by the LAM GUI." | cat >>lam.conf
echo "#" | cat >>lam.conf
echo "###################################################################################################" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# server address (e.g. ldap://localhost:389 or ldaps://localhost:636)" | cat >>lam.conf
echo "ServerURL: ldap://localhost:389" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# list of users who are allowed to use LDAP Account Manager" | cat >>lam.conf
echo "# names have to be seperated by semicolons" | cat >>lam.conf
echo "# e.g. admins: cn=admin,dc=yourdomain,dc=org;cn=root,dc=yourdomain,dc=org" | cat >>lam.conf
echo "Admins: uid=$lamadmin,ou=users,dc=$domain,dc=$suffix" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# password to change these preferences via webfrontend (default: lam)" | cat >>lam.conf
echo "Passwd: {SSHA}RjBruJcTxZEdcBjPQdRBkDaSQeY= iueleA==" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# suffix of tree view" | cat >>lam.conf
echo "# e.g. dc=yourdomain,dc=org" | cat >>lam.conf
echo "treesuffix: dc=$domain,dc=$suffix" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# default language (a line from config/language)" | cat >>lam.conf
echo "defaultLanguage: en_GB.utf8:UTF-8:English (Great Britain)" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Path to external Script" | cat >>lam.conf
echo "scriptPath: /usr/share/ldap-account-manager/lib/lamdaemon.pl" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Server of external Script" | cat >>lam.conf
echo "scriptServer: localhost" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Access rights for home directories" | cat >>lam.conf
echo "scriptRights: 740" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Number of minutes LAM caches LDAP searches." | cat >>lam.conf
echo "cachetimeout: 5" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# LDAP search limit." | cat >>lam.conf
echo "searchLimit: 0" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Module settings" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "modules: posixAccount_minUID: $uidstart" | cat >>lam.conf
echo "modules: posixAccount_maxUID: $uidend" | cat >>lam.conf
echo "modules: posixAccount_minMachine: $midstart" | cat >>lam.conf
echo "modules: posixAccount_maxMachine: $midend" | cat >>lam.conf
echo "modules: posixGroup_minGID: $gidstart" | cat >>lam.conf
echo "modules: posixGroup_maxGID: $gidend" | cat >>lam.conf
echo "modules: posixGroup_pwdHash: SSHA" | cat >>lam.conf
echo "modules: posixAccount_pwdHash: SSHA" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# List of active account types." | cat >>lam.conf
echo "activeTypes: user,group,host,smbDomain" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "types: suffix_user: ou=users,dc=$domain,dc=$suffix" | cat >>lam.conf
echo "types: attr_user: #uid;#givenName;#sn;#uidNumber;#gidNumber" | cat >>lam.conf
echo "types: modules_user: inetOrgPerson,posixAccount,shadowAccount,sambaSamAccount" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "types: suffix_group: ou=groups,dc=$domain,dc=$suffix" | cat >>lam.conf
echo "types: attr_group: #cn;#gidNumber;#memberUID;#description" | cat >>lam.conf
echo "types: modules_group: posixGroup,sambaGroupMapping" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "types: suffix_host: ou=computers,dc=$domain,dc=$suffix" | cat >>lam.conf
echo "types: attr_host: #cn;#description;#uidNumber;#gidNumber" | cat >>lam.conf
echo "types: modules_host: account,posixAccount,sambaSamAccount" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "types: suffix_smbDomain: dc=$domain,dc=$suffix" | cat >>lam.conf
echo "types: attr_smbDomain: sambaDomainName:Domain name;sambaSID:Domain SID" | cat >>lam.conf
echo "types: modules_smbDomain: sambaDomain" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Password mail subject" | cat >>lam.conf
echo "lamProMailSubject: Your password was reset" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Password mail text" | cat >>lam.conf
echo "lamProMailText: Dear @@givenName@@ @@sn@@,+::++::+your password was reset to: @@newPassword@@+::++::++::+Best regards+::++::+deskside support+::+" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# enable TLS encryption" | cat >>lam.conf
echo "useTLS: no" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Access level for this profile." | cat >>lam.conf
echo "accessLevel: 100" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Login method." | cat >>lam.conf
echo "loginMethod: list" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Search suffix for LAM login." | cat >>lam.conf
echo "#loginSearchSuffix: dc=yourdomain,dc=org" | cat >>lam.conf
echo "#loginSearchSuffix: dc=$domain,dc=$suffix" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Search filter for LAM login." | cat >>lam.conf
echo "loginSearchFilter: uid=%USER%" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Bind DN for login search." | cat >>lam.conf
echo "loginSearchDN: " | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Bind password for login search." | cat >>lam.conf
echo "loginSearchPassword: " | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# HTTP authentication for LAM login." | cat >>lam.conf
echo "httpAuthentication: false" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Password mail from" | cat >>lam.conf
echo "lamProMailFrom: " | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Password mail reply-to" | cat >>lam.conf
echo "lamProMailReplyTo: " | cat >>lam.conf
echo "" | cat >>lam.conf
echo "" | cat >>lam.conf
echo "# Password mail is HTML" | cat >>lam.conf
echo "lamProMailIsHTML: false" | cat >>lam.conf
echo "types: filter_user: " | cat >>lam.conf
echo "types: customLabel_user: " | cat >>lam.conf
echo "types: filter_group: " | cat >>lam.conf
echo "types: customLabel_group: " | cat >>lam.conf
echo "types: filter_host: " | cat >>lam.conf
echo "types: customLabel_host: " | cat >>lam.conf
echo "types: filter_smbDomain: " | cat >>lam.conf
echo "types: customLabel_smbDomain: " | cat >>lam.conf
echo "types: hidden_user: " | cat >>lam.conf
echo "types: hidden_group: " | cat >>lam.conf
echo "types: hidden_host: " | cat >>lam.conf
echo "types: hidden_smbDomain: " | cat >>lam.conf
echo "tools: tool_hide_toolServerInformation: false" | cat >>lam.conf
echo "tools: tool_hide_toolFileUpload: false" | cat >>lam.conf
echo "tools: tool_hide_toolTests: false" | cat >>lam.conf
echo "tools: tool_hide_toolSchemaBrowser: false" | cat >>lam.conf
echo "tools: tool_hide_toolMultiEdit: false" | cat >>lam.conf
echo "tools: tool_hide_toolPDFEditor: false" | cat >>lam.conf
echo "tools: tool_hide_toolProfileEditor: false" | cat >>lam.conf
echo "tools: tool_hide_toolOUEditor: false" | cat >>lam.conf

sudo cp -v /var/lib/ldap-account-manager/config/lam.conf /var/lib/ldap-account-manager/config/lam.conf-$date
sudo mv -v lam.conf /var/lib/ldap-account-manager/config/lam.conf
sudo chmod 744 /var/lib/ldap-account-manager/config/lam.conf
sudo chown www-data:www-data /var/lib/ldap-account-manager/config/lam.conf


# Create LAM Administrator if not the same as Network Administrator
# Check, and if necessary and add LAM Group to LDAP
{
    if [ "$lamgroup" = "$netadmingrp" ] ; then
    	continue
    else
    	echo "Adding LAM Administrator Group: $lamgroup"
    	sleep 1
    	sudo ldapaddgroup $lamgroup
    fi
}
# Check if necessary and add LAM Administrator to LDAP
{
	if [ "$lamadmin" = "$netadmin" ] ; then
		continue
	else
		echo "Adding LAM Adminstrator: cn=$lamadmin,dc=$domain,dc=$suffix"
		sleep 1
		sudo ldapadduser $lamadmin $lamgroup
		echo "Setting password for LAM Administrator"
		sleep 1
		sudo ldapsetpasswd $lamadmin $lampasswd
	fi
}
# adding user to sudo group
sudo adduser $lamadmin sudo
sudo cp /etc/sudoers sudoers
sudo chmod 777 sudoers
echo "$lamadmin ALL=NOPASSWD:/usr/share/ldap-account-manager/lib/lamdaemon.pl *" | cat >>sudoers
sudo chmod 440 sudoers
sudo mv -v sudoers /etc/sudoers

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "LDAP Account Manager: Installed" | cat >>$notes
echo "LAM Account Manager: $lamadmin" | cat >>$notes
echo "LAM Password: $lampasswd" | cat >>$notes

# Removing .temp files
rm -rf *.temp