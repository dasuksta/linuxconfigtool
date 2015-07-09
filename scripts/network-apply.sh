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
#         NAME: network-apply.sh
#      CREATED: 10-10-2014
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

# Interface logic
echo ""
echo "Generating Configuration: interfaces"
sleep 1
echo "# $brand - Configuration generated on:$date at:$time" | cat >interfaces
        echo "auto lo" | cat >>interfaces
        echo "iface lo inet loopback" | cat >>interfaces
{
    if [ "$hostrole" = "standalone" ]; then
        echo "" | cat >>interfaces
        echo "auto $internalif" | cat >>interfaces
        echo "iface $internalif inet static" | cat >>interfaces
        echo "  address $internaladdress" | cat >>interfaces
        echo "  network $internalnetwork" | cat >>interfaces
        echo "  netmask $internalnetmask" | cat >>interfaces
        echo "  broadcast $internalbroadcast" | cat >>interfaces
        echo "  gateway $internalgateway" | cat >>interfaces
        {
        	if [ "$nicconfig" = "bridged" ]; then
        		echo "  bridge_ports $internalhw" | cat >>interfaces
        		echo "  bridge_fd 9" | cat >>interfaces
        		echo "  bridge_hello 2" | cat >>interfaces
        		echo "  bridge_maxage 12" | cat >>interfaces
        		echo "  bridge_stp off" | cat >>interfaces
        	else
        		continue
        	fi
        }
        echo "dns-search $fullname" | cat >>interfaces
        echo "dns-nameservers $internaladdress $dns1 $dns2" | cat >>interfaces
    else
        # External Interface
        {
            if [ "$externalconfig" = "dhcp" ]; then
                echo "" | cat >>interfaces
                echo "auto $externalif" | cat >>interfaces
                echo "iface $externalif inet dhcp" | cat >>interfaces
                {
        			if [ "$nicconfig" = "bridged" ]; then
                		echo "  bridge_ports $externalhw" | cat >>interfaces
                		echo "  bridge_fd 9" | cat >>interfaces
                		echo "  bridge_hello 2" | cat >>interfaces
                		echo "  bridge_maxage 12" | cat >>interfaces
                		echo "  bridge_stp off" | cat >>interfaces
                	else
                		continue
                	fi
                }
            else
                echo "" | cat >>interfaces
                echo "auto $externalif" | cat >>interfaces
                echo "iface $externalif inet static" | cat >>interfaces
                echo "  address $externaladdress" | cat >>interfaces
                echo "  network $externalnetwork" | cat >>interfaces
                echo "  netmask $externalnetmask" | cat >>interfaces
                echo "  broadcast $externalbroadcast" | cat >>interfaces
                echo "  gateway $externalgateway" | cat >>interfaces
                {
        			if [ "$nicconfig" = "bridged" ]; then
        				echo "  bridge_ports $externalhw" | cat >>interfaces
                		echo "  bridge_fd 9" | cat >>interfaces
                		echo "  bridge_hello 2" | cat >>interfaces
                		echo "  bridge_maxage 12" | cat >>interfaces
                		echo "  bridge_stp off" | cat >>interfaces
                	else
                		continue
                	fi
            	}
            fi
        }
        # Internal Interface
        {
            if [ "$internalconfig" = "dhcp" ]; then
                echo "" | cat >>interfaces
                echo "auto $internalif" | cat >>interfaces
                echo "iface $internalif inet dhcp" | cat >>interfaces
                {
        			if [ "$nicconfig" = "bridged" ]; then
		                echo "  bridge_ports $internalhw" | cat >>interfaces
        		        echo "  bridge_fd 9" | cat >>interfaces
                		echo "  bridge_hello 2" | cat >>interfaces
                		echo "  bridge_maxage 12" | cat >>interfaces
                		echo "  bridge_stp off" | cat >>interfaces
                	else
                		continue
                	fi
                }
            else
                echo "" | cat >>interfaces
                echo "auto $internalif" | cat >>interfaces
                echo "iface $internalif inet static" | cat >>interfaces
                echo "  address $internaladdress" | cat >>interfaces
                echo "  network $internalnetwork" | cat >>interfaces
                echo "  netmask $internalnetmask" | cat >>interfaces
                echo "  broadcast $internalbroadcast" | cat >>interfaces
                #echo "  gateway $internal-gateway" | cat >>interfaces
                {
        			if [ "$nicconfig" = "bridged" ]; then
		                echo "  bridge_ports $internalhw" | cat >>interfaces
        		        echo "  bridge_fd 9" | cat >>interfaces
                		echo "  bridge_hello 2" | cat >>interfaces
                		echo "  bridge_maxage 12" | cat >>interfaces
                		echo "  bridge_stp off" | cat >>interfaces
                	else
                		continue
                	fi
                }
                echo "dns-search $fullname" | cat >>interfaces
                echo "dns-nameservers $internaladdress $dns1 $dns2" | cat >>interfaces
            fi
        }
    fi
}

