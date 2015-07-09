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
#         NAME: install.sh
#      CREATED: 05-11-2014
#      REVISED: 09-07-2015
#       AUTHOR: Suki Parwana suki.parwana@gmail.com
#===============================================================================

#--- Common Variables ----------------------------------------------------------
product='Linux Config Tool'
distro='Ubuntu Server'
version='14.04 LTS'
url='www.linuxconfigtool.com'
auto='*Automatic Configuration*'
error='***Configuration Error***'
#--- Other Variables -----------------------------------------------------------
date=$(date -u +"%Y%m%d")
time=$(date -u +"%H:%M:%S")
log=install.info

# Create & make initial entry into installation log info file
echo "InstallDate = $date" | cat >$log
echo "InstallStart = $time" | cat >>$log
# Find current working directory and set as root for install
echo "cwd = $(pwd)" | cat >>$log
# Making note of current user - most likely the user with sudo privileges
id -un | cat >sysadmin.temp
sysadmin=`cat <sysadmin.temp`
echo "sysadmin = $sysadmin" | cat >>$log
# Remove temp files
rm -rf *.temp
# Setting up the First Variables form the Installation log
cwd=`cat <$log | grep cwd | awk '{print $3}'`
sysadmin=`cat <$log | grep sysadmin | awk '{print $3}'`

# Execute the system-hostname.sh script
./system-hostname.sh

# Whiptail Menu to select Interface bridging or standard eth* type config.
module='Interface Configuration Selection'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
A scan of your system has found $nicno or more network interfaces. Please select how you \
would like to manage and configure the system Network Interfaces.

STANDARD - In this configuration the installer will directly configure the First Two Network \
Intefaces (eth0 & eth1) found. Any additional interfaces will have to be configured manaually.

BRIDGED  - Bridging multiple interfaces is a more advanced configuration, but is very useful. \
The installer will Automatically Bridge and group up to x4 Network Intefaces.

HELP: If you are unsure, please consult your network administrator or system docuemntation." 24 68 2 \
\
STANDARD ": Directly configure eth* configuration." \
\
BRIDGED ": Configure Bridged br* device configuration." \
2>nicconfig.temp

nicconfig=`cat <nicconfig.temp`
# Enter interface assignment into temp file.
echo $nicconfig | sed 's/\(.*\)/\L\1/' | cat >nicconfig.temp
# Enter interface assignment into configuration file.
nicconfig=`cat <nicconfig.temp`
echo "nicconfig = $nicconfig" | cat >>$log
nicconfig=`cat <$log | grep nicconfig | awk '{print $3}'`
# Check Interafce configuration and invoke apporiate sub-script.
{
    if [ "$nicconfig" = "standard" ]; then
        ./network-eth.sh
    else
        ./network-br.sh
    fi
}

# Whiptail you no - to install Dnsmaq server.
module='Install Dnsmasq DNS <-> DHCP Server'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Dnsmasq provides network infrastructure for small networks: DNS, DHCP, router \
advertisement and network boot. It is designed to be lightweight and have a small \
footprint, suitable for resource constrained routers and firewalls. 

Supported platforms include Linux (with glibc and uclibc), Android, *BSD, and Mac OS X. \
Dnsmasq is included in most Linux distributions and the ports systems of FreeBSD, OpenBSD \
and NetBSD. Dnsmasq provides full IPv6 support.

The DNS subsystem provides a local DNS server for the network, with forwarding of all \
query types to upstream recursive DNS servers and cacheing of common record types \
(A, AAAA, CNAME and PTR, also DNSKEY and DS when DNSSEC is enabled).

Do you want to install and configureDNS DHCP server?"  24 68)
	then
		./service-dnsmasq.sh
	else
		continue
	fi
}

