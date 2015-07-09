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
#         NAME: system-kerberos.sh
#      CREATED: 20-05-2015
#      REVISED: 18-06-2015
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
fqdn=`cat <$log | grep "fqdn " | awk '{print $3}'`
ldapadmin=`cat <$log | grep "ldapadmin =" | awk '{print $3}'`
ldappasswd=`cat <$log | grep "ldappasswd =" | awk '{print $3}'`
netadmin=`cat <$log | grep "netadmin =" | awk '{print $3}'`
netadmingrp=`cat <$log | grep "netadmingrp =" | awk '{print $3}'`
netadminpasswd=`cat <$log | grep "netadminpasswd =" | awk '{print $3}'`

clear
echo "Gathering system info to configure Kerberos"
echo "pleae wait..."
sleep 1
# Change fullname name to Uppercase for Kerberos Realm
echo $fullname | sed 's/\(.*\)/\U\1/' | cat >realm.temp
# Output Kerberos server names into temp files
echo "kerberos.$fullname" | cat >>kdc.temp
echo "kerberos.$fullname" | cat >>admin_server.temp
# Read back variables
realm=`cat <realm.temp`
kdc=`cat <kdc.temp`
admin_server=`cat <admin_server.temp`

# Whiptail input box to edit username for Kerberos Principal
module='Kerberos Admin Principal'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
When setting up a Key Distribution Center (KDC) Server an admin user, the \"Admin Principal\" is needed.

It is recommended you use a different user for this task, to keep things simpler the installer \
has suggested the \"Network Administrator\" user created when LDAP was configured.

Please enter the KDC Admin Principal username:" 16 68 $netadmin 2>kdcadmin.temp

# Set variable
kdcadmin=`cat <kdcadmin.temp`
	# Check for null entry
	{
    	if [ "$kdcadmin" = "" ] ; then
	    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
	        # Re-Start Module
    	    ./service-kerberos.sh
        else
	    	continue
    	fi
	}