# Generate /etc/hostname file
echo ""
echo "Generating Configuration: hostname"
sleep 1
echo "$hostname" | cat >hostname # <-- DYNAMIC ENTRY

# Generate /etc/hosts file
echo ""
echo "Generating Configuration: hosts"
sleep 1
echo "# $brand - Configuration generated on:$timestamp" | cat >hosts
echo "127.0.0.1	localhost" | cat >>hosts
echo "127.0.1.1	$fqdn	$hostname" | cat >>hosts # <-- DYNAMIC ENTRY
echo "$internaladdress     $fqdn   $hostname" | cat >>hosts # <-- DYNAMIC ENTRY
echo "" | cat >>hosts
echo "# The following lines are desirable for IPv6 capable hosts" | cat >>hosts
echo "::1     ip6-localhost ip6-loopback" | cat >>hosts
echo "fe00::0 ip6-localnet" | cat >>hosts
echo "ff00::0 ip6-mcastprefix" | cat >>hosts
echo "ff02::1 ip6-allnodes" | cat >>hosts
echo "ff02::2 ip6-allrouters" | cat >>hosts

# Generate IPTables script to enable ip forwarding
echo ""
echo "Generating IP Forwarding Script: zzz-01gateway-rules"
sleep 1
{
    if [ "$hostrole" = "gateway" ]; then
		echo "#!/bin/sh" | cat >zzz-01gateway-rules
		echo "# delete all existing rules." | cat >>zzz-01gateway-rules
		echo "iptables -F" | cat >>zzz-01gateway-rules
		echo "iptables -t nat -F" | cat >>zzz-01gateway-rules
		echo "iptables -t mangle -F" | cat >>zzz-01gateway-rules
		echo "iptables -X" | cat >>zzz-01gateway-rules
		
		echo "# Always accept loopback traffic" | cat >>zzz-01gateway-rules
		echo "iptables -A INPUT -i lo -j ACCEPT" | cat >>zzz-01gateway-rules
		
		echo "# Allow outgoing connections from the LAN side." | cat >>zzz-01gateway-rules
		echo "iptables -A FORWARD -i $internalif -o $externalif -j ACCEPT" | cat >>zzz-01gateway-rules		
		
		echo "# Allow established connections, and those not coming from the outside" | cat >>zzz-01gateway-rules
		echo "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" | cat >>zzz-01gateway-rules
		echo "iptables -A FORWARD -i $externalif -o $internalif -m state --state ESTABLISHED,RELATED -j ACCEPT" | cat >>zzz-01gateway-rules
		
		echo "# Don't forward from the outside to the inside." | cat >>zzz-01gateway-rules
		echo "iptables -A FORWARD -i $externalif -o $internalif -j REJECT" | cat >>zzz-01gateway-rules
		
		echo "# Drop all incoming connections on external Interface" | cat >>zzz-01gateway-rules
		echo "#iptables -A INPUT -i $externalif -j DROP" | cat>>zzz-01gateway-rules
		
		echo "# Masquerade." | cat >>zzz-01gateway-rules
		echo "iptables -t nat -A POSTROUTING -o $externalif -j MASQUERADE" | cat >>zzz-01gateway-rules
		
		echo "# Enable routing." | cat >>zzz-01gateway-rules
		echo "echo 1 > /proc/sys/net/ipv4/ip_forward" | cat >>zzz-01gateway-rules

	else
		echo "Host configured as Standalone - NO IP Forwarding generated"	
	fi
}

# Generate /etc/ntp.conf file
echo ""
echo "Generating Configuration: ntp.conf"
sleep 1
echo "# $brand - Configuration generated on:$timestamp" | cat >ntp.conf
echo "# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "driftfile /var/lib/ntp/ntp.drift" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Enable this if you want statistics to be logged." | cat >>ntp.conf
echo "#statsdir /var/log/ntpstats/" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "statistics loopstats peerstats clockstats" | cat >>ntp.conf
echo "filegen loopstats file loopstats type day enable" | cat >>ntp.conf
echo "filegen peerstats file peerstats type day enable" | cat >>ntp.conf
echo "filegen clockstats file clockstats type day enable" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Specify one or more NTP servers." | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Use servers from the NTP Pool Project. Approved by Ubuntu Technical Board" | cat >>ntp.conf
echo "# on 2011-02-08 (LP: #104525). See http://www.pool.ntp.org/join.html for" | cat >>ntp.conf
echo "# more information." | cat >>ntp.conf
echo "server 0.ubuntu.pool.ntp.org" | cat >>ntp.conf
echo "server 1.ubuntu.pool.ntp.org" | cat >>ntp.conf
echo "server 2.ubuntu.pool.ntp.org" | cat >>ntp.conf
echo "server 3.ubuntu.pool.ntp.org" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Use Ubuntu's ntp server as a fallback." | cat >>ntp.conf
echo "server ntp.ubuntu.com" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for" | cat >>ntp.conf
echo "# details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>" | cat >>ntp.conf
echo "# might also be helpful." | cat >>ntp.conf
echo "#" | cat >>ntp.conf
echo "# Note that "restrict" applies to both servers and clients, so a configuration" | cat >>ntp.conf
echo "# that might be intended to block requests from certain clients could also end" | cat >>ntp.conf
echo "# up blocking replies from your own upstream servers." | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# By default, exchange time with everybody, but don't allow configuration." | cat >>ntp.conf
echo "restrict -4 default kod notrap nomodify nopeer noquery" | cat >>ntp.conf
echo "restrict -6 default kod notrap nomodify nopeer noquery" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Local users may interrogate the ntp server more closely." | cat >>ntp.conf
echo "restrict 127.0.0.1" | cat >>ntp.conf
echo "restrict ::1" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# Clients from this (example!) subnet have unlimited access, but only if" | cat >>ntp.conf
echo "# cryptographically authenticated." | cat >>ntp.conf
echo "#restrict 192.168.123.0 mask 255.255.255.0 notrust" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "" | cat >>ntp.conf
echo "# If you want to provide time to your local subnet, change the next line." | cat >>ntp.conf
echo "# (Again, the address is an example only.)" | cat >>ntp.conf
echo "broadcast $internalbroadcast" | cat >>ntp.conf # <-- DYNAMIC ENTRY
echo "" | cat >>ntp.conf
echo "# If you want to listen to time broadcasts on your local subnet, de-comment the" | cat >>ntp.conf
echo "# next lines.  Please do this only if you trust everybody on the network!" | cat >>ntp.conf
echo "#disable auth" | cat >>ntp.conf
echo "#broadcastclient" | cat >>ntp.conf