# Whiptail yes no - to install GnuTLS
# Capture console dimensions and set max size for whiptail
test -x /usr/bin/tty && console=`/usr/bin/tty`
test -z "$console" && console=/dev/console
size=$(stty size < $console)
screen_w=${size#*\ }
screen_h=${size%%\ *}
if [ "$screen_w" -gt 0 ]; then
	max_w=$((screen_w-6))
fi
if [ "$screen_h" -gt 0 ]; then
	max_h=$((screen_h-6))
fi
module='Install GnuTLS Certificate Authority'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel --scrolltext "
GnuTLS (http://www.gnu.org/software/gnutls/) is an LGPL-licensed implementation of \
Transport Layer Security, the successor to SSL. Using GnuTLS avoids the licensing issues \
that can arise from employing the more common OpenSSL package. For this reason, certain \
packages such as OpenLDAP are compiled with support for GnuTLS instead of OpenSSL in \
recent releases of Ubuntu.

This will assist you in using the GnuTLS tools to generate certificates for the \
verification of host identity and the encryption of client/server communications. 

In order to enable TLS connections with this system, we need to setup and configure a \
Certificate Authority to Issue and Sign security certificates from this host.

- Other Notes -
Using this installer you can quickly set up this System as a Local Certificate Authority \
for your network, in general it is good pratice to deploy secured network services.

Do you want to install and configure GnuTLS..."  24 $max_w)
	then
		./system-cert-ca.sh
	else
		continue
	fi
}

# Whiptail yes no - to install Open LDAP
module='Install OpenLDAP Server'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
The Lightweight Directory Access Protocol or LDAP, is a protocol for querying and \
modifying a X.500-based directory service running over TCP/IP.The current LDAP version \
is LDAPv3, as defined in RFC4510.

The LDAP implementation used in $distro is OpenLDAP.

Do you want to install and configure OpenLDAP Directory Server? "  16 68)
	then
		./service-ldap.sh
	else
		continue
	fi
}

# Whiptail yes no - to install kerberos if LDAP installed
ldapadmin=`cat <$log | grep "ldapadmin =" | awk '{print $1}'`
module='Install MIT Kerberos'
{
	if [ "$ldapadmin" = "ldapadmin" ] ; then
	{
		if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Kerberos is a network authentication system based on the principal of a trusted third party. \
The other two parties being the user and the service the user wishes to authenticate to \
not all services and applications can use Kerberos, but for those that can, it brings the \
network environment one step closer to being Single Sign On (SSO).

Do you want to install and configure Kerberos server? "  16 68)
		then
			./service-kerberos.sh
		else
			continue
		fi
	}
	else
		continue
	fi
}

# Load variable with presence of ldapadmin value in logile
ldapadmin=`cat <$log | grep ldapadmin | awk '{print $1}'`
# Whiptail yes no - install LDAP Account Manager if LDAP is installed
module='Install LDAP Account Manager'
{
	if [ "$ldapadmin" = "ldapadmin" ] ; then
	{
		if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
LDAP Account Manager (LAM) is a web-based interface for administering LDAP Servers, the installer will:

 1. Install LDAP Account Manager.
 2. Configure LAM for use with the LDAP Server.
 3. Create a Special Administrator that can:
Adminster the LDAP Server & Create Local Home Directories for users.
 
Do you want to install and configure LDAP Account Manager?" 18 68)
		then
			./install-lam.sh
		else
			continue
		fi
	}
	else
		continue
	fi
}

# Whiptail yes no - to install NFS server and Primary share Location
whiptail --title "NFS Server & File share" --backtitle "$product for $distro $version - $url" \
 --nocancel --msgbox "Network File System (NFS)
NFS allows a system to share directories and files with others over a network. By using \
NFS, users and programs can access files on remote systems almost as if they were local files.

Some of the most notable benefits that NFS can provide include:
Local workstations use less disk space because commonly used data can be stored on a \
single machine and still remain accessible to others over the network.

There is no need for users to have separate home directories on every network machine. \
Home directories could be set up on the NFS server and made available throughout the network.

Ready to begin installation and configuration for file sharing and NFS Server for \
centralised logins of *NIX clients.

Select OK to continue..."  24 68
# execute script
./service-nfs.sh

