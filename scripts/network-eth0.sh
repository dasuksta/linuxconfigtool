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
#         NAME: network-eth0.sh
#      CREATED: 06-01-2015
#      REVISED: 17-06-2015
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
# NOTE: Logfile for Networking is NETWORK.INFO
log=network.info
nicno=`cat <$log | grep nicno | awk '{print $3}'`

# Check to ensure at least x1 Inteface is detected and generate Bridging Logic.
{
    if [ "$nicno" = "" ]; then
    	# Whiptail message box
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
A scan of your system has found NO Netwotk Interface hardware!!!

NOTE: You need to have at least One interface to configure this system. If you have a \
Network Interface installed plese ensure hardware is working correctly.

The Installer will now exit." 14 68
        # Report Error & Cleanup files
        rm -rf *.temp
        echo "Error = Missing_Network_Interface" | cat >>$log
        exit
    else    
        continue
    fi
}

# Set state of inteface. x1 Inteface, defaults to eth0 = Internal
echo "internal = eth0" | cat >>$log
cat eth0.config | cat >>$log

# Whiptail menu to select configuration of interace
module='Network Address Configuration'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
A scan of your system has found $nicno active interface, the Installer will now \
Auto-Configure the Network Interface.

Installer will create One Bridged Device, please see below for a summary of the created \
object and the hardware assigned:
`cat <eth0.temp`
Please select what IP address configuration will be used with the Network Interface known as: eth0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
MANUAL ": Fixed or manually assigned IP address." \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
2>eth0config.temp

# Output interface configuration into install log.
echo "eth0config = `cat <eth0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
rm -rf eth0config.temp
# Check temp file for Interface configuration
eth0config=`cat <$log | grep eth0config | awk '{print $3}'`
{
    if [ "$eth0config" = "dynamic" ]; then
        echo "eth0config = dhcp"
        # Whiptail message box
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
You have selected to configure the Only network interface without a fixed address.
A fixed address must provided in the current configuration.

The installer will now exit and remove any changes." 12 68
        rm -rf *.temp
        exit
    else
        # Capture current system IP Address - remove internal loopback address
        # delete BOTH leading and trailing whitespace from each line - delete the last line of file
        ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed 'd2' | cat >eth0ipaddress.temp
        # Read current system IP address form temporary file
        eth0ipaddress=`cat <eth0ipaddress.temp`
        # Whiptail input box to manually Enter IP Address
        module='IP Address - eth0'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter a unique FIXED system address that is assigned to this host ONLY. If you are unsure contact your network administrator.

Please enter new System IP Address or slelct OK accept the currently assigned address.
NOTE: The current system address is displayed below." 16 68 $eth0ipaddress 2>eth0ipaddress.temp

        # Read assigned system IP address form temporary file
        eth0ipaddress=`cat <eth0ipaddress.temp`
            # Check for null entry
            {
                if [ "$eth0ipaddress" = "" ] ; then
                    whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                    rm -rf *.temp
                    exit
                else
                    continue
                fi
            }
        # Use IP Address calculate network value
        sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.0~p" eth0ipaddress.temp | cat >eth0network.temp
        eth0network=`cat <eth0network.temp`
        # Use IP Address to calculate broadcast values
        sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.255~p" eth0ipaddress.temp | cat >eth0broadcast.temp
        eth0broadcast=`cat <eth0broadcast.temp`
        # Output values into log file
        echo "eth0ipaddress = $eth0ipaddress" | cat >>$log
        echo "eth0network = $eth0network" | cat >>$log
        echo "eth0broadcast = $eth0broadcast" | cat >>$log

        # Capture current system Subnet - remove any text - remove loopback subnet - 
        # delete BOTH leading and trailing whitespace from each line - delete all trailing blank lines at end of file
        ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  eth0netmask.temp
        # Read current system Netmask address form temporary file
        eth0netmask=`cat <eth0netmask.temp`
        # Whiptail manually enter Subnet
        module='IP Subnet - eth0'
        whiptail --title "$module - Subnet" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter your network subnet. If you are unsure contact your network administrator.

Please enter network subnet or slelct OK accept the currently assigned value.
NOTE: The current system subnet is displayed below."  16 68 $eth0netmask 2>eth0netmask.temp

        # Read assigned system IP address form temporary file
        eth0netmask=`cat <eth0netmask.temp`
        # Check for null entry
        {
            if [ "$eth0netmask" = "" ] ; then
        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                rm -rf *.temp
                exit
            else
                continue
            fi
        }
        # Enter interface assignment into configuration file
        echo "eth0netmask = $eth0netmask" | cat >>$log

        # Capture current system gateway - remove any 0.0.0.0 entries - remove any blank lines
        # delete BOTH leading and trailing whitespace from each line
        /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >eth0gateway.temp
        # Read current network gateway address form temporary file
        eth0gateway=`cat <eth0gateway.temp`
        # Whiptail input box to manually enter Gateway IP
        module='IP Gateway - eth0'
        whiptail --title "$module - gateway" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of your network gateway or Router, if you are unsure contact your network administrator.

Please enter your network gateway or slelct OK accept the currently assigned value.
NOTE: The current network gateway is displayed below." 16 68 $eth0gateway 2>eth0gateway.temp

        # Read current network gateway address form temporary file
        eth0gateway=`cat <eth0gateway.temp`
        # Check for null entry    
        {    
            if [ "$eth0gateway" = "" ] ; then
        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                rm -rf *.temp
                exit
            else
                continue
            fi
        }
        # Output interface assignment into configuration file
        echo "eth0gateway = $eth0gateway" | cat >>$log
        # Remove any files with the .temp extension
        rm -rf *.temp
    fi
}
# Execute next script in sequence
./network-eth-config.sh