# Whiptail yes no - apply changes
module='Install Applications'
{
	if (whiptail --title "$module" --backtitle "$product for $distro $version - $url" --yesno --nocancel "
System Network configuration has been generated, do you want to apply these settings?

Hostname: $hostname  Domain: $fullname
System FQDN: $fqdn
Internal IP: $internaladdress
System Role: $hostrole

Appitional packages will be downloaded and installed to assist with: Inteface Bridging \
Utilities & Netwotk Time Protocol services.

Select Yes to Continue or select No to exit." 20 68)
	then
		# Installing packages
    	clear
		echo ""
		echo "Applying system changes..."
		sleep 1
		echo "Fetching Packages... please wait"
		sleep 1
		sudo apt-get update
		sudo apt-get -y --force-yes install bridge-utils ntp
		# Backing up config files
		clear
		echo ""
		echo "all config files backed up will have the suffix: *-$date"
		sleep 2
		sudo cp -v /etc/hostname /etc/hostname-$date
		sudo cp -v /etc/hosts /etc/hosts-$date
		sudo cp -v /etc/network/interfaces /etc/network/interfaces-$date
		sudo cp -v /etc/ntp.conf /etc/ntp.conf-$date
		# Placing generated configs into place
		echo "Applying Changes..."
		sleep 1
		sudo mv -v hostname /etc/hostname
		sudo mv -v hosts /etc/hosts
		sudo mv -v interfaces /etc/network/interfaces
		sudo mv -v ntp.conf /etc/ntp.conf
		sudo chown root:root /etc/hostname
		sudo chown root:root /etc/hosts
		sudo chown root:root /etc/network/interfaces
		sudo chown root:root /etc/ntp.conf
		{
		    if [ "$hostrole" = "gateway" ]; then
				sudo mv -v zzz-01gateway-rules /etc/network/if-up.d/
				sudo chmod +x /etc/network/if-up.d/zzz-01gateway-rules
				sudo chown root:root /etc/network/if-up.d/zzz-01gateway-rules
				sudo chmod 755 /etc/network/if-up.d/zzz-01gateway-rules
			else
				echo "Host configured as Standalone - NO IP Forwarding applied!"
			fi
		}
		# Applying changes
		sudo hostname $hostname
		sudo service hostname restart
		sudo service networking restart
		{
		    if [ "$hostrole" = "gateway" ]; then
				sudo /etc/network/if-up.d/./zzz-01gateway-rules
				echo "Firewall rules applied to host..."
				echo "Internal Interface: $internalif"
				echo "External Interface: $externalif"
				sleep 1
			else
				continue
			fi
		}
		sleep 1
		clear
		echo "Syncing with Internet NTP Time Servers"
		sleep 1
		ntpq -p
		sleep 3
		echo "Finished..."
	else
		clear
		echo ""
    	echo "Removing Configuration files..."
    	sleep 1
    	rm -v 00*
    	rm -v *.config
    	rm -v *.conf
        rm -v *.info
    	rm -v host*
    	rm -v interfaces
    	echo "Configuration files removed... Halting system!"
    	sleep 2
    	sudo shutdown -h now
	fi
}

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo "============================================================" | cat >>$notes
echo "Host Role: $hostrole" | cat >>$notes
echo "Number of Interfaces: $nicno" | cat >>$notes
echo "Interface Config: $nicconfig" | cat >>$notes
echo "IP Address: $internaladdress" | cat >>$notes
echo "Netmask: $internalnetmask" | cat >>$notes