# Whiptail yes no - to install Samba and configure it with Kerberos 
mainshare=`cat <$log | grep mainshare | awk '{print $3}'`
module='Install SAMBA'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Since 1992, Samba has provided secure, stable and fast file and print services for all \
clients using the SMB/CIFS protocol, such as all versions of DOS and Windows, OS/2, Linux \
and many others.

Do wout want to support logins for Windows clients on your network using this server?

If you select YES the installer will:
 1. Install SAMBA, SMB/CIFS Server.
 2. Configure SAMBA with the LDAP Server.
 3. Setup Samba to support Roaming Profiles
 4. Setup x1 Share at:"$mainshare"
 5. Configure this share with Network Recycle Bin.

Do you want to Install SAMBA and configure it with LDAP?" 22 68)
	then
		./service-smb.sh
	else
		continue
	fi
}

# Whiptail yes no - Install Dazzle Share and Sparkel Server
module='Sparkel Share & Dazzle Server'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Sparkle Share <- to -> Dazzle Server 

SparkleShare creates a special folder on your computer. You can add remotely hosted folders \
(or \"projects\") to this folder. These projects will be automatically kept in sync with \
both the host and all of your peers when someone adds, removes or edits a file.

Dazzle is the Server side component of Sparkel Share, and uses GIT to keep things in sync.

Do you want to Install Sparkel Share & Dazzle Server? " 18 68)
	then
		./install-dazzle.sh
	else
		continue
	fi
}

# Whiptail yes no - Install Gitlab Server
module='Install Gitlab Server'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Open source software to collaborate on code

GitLab offers git repository management, code reviews, issue tracking, activity \
feeds, wikis. It has LDAP/AD integration, can handle thousands of users on a single \
server but can also run on a highly available active/active cluster.

Do you want to Install Gitlab Server? " 16 68)
	then
		./install-gitlab.sh
	else
		continue
	fi
}

# Whiptail yes no - Install Egroupware Server
module='Egroupware Collaboration Server'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel --scrolltext "
EGroupware is free open source groupware software intended for businesses from small to \
enterprises. Its primary functions allow users to manage Contacts, Appointments, \
To-Do Lists, Ticketing & Bug Tracking, Document, Project and Resource Management.

It is used either via its native web-interface, making access platform-independent, or by \
using different supported groupware clients, such as Kontact, Novell Evolution, or \
Microsoft Outlook. It can also be used by mobile phone or PDA via SyncML.

It currently has translations for more than 25 languages, including right-to-left \
language support. It depends on a standard X-AMP System and as such requires no specific \
operating system. Most popular internet browsers are supported for use as web based clients

Do you want to Install Egroupware Collaboration Server? " 24 68)
	then
		./install-egw.sh
	else
		continue
	fi
}

# Whiptail yes no - Install Munin Monitoring Tool
module='Install Munin Monitoring Tool'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Munin the monitoring tool surveys all your computers and remembers what it saw. It presents \
all the information in graphs through a web interface. Its emphasis is on plug and play \
capabilities. After completing a installation a high number of monitoring plugins will be \
playing with no more effort.

Using Munin you can easily monitor the performance of your computers, networks, SANs, \
applications, weather measurements and whatever comes to mind. It makes it easy to \
determine \"what's different today\" when a performance problem crops up. 
It makes it easy to see how you're doing capacity-wise on any resources

Do you want to the Install Install Munin Monitoring Tool? " 22 68)
	then
		./install-munin.sh
	else
		continue
	fi
}

# Whiptail yes no - Install Webmin
module='Install Webmin'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Webmin is a web-based interface for system administration for Unix. Using any modern \
web browser, you can setup user accounts, Apache, DNS, file sharing and much more. Webmin \
removes the need to manually edit Unix configuration files like /etc/passwd, and lets you \
manage a system from the console or remotely.

See the standard modules page for a list of all the functions built into Webmin

