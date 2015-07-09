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
#         NAME: service-dnsmasq.sh
#      CREATED: 11-04-2014
#      REVISED: 06-07-2015
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
kerberos=`cat <$log | grep "kerberos =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
hostrole=`cat <$log | grep "hostrole =" | awk '{print $3}'`
nicno=`cat <$log | grep "nicno =" | awk '{print $3}'`
nicconfig=`cat <$log | grep "nicconfig =" | awk '{print $3}'`
externalif=`cat <$log | grep "externalif =" | awk '{print $3}'`
externalhw=`cat <$log | grep "externalhw =" | awk '{print $3}'` # '{print $3" "$4" "$5}'`
externalconfig=`cat <$log | grep "externalconfig =" | awk '{print $3}'`
externaladdress=`cat <$log | grep "externaladdress =" | awk '{print $3}'`
externalnetwork=`cat <$log | grep "externalnetwork =" | awk '{print $3}'`
externalbroadcast=`cat <$log | grep "externalbroadcast =" | awk '{print $3}'`
externalnetmask=`cat <$log | grep "externalnetmask =" | awk '{print $3}'`
externalgateway=`cat <$log | grep "externalgateway =" | awk '{print $3}'`
internalif=`cat <$log | grep "internalif =" | awk '{print $3}'`
internalhw=`cat <$log | grep "internalhw =" | awk '{print $3}'` # '{print $3" "$4" "$5}'`
internalconfig=`cat <$log | grep "internalconfig =" | awk '{print $3}'`
internaladdress=`cat <$log | grep "internaladdress =" | awk '{print $3}'`
internalnetwork=`cat <$log | grep "internalnetwork =" | awk '{print $3}'`
internalbroadcast=`cat <$log | grep "internalbroadcast =" | awk '{print $3}'`
internalnetmask=`cat <$log | grep "internalnetmask =" | awk '{print $3}'`
internalgateway=`cat <$log | grep "internalgateway =" | awk '{print $3}'`
internaloctet1=`cat <$log | grep "internaloctet1 =" | awk '{print $3}'`
internaloctet2=`cat <$log | grep "internaloctet2 =" | awk '{print $3}'`
internaloctet3=`cat <$log | grep "internaloctet3 =" | awk '{print $3}'`
internaloctet4=`cat <$log | grep "internaloctet4 =" | awk '{print $3}'`

# Read logfile and Reverse Internal IP for DNS Server
internaladdress=`cat <$log | grep internaladdress | awk '{print $3}'`
echo "$internaladdress" | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p" | cat >reverseip.temp
reverseip=`cat <reverseip.temp`
# Generate leading IP octets and remove last value
echo "$internaladdress" | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3~p" | cat >start.temp
start=`cat <start.temp`

# Increase last IPv4 octet value by +1
expr $internaloctet4 + 1 | cat >startip.temp
startip=`cat <startip.temp`
# Checking value does not excede IPv4 range of x.x.x.254
{
	if [ "$startip" -gt "254" ] ; then
		# Replace value with 254
		echo "254" | cat >startip.temp
	else
		continue
	fi
}
# Reread file to update vaiable
startip=`cat <startip.temp`
echo "$start.$startip" | cat >dhcpstart.temp
dhcpstart=`cat <dhcpstart.temp`
# Whiptail input box to edit Start of DHCP Server IP range
module='DHCP Server Starting IP'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the starting IP address of your DHCP Server, if you are unsure contact your network administrator.

Please enter the Starting IP or select OK accept the currently assigned value.
NOTE: A recommended Start Address is displayed below." 14 68 $dhcpstart 2>dhcpstart.temp