# Whiptail yes no - Configure Kerberos Realm
module='Kerberos Realm & Servers'
{
	if (whiptail --title "Create Kerberos Realm" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
To create and configure a Kerberos Realm requires human intervention, due to the security \
trust factors this aspect cannot be automated. The installer will however attempt to \
simplfy this process, based on the values already used.

The Kerberos Realm & Servers will be configured with the following...
Kerberos Realm          = $realm
Key Distribution Center = $kdc
Kerberos Admin Server   = $admin_server
Admin Principal         = "$kdcadmin"@"$realm"
(Password to be entered when creating Realm & adding Principal)

NOTE: Kerberos will use OpenLDAP directory as it's Principal Database.

Select OK to continue..."  24 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Check if LDAP has been installed by checking logfile for "ldapadmin" value.
ldapcheck=`cat <$log | grep ldapadmin | awk '{print $1}'`
{
    if [ "$ldapcheck" = "ldapadmin" ] ; then
    	continue
    else
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No entry has been found in the install log to suggest you have installed and configured \
Open LDAP on this system. Your current settings will be lost and the LDAP module will be started.

NOTE: The \"ldapadmin\" value was missing form the install log." 12 68
        # Re-Start Module
        ./service-ldap.sh
    fi
}

# Make Installation log entries
echo "realm = $realm" | cat >>$log
echo "kdc = $kdc" | cat >>$log
echo "admin_server = $admin_server" | cat >>$log
echo "kdcadmin = $kdcadmin" | cat >>$log

# Make hostname entries into dnsmasq config so kerberos installation is automagical!
clear
echo ""
echo "Making Kerberos name entries into DNS server..."
echo "# Kerberos Server Entry" | cat >>dnsmasq.conf
echo "# This maps $kdc to the server" | cat >>dnsmasq.conf
echo "address=/kerberos.$fullname/$internaladdress" | cat >>dnsmasq.conf
echo "txt-record=_kerberos.$fullname,\"$realm\" " | cat >>dnsmasq.conf
echo "srv-host=_kerberos._udp.$fullname,\"$kdc\",88 " | cat >>dnsmasq.conf
echo "srv-host=_kerberos._tcp.$fullname,\"$kdc\",88 " | cat >>dnsmasq.conf
echo "srv-host=_kerberos-master._udp.$fullname,\"$kdc\",88 " | cat >>dnsmasq.conf
echo "srv-host=_kerberos-adm._tcp.$fullname,\"$kdc\",749 " | cat >>dnsmasq.conf
echo "srv-host=_kpasswd._udp.$fullname,\"$kdc\",464 " | cat >>dnsmasq.conf
echo "#" | cat >>dnsmasq.conf
sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo service dnsmasq restart
sleep 1

#echo "Installing Kerberos LDAP packages"
clear 
echo ""
echo "Installing MIT Kerberos server..."
sudo apt-get -y --force-yes install krb5-kdc-ldap

# Copying file needed to generate Kerberos Schema
sudo gzip -d /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz
sudo cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema /etc/ldap/schema/

# Generating LDAP Kerberos Schema
echo "Dynamically generating Kerberos schema for LDAP..."
# Generating schema_convert.conf file for schema listing
echo "include /etc/ldap/schema/core.schema" | cat >schema_convert.conf
echo "include /etc/ldap/schema/collective.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/corba.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/cosine.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/duaconf.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/dyngroup.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/inetorgperson.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/java.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/misc.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/nis.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/openldap.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/ppolicy.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/ldapns.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/pmi.schema" | cat >>schema_convert.conf
echo "include /etc/ldap/schema/kerberos.schema" | cat >>schema_convert.conf
# Checking if Temp file for Schema output is about
mkdir -p ldif_output
# Inserting name of schema to insert
echo "kerberos" | cat >schemaname.temp
# Read back Name of Schema to install
schemaname=`cat <schemaname.temp`
# Capture Number of schema
slapcat -f schema_convert.conf -F ldif_output -n 0 | sed 's/[^ ]* //' | grep $schemaname,cn=schema \
| sed -e 's/\,.*//' | sed 's/cn=//' | cat >schemanumber.temp
# Readback Schema Number
schemanumber=`cat <schemanumber.temp`
# Use Spalcat to perform conversion
slapcat -f schema_convert.conf -F ldif_output -n0 -H ldap:///cn=$schemanumber,cn=schema,cn=config -l $schemaname.ldif
# Rename attributes and remove generation output - the Double quotation helps Sed deal with variables
cat <$schemaname.ldif | sed "s/cn=$schemanumber,cn=schema,cn=config/cn=$schemaname,cn=schema,cn=config/"  \
| sed "s/$schemanumber/$schemaname/" | sed -e '/^structuralObjectClass:/d' | sed -e '/^entryUUID:/d' \
| sed -e '/^creatorsName:/d' | sed -e '/^createTimestamp:/d' | sed -e '/^entryCSN:/d' \
| sed -e '/^modifiersName:/d' | sed -e '/^modifyTimestamp:/d' | cat >cn=$schemaname.ldif
# Adding Schema $schemaname into LDAP
echo ""
echo "Adding $schemaname schema to LDAP server..."
echo ""
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f cn\=$schemaname.ldif
sleep 1

# LDAP Kerberos Principal
echo "Generating Kerberos Principal LDAP values"
sleep 1
echo "dn: olcDatabase={1}hdb,cn=config" | cat >krb_principal.ldif
echo "add: olcDbIndex" | cat >>krb_principal.ldif
echo "olcDbIndex: krbPrincipalName eq,pres,sub" | cat >>krb_principal.ldif
echo ""
echo "Modifying olcDbIndex with krbPrincipalName vales"
echo ""
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f krb_principal.ldif
sleep 1

# LDAP-Kerberos acl's
echo "Generating Kerberos LDAP ACl's"
sleep 1 
echo "dn: olcDatabase={1}hdb,cn=config" | cat >krb_acl.ldif
echo "replace: olcAccess" | cat >>krb_acl.ldif
echo "olcAccess: to attrs=userPassword,shadowLastChange,krbPrincipalKey by dn=\"cn=admin,dc=$domain,dc=$suffix\" write by anonymous auth by self write by * none" | cat >>krb_acl.ldif
echo "-" | cat >>krb_acl.ldif
echo "add: olcAccess" | cat >>krb_acl.ldif
echo "olcAccess: to dn.base=\"\" by * read" | cat >>krb_acl.ldif
echo "-" | cat >>krb_acl.ldif
echo "add: olcAccess" | cat >>krb_acl.ldif
echo "olcAccess: to * by dn=\"cn=admin,dc=$domain,dc=$suffix\" write by * read" | cat >>krb_acl.ldif
echo ""
echo "Modifying oclAccess with krbPrincipalKey values"
echo ""
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -w $ldappasswd -f krb_acl.ldif

# Installing main Kerberos package
echo "Installing additional Kerberos packages..."
sleep 1
sudo apt-get -y --force-yes install krb5-kdc krb5-admin-server krb5-kdc-ldap krb5-user

# Generate /etc/krb5.conf
echo ""
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
echo "" | cat >>krb5.conf
echo "[dbdefaults]" | cat >>krb5.conf
# Bug in Ubuntu Server guide - LDAP container needs cn attribute, used: cn=kerberos
echo "        ldap_kerberos_container_dn = cn=kerberos,dc=$domain,dc=$suffix" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "" | cat >>krb5.conf
echo "[dbmodules]" | cat >>krb5.conf
echo "        openldap_ldapconf = {" | cat >>krb5.conf
echo "                db_library = kldap" | cat >>krb5.conf
echo "                ldap_kdc_dn = \"cn=admin,dc=$domain,dc=$suffix\" " | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "                # this object needs to have read rights on" | cat >>krb5.conf
echo "                # the realm container, principal container and realm sub-trees" | cat >>krb5.conf
echo "                ldap_kadmind_dn = \"cn=admin,dc=$domain,dc=$suffix\"" | cat >>krb5.conf
echo "" | cat >>krb5.conf
echo "                # this object needs to have read and write rights on" | cat >>krb5.conf
echo "                # the realm container, principal container and realm sub-trees" | cat >>krb5.conf
echo "                ldap_service_password_file = /etc/krb5kdc/service.keyfile" | cat >>krb5.conf
echo "                ldap_servers = ldaps://$fqdn" | cat >>krb5.conf # <-- DYNAMIC ENTRY
echo "                ldap_conns_per_server = 5" | cat >>krb5.conf
echo "        }" | cat >>krb5.conf

# Copy the config file across
sudo cp /etc/krb5.conf /etc/krb5conf-$date
sudo cp krb5.conf /etc/krb5.conf

clear
echo ""
echo "** Creating Kerberos Realm **"
sleep 1
echo ""
echo "To create the Kerberos Realm, you will need to:"
sleep 1
echo "1. Authenticate with your LDAP admin password"
sleep 1
echo "2. Set a database Master pasword for the Key Distribution Centre (KDC)"
sleep 1
echo "3. Re-Enter the KDC database Master password"
sleep 1
echo ""
read -p "Press Enter to continue..." key
#echo ""
#echo "Creating realm, executing utility kdb5_ldap_util:"
#sleep 1
#echo "cn=admin,dc=$domain,dc=$suffix create -subtrees dc=$domain,dc=$suffix -r $realm -s -H ldap://$fqdn"
echo ""
sudo kdb5_ldap_util -D cn=admin,dc=$domain,dc=$suffix create -subtrees dc=$domain,dc=$suffix -r $realm -s -H ldap://$fqdn
echo ""
echo "Creating hash file so Kerberos can bind to the LDAP Server"
sleep 1
echo "NOTE: you will need to enter the Admin password x3 times!"
sleep 1
echo ""
read -p "Press Enter to continue..." key
#echo ""
#echo "executing the following command..."
#sleep 1
#echo "sudo kdb5_ldap_util -D cn=admin,dc=$domain,dc=$suffix stashsrvpw -f /etc/krb5kdc/service.keyfile cn=admin,dc=$domain,dc=$suffix"
echo ""
sudo kdb5_ldap_util -D cn=admin,dc=$domain,dc=$suffix stashsrvpw -f /etc/krb5kdc/service.keyfile cn=admin,dc=$domain,dc=$suffix

# Create Kerberos Admin Principal, if same as Network Administrator
{
    if [ "$kdcadmin" = "$netadmin" ] ; then
    	echo ""
    	echo "Adding Kerberos Admin Principal attributes to user;"
    	echo "uid=$kdcadmin,ou=users,dc=$domain,dc=$suffix"
    	read -p "Press Enter to continue..." key
    	echo ""
    	sudo kadmin.local -q "addprinc -x dn="uid=$kdcadmin,ou=users,dc=$domain,dc=$suffix" $kdcadmin/admin"
    else
    	echo ""
    	echo "Creating Kerberos Admin Principal in LDAP..."
    	sleep 1
    	echo "Assigning user to LDAP Group: $netadmingrp"
    	sleep 1
		sudo ldapadduser $kdcadmin $netadmingrp
		echo "NOTE: this user will have the same LDAP password as: $netadmin"
		sleep 2
		echo "Adding Kerberos Admin Principal attributes to user;"
		echo "uid=$kdcadmin,ou=users,dc=$domain,dc=$suffix"
		read -p "Press Enter to continue..." key
		echo ""
		sudo kadmin.local -q "addprinc -x dn="uid=$kdcadmin,ou=users,dc=$domain,dc=$suffix" $kdcadmin/admin"
    fi
}

# Generate /etc/krb5kdc/kadm5.acl file
echo "# This file Is the access control list for krb5 administration." | cat >kadm5.acl
echo "# When this file is edited run /etc/init.d/krb5-admin-server restart to activate" | cat >>kadm5.acl
echo "# One common way to set up Kerberos administration is to allow any principal" | cat >>kadm5.acl
echo "# ending in /admin  is given full administrative rights." | cat >>kadm5.acl
echo "# To enable this, uncomment the following line:" | cat >>kadm5.acl
echo "*/admin *" | cat >>kadm5.acl
# Copy file into place
sudo cp -v kadm5.acl /etc/krb5kdc/kadm5.acl
# Re-start Kerberos
sudo service krb5-kdc restart
sudo service krb5-admin-server restart

# make hash file readable by kerberos
sudo chmod 644 /etc/krb5kdc/service.keyfile

# Fix krb524d bug - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=569758
# Generating scrip to run every 15 mins to fix
echo "# krb524d bug - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=569758" | cat >slapd-check
echo "#!/bin/sh" | cat >>slapd-check
echo "" | cat >>slapd-check
echo "PATH=/usr/bin:/bin" | cat >>slapd-check
echo "" | cat >>slapd-check
echo "openfiles=`lsof |grep -c slapd`" | cat >>slapd-check 
echo "" | cat >>slapd-check
echo "daemonactive=`ps ax |grep -c krb524d`" | cat >>slapd-check
echo "" | cat >>slapd-check
echo "if [ $daemonactive -gt 0 ] && [ $openfiles -gt 100 ]; then" | cat >>slapd-check
echo "" | cat >>slapd-check
echo "        killall krb524d" | cat >>slapd-check
echo "        krb524d -m" | cat >>slapd-check
echo "fi" | cat >>slapd-check
echo "" | cat >>slapd-check
echo "exit 0" | cat >>slapd-check
# Moving fix scrip into place
sudo cp -v slapd-check /usr/local/bin/
# Setting script permissions
sudo chmod 750 /usr/local/bin/slapd-check
# Adding job to crontab @ every 15 mins
sudo echo "*/15 * * * * /usr/local/bin/slapd-check" | cat >>crontab

# Re-organise the startup scripts so Kerberos starts After LDAP
sudo mv -v /etc/rc2.d/S18krb5-admin-server /etc/rc2.d/S21krb5-admin-server
sudo mv -v /etc/rc2.d/S18krb5-kdc /etc/rc2.d/S21krb5-kdc

# check Kerberos is working and has issues session ticket
#clear
echo ""
echo "getting session ticket for $kdcadmin/admin@$realm"
kinit $kdcadmin/admin@$realm
echo ""
klist
echo ""
read -p "Press Enter to continue..." key

# Install and configure sssd
echo ""
echo "Installing SSSD to allow centralised logins..."
sleep 1
sudo apt-get -y --force-yes install sssd

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
chmod +x kerberise.sh

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "Kerberos: Enabled" | cat >>$notes
echo "Kerberos Realm: $realm" | cat >>$notes
echo "Key Distribution Centre (KDC)" | cat >>$notes
echo "Database Master Password: " | cat >>$notes
echo "Kerberos Admin Principal: $kdcadmin" | cat >>$notes
echo "Kerberos Admin Principal Password: " | cat >>$notes

# Removing .temp files
rm -rf *.temp