Do you want to the Install Install Webmin? " 18 68)
	then
		# Make entry into /etc/apt/sources.list and install Webmin
		sudo cp -v /etc/apt/sources.list /etc/apt/sources.list-$date
		sudo sh -c 'echo -n "deb http://download.webmin.com/download/repository sarge contrib" >>/etc/apt/sources.list'
		wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
		sudo apt-get update
		sudo apt-get -y --force-yes install webmin
		# Writing out InstallNotes.txt reference file.
		notes=InstallNotes.txt
		echo ""
		echo "============================================================" | cat >>$notes
		echo "Webmin: Installed" | cat >>$notes
		echo "Webmin Port: 10000" | cat >>$notes
		# Check for bwtheme.wbt.gz file if not fetch it
		echo "getting latest version of the Webmin Bootstrap theme..."
		sleep 1
		{
   			if [ -f bwtheme.wbt.gz ] ; then
				# Copying Webmin Bootstrap theme into public share
   				cp -v bwtheme.wbt.gz /mnt/public/
   			else 
				wget http://theme.winfuture.it/bwtheme.wbt.gz
				# Copying Webmin Bootstrap theme into public share
				cp -v bwtheme.wbt.gz /mnt/public
			fi
		}
	else
		continue
	fi
}

# Read log file to see if Apache GnuTLS module is enabled.
echo ""
echo "Checking to see if Apache Webserver is configured for HTTPS using GnuTLS"
sleep 1
echo "if not, going to configure and setup HTTPS"
sleep 2
https=`cat <$log | grep https | awk '{print $3}'`
{
	if [ "$https" = "gnutls" ] ; then
		echo "Apache GnuTLS already configured - skipping..."
	else
		./enable-apache-tls.sh
	fi
}

# Install a few additional utilities
sudo apt-get -y --force-yes install htop iftop tree

# Copy the kerberise.sh script to /usr/local/bin/kerberise for easy execution
sudo cp -v client.info /usr/local/bin/server.info
sudo cp -v kerberise.sh /usr/local/bin/kerberise
sudo chmod +x /usr/local/bin/kerberise

# Tidy up the installation files
echo "tidying up installation files..."

# Collating all the LDIF files placed into the LDAP Server
mkdir ~/ldifs
mv -v *.ldif ~/ldifs/

# Setting up configs for Network Clients
echo "Placing Client Configuration files into SMB Public share..."
sleep 1
mkdir ~/client-configs
mv -v *.reg ~/client-configs/
mv -v client-ubuntu.sh ~/client-configs/
mv -v client.info ~/client-configs/

# Copying Client configs to SMB Public Share
cp -Rv ~/client-configs /mnt/public/

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "" | cat >>$notes
echo "============================================================" | cat >>$notes
echo "NOTE: Please complete any missing information in the file," | cat >>$notes
echo "once completed, please ensure you secure access to this file" | cat >>$notes
echo "and the \"install.info\" file inside "scripts" folder." | cat >>$notes
mv -v InstallNotes.txt ~

# Removing all temporary files created during install 
rm -rf *.temp
rm -rf *.passwd
rm br0.config
rm br1.config
rm -rf ldap.conf

# Capture console dimensions and set max sixe for whiptale
test -x /usr/bin/tty && console=`/usr/bin/tty`
test -z "$console" && console=/dev/console
size=$(stty size < $console)
screen_w=${size#*\ }
screen_h=${size%%\ *}
if [ "$screen_w" -gt 0 ]; then
	max_w=$((screen_w-6))
fi
if [ "$screen_h" -gt 0 ]; then
	max_h=$((screen_h-6))
fi

install=`cat <~/InstallNotes.txt`

# Whiptail info box to display installation summary (as large as possible)
module='Installation Summary'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --scrolltext --msgbox "
Please see below system instalaltion summary.
$install

Select OK to continue..."  $max_h $max_w 

# Whiptail menu to select interface configuration method.
module='Power Down System'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel "
Installation is now Complete, in order for certain programs to function correctly, it is \
recommended the system be rebooted.

Please select Power Down Options." 14 68 2 \
\
REBOOT ": Restart the system." \
\
HALT ": Turn the system OFF." \
2>power.temp

power=`cat <power.temp`

{
	if [ "$power" = "reboot" ]; then
		rm -rf power.temp
		sudo reboot
	else
		rm -rf power.temp
		sudo shutdown -h now
	fi
}