# Read current network DHCP Start address form temporary file
dhcpstart=`cat <dhcpstart.temp`
# Check for null entry    
{    
    if [ "$dhcpstart" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}
# Read logfile check DHCP range does not clash with internal IP
dhcpstart=`cat <dhcpstart.temp`
{
    if [ "$dhcpstart" = "$internaladdress" ]; then
	    whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The Starting IP address enterd is the same as assigned to the internal interface.
Your current settings will be lost and the $module module will be restarted" 10 68
    	# Re-Start Modules
    	./service-dnsmasq.sh
	else
    	continue
    fi    
}

# Increase last IPv4 octet value by +100
expr $internaloctet4 + 100 | cat >endip.temp
endip=`cat <endip.temp`
# Checking value does not excede IPv4 range of x.x.x.254
{
	if [ "$endip" -gt "254" ] ; then
		# Replace value with 254
		echo "254" | cat >endip.temp
	else
		continue
	fi
}
# Reread file to update vaiable
endip=`cat <endip.temp`
echo "$start.$endip" | cat >dhcpend.temp
dhcpend=`cat <dhcpend.temp`
# Whiptail inout box to edit end of DHCP Server IP range
module='DHCP Server Ending IP'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the Ending IP address of your DHCP Server, if you are unsure contact your network administrator.

Please enter the Ending IP or select OK accept the currently assigned value.
NOTE: A recommended End Address is displayed below." 14 68 $dhcpend 2>dhcpend.temp

# Read current network DHCP Start address form temporary file
dhcpend=`cat <dhcpend.temp`
# Check for null entry    
{    
    if [ "$dhcpend" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}

# Read tempfile and check address conflict
dhcpend=`cat <dhcpend.temp`
{
    if [ "$dhcpend" = "$internaladdress" ]; then
    whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The Ending IP address enterd is the same as assigned to the internal interface.
Your current settings will be lost and the $module module will be restarted" 10 68
    	# Re-Start Modules
    	./service-dnsmasq.sh
	else
        continue
    fi    
}

internaladdress=`cat <$log | grep internaladdress | awk '{print $3}'`
# Whiptail to edit Gateway IP for DHCP config
module='DHCP Network Gateway Router'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP Address of the Gateway or Router your DHCP Server will assign to network hosts, if you are unsure contact your network administrator.

Please enter the Gateway IP or select OK accept the currently assigned value.
NOTE: A recommended Gateway Address is displayed below." 16 68 $internaladdress 2>dhcpgateway.temp

# Read current network DHCP Start address form temporary file
dhcpgateway=`cat <dhcpgateway.temp`
# Check for null entry    
{    
    if [ "$dhcpgateway" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}

internalnetmask=`cat <$log | grep internalnetmask | awk '{print $3}'`
# Whiptail input box to edit DHCP network netmask
module='DHCP Server Netmask'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the Network Subnet for your DHCP Server, if you are unsure contact your network administrator.

Please enter Network Subnet or select OK accept the currently assigned value.
NOTE: A recommended Network Subnet is displayed below." 14 68 $internalnetmask 2>dhcpnetmask.temp

# Read current network DHCP Start address form temporary file
dhcpnetmask=`cat <dhcpnetmask.temp`
# Check for null entry    
{    
    if [ "$dhcpnetmask" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}

# Read tempfile and check address conflict
dhcpnetmask=`cat <dhcpnetmask.temp`
{
    if [ "$dhcpnetmask" = "$internaladdress" ]; then
    	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The Ending IP address enterd is the same as assigned to the internal interface.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}

# Read /etc/resolv.conf file and extract first nameserver entry
cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | sed -e '2,$d' | cat >dns1.temp
dns1=`cat <dns1.temp`

# Check for null entry
{    
    if [ "$dns1" = "" ] ; then
    	# if null entry found output OpenDNS Name Server to temp file
	    echo "208.67.222.222" | cat >dns1.temp
	    # re-read to update variable
	    dns1=`cat <dns1.temp`
	else
		continue
	fi
}

# Whiptail inout box to edit Primary DNS Server
module='Primary DNS Server'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of you Primary DNS Server, if you are unsure contact your network administrator.

If you would like to use Public DNS servers for name resolution, please see below Primary Nameserver IP's for:
Google Public DNS Server: 8.8.8.8
OpenDNS Servers: 208.67.222.222

Please enter Primary DNS IP or select OK accept the currently assigned value.
NOTE: The current Primary DNS servers IP is displayed below." 20 68 $dns1 2>dns1.temp

# Read current network gateway address form temporary file
dns1=`cat <dns1.temp`
# Check for null entry    
{    
    if [ "$dns1" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}

# Read /etc/resolv.conf file and extract second nameserver entry
cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | sed -e '1d' | sed -e '2,$d' | cat >dns2.temp
dns2=`cat <dns2.temp`

# Check for null entry
{    
    if [ "$dns2" = "" ] ; then
    	# if null entry found output OpenDNS Name Server to temp file
	    echo "208.67.202.202" | cat >dns2.temp
	    # re-read to update variable
	    dns2=`cat <dns2.temp`
	else
		continue
	fi
}

# Whiptail input box to edit Secondary DNS Server
module='Secondary DNS Server'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of you Secondary DNS Server, if you are unsure contact your network administrator.

If you would like to use Public DNS servers for name resolution, please see below Secondary Nameserver IP's for:
Google Public DNS Server: 8.8.4.4
OpenDNS Server: 208.67.202.202

Please enter Secondary DNS IP or select OK accept the currently assigned value.
NOTE: The current Secondary DNS servers IP is displayed below." 20 68 $dns2 2>dns2.temp

# Read current network gateway address form temporary file
dns2=`cat <dns2.temp`
# Check for null entry    
{    
    if [ "$dns2" = "" ] ; then
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module.
Your current settings will be lost and the $module module will be restarted." 10 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
		continue
    fi
}


# Read temp files to check DNS servers IP addresses are not the same
dns1=`cat <dns1.temp`
dns2=`cat <dns2.temp`
{
    if [ "$dns1" = "$dns2" ]; then
        # Whiptail info box to advise of conflicting ip address
        whiptail --title "$error - Notice" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
A scan of your system as found that you have Selected to configure Both DNS Servers with the same IP Address!

You must provide at least two differrent IP addreses to ensure that DNS queries are correct.

NOTE: Your current settings will be lost and the $module module will be restarted." 16 68
        # Re-Start Module
        ./service-dnsmasq.sh
    else
        continue
    fi
}


# Whiptail yes no - summary of DNS DHCP changes to apply
module='Dnsmasq DNS <-> DHCP Server Summary'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
Your DNS <-> DHCP Server will be setup with the following configuration...

DNS Domain    = $fullname
DNS Server    = $fqdn
Server IP     = $internaladdress
IP Netmask    = $dhcpnetmask
IP Pool Start = $dhcpstart
IP Pool End   = $dhcpend
Gateway IP    = $dhcpgateway
Primary DNS   = $dns1
Secondary DNS = $dns2

Select Yes to Continue or select No to exit." 22 68)
	then
		continue
	else
		rm -rf *.temp
		exit
	fi
}

# Gather Variables and input into install log
echo "reverseip = $reverseip" | cat >>$log
echo "dhcpstart = $dhcpstart" | cat >>$log
echo "dhcpend = $dhcpend" | cat >>$log
echo "dhcpgateway = $dhcpgateway" | cat >>$log
echo "dhcpnetmask = $dhcpnetmask" | cat >>$log
echo "dns1 = $dns1" | cat >>$log
echo "dns2 = $dns2" | cat >>$log

# Remove any temp files
rm -rf *.temp

# Gather new variables from install log
dhcpstart=`cat <$log | grep dhcpstart | awk '{print $3}'`
dhcpend=`cat <$log | grep dhcpend | awk '{print $3}'`
dhcpgateway=`cat <$log | grep dhcpgateway | awk '{print $3}'`
dhcpnetmask=`cat <$log | grep dhcpnetmask | awk '{print $3}'`
dns1=`cat <$log | grep dns1 | awk '{print $3}'`
dns2=`cat <$log | grep dns2 | awk '{print $3}'`

# Install Dnsmasq DNS <-> DHCP server package
clear
echo ""
echo "Installing & configuring Dnsmasq DNS <-> DHCP server"
sleep 2
sudo apt-get -y --force-yes install dnsmasq
echo ""
echo "Generating Configuration: dnsmasq.conf"
sleep 2
echo "# $brand - Configuration generated on:$timestamp" | cat >dnsmasq.conf
#echo "# A bit of house keeping to prevent non-routable items being forwarded" | cat >>dnsmasq.conf
#echo "domain-needed" | cat >>dnsmasq.conf
#echo "bogus-priv" | cat >>dnsmasq.conf
#echo "no-resolv" | cat >>dnsmasq.conf
#echo "no-poll" | cat >>dnsmasq.conf
echo "# dnsmasq shal listen for DHCP and DNS requests only on specified interfaces (and the loopback)." | cat >>dnsmasq.conf
echo "interface=$internalif" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "#Use dnsmasq specific hosts file" | cat >>dnsmasq.conf
echo "no-hosts" | cat >>dnsmasq.conf
echo "addn-hosts=/etc/hosts.dnsmasq" | cat >>dnsmasq.conf
echo "#DNS Settings" | cat >>dnsmasq.conf
echo "server=/$fullname/$internaladdress" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "server=/#/$dns1" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "server=/#/$dns2" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "#" | cat >>dnsmasq.conf
echo "# adapted for a typical dnsmasq installation where the host running" | cat >>dnsmasq.conf
echo "# dnsmasq is also the host running samba." | cat >>dnsmasq.conf
echo "# you may want to uncomment some or all of them if you use" | cat >>dnsmasq.conf
echo "# Windows clients and Samba." | cat >>dnsmasq.conf
echo "dhcp-option=19,0           # option ip-forwarding off" | cat >>dnsmasq.conf
echo "dhcp-option=44,0.0.0.0     # set netbios-over-TCP/IP nameserver(s) aka WINS ser$" | cat >>dnsmasq.conf
echo "dhcp-option=45,0.0.0.0     # netbios datagram distribution server" | cat >>dnsmasq.conf
echo "dhcp-option=46,8           # netbios node type" | cat >>dnsmasq.conf
echo "#" | cat >>dnsmasq.conf
echo "domain=$fullname	#sets the domain name you're going to use" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "expand-hosts		#Appends domain name to simple LAN hostnames" | cat >>dnsmasq.conf
echo "dhcp-range=$dhcpstart,$dhcpend,12h		#sets the range from which to allocate IP addresses to clients and the lease time" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "dhcp-option=option:router,$internaladdress		#sets the IP address of the router (gateway address) to be given to clients" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "dhcp-option=option:ntp-server,$internaladdress		#sets the NTP server to Internal address" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "dhcp-authoritative		#makes this the authoritative (in this case ONLY) DHCP server on the network" | cat >>dnsmasq.conf
echo "#" | cat >>dnsmasq.conf
echo "# Server DNS settings... this is required as the server itself will" | cat >>dnsmasq.conf
echo "# not be obtaining it's IP address via DHCP and therefore would" | cat >>dnsmasq.conf
echo "# not be automatically added to the DNS records for forward/reverse" | cat >>dnsmasq.conf
echo "# DNS queries as required by Kerberos" | cat >>dnsmasq.conf
echo "ptr-record=$reverseip.in-addr.arpa.,\"$fqdn\" " | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "address=/$fqdn/$internaladdress" | cat >>dnsmasq.conf # <-- DYNAMIC ENTRY
echo "#" | cat >>dnsmasq.conf

# Make backup of original config
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf-$date
sudo cp -v dnsmasq.conf /etc/dnsmasq.conf
# Create Dnasmasq hosts file
sudo touch /etc/hosts.dnsmasq
sudo service dnsmasq restart

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "------------------------------------------------------------" | cat >>$notes
echo "DNS Server: Enabled" | cat >>$notes
echo "Domain Name: $fullname" | cat >>$notes
echo "Domain Server IP: $internaladdress" | cat >>$notes
echo "Primary DNS Server: $dns1" | cat >>$notes
echo "Secondary DNS Server: $dns2" | cat >>$notes
echo "------------------------------------------------------------" | cat >>$notes
echo "DHCP Server: Enabled" | cat >>$notes
echo "DHCP Server IP: $internaladdress" | cat >>$notes
echo "DHCP Gateway IP: $dhcpgateway" | cat >>$notes
echo "DHCP IP Pool Start: $dhcpstart" | cat >>$notes
echo "DHCP IP Pool End: $dhcpend" | cat >>$notes
# Removing .temp files
rm -rf *.temp