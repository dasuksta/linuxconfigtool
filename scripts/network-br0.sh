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
#         NAME: network-br0.sh
#      CREATED: 04-04-2014
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

# Ensure at least x1 Inteface is detected and generate Bridging Logic.
{
    if [ "$nicno" = "" ]; then
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

# Set state of inteface. x1 Inteface, defaults to br0 = Internal
echo "internal = br0" | cat >>$log
cat br0.config | cat >>$log

# Whiptail menu to select interface configuration
module='Network Address Configuration'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
A scan of your system has found $nicno active interface, the Installer will now Auto-Configure the Bridged Network Object.

Installer will create One Bridged Device, please see below for a summary of the created object and the hardware assigned.

`cat <br0.temp`

Please select what IP address configuration will be used with the Network Interface known as: br0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
MANUAL ": Fixed or manually assigned IP address." \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
2>br0config.temp

# Enter interface configuration into install log.
echo "br0config = `cat <br0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
rm -rf br0config.temp
# Check temp file for Interface configuration
br0config=`cat <$log | grep br0config | awk '{print $3}'`
{
    if [ "$br0config" = "dynamic" ]; then
        echo "br0config = dhcp"
        whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
You have selected to configure the Only network interface without a fixed address.
A fixed address must provided in the current configuration.

The installer will now exit and remove any changes." 12 68
        rm -rf *.temp
        exit
    else

        # Capture current system IP Address - remove internal loopback address
        # delete BOTH leading and trailing whitespace from each line - delete the last line of file
        ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed 'd2' | cat >br0ipaddress.temp
        # Read current system IP address form temporary file
        br0ipaddress=`cat <br0ipaddress.temp`
        # Whiptail input box to manually enter IP Address
        module='IP Address - br0'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter a unique FIXED system address that is assigned to this host ONLY. If you are unsure contact your network administrator.

Please enter new System IP Address or slelct OK accept the currently assigned address.
NOTE: The current system address is displayed below." 16 68 $br0ipaddress 2>br0ipaddress.temp

        # Read assigned system IP address form temporary file
        br0ipaddress=`cat <br0ipaddress.temp`
            # Check for null entry
            {
                if [ "$br0ipaddress" = "" ] ; then
                    whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                    rm -rf *.temp
                    exit
                else
                    continue
                fi
            }
        # Use IP Address calculate network value
        sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.0~p" br0ipaddress.temp | cat >br0network.temp
        br0network=`cat <br0network.temp`
        # Use IP Address to calculate broadcast values
        sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.255~p" br0ipaddress.temp | cat >br0broadcast.temp
        br0broadcast=`cat <br0broadcast.temp`
        # Output values into log file
        echo "br0ipaddress = $br0ipaddress" | cat >>$log
        echo "br0network = $br0network" | cat >>$log
        echo "br0broadcast = $br0broadcast" | cat >>$log

        # Capture current system Subnet - remove any text - remove loopback subnet
        # delete BOTH leading and trailing whitespace from each line
        # delete all trailing blank lines at end of file
        ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  br0netmask.temp
        # Read current system Netmask address form temporary file
        br0netmask=`cat <br0netmask.temp`
        # Whiptail input box to manually enter Subnet Mask
        module='IP Subnet - br0'
        whiptail --title "$module - Subnet" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter your network subnet. If you are unsure contact your network administrator.

Please enter network subnet or slelct OK accept the currently assigned value.
NOTE: The current system subnet is displayed below."  16 68 $br0netmask 2>br0netmask.temp

        # Read assigned system IP address form temporary file
        br0netmask=`cat <br0netmask.temp`
        # Check for null entry
        {
            if [ "$br0netmask" = "" ] ; then
        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                rm -rf *.temp
                exit
            else
                continue
            fi
        }
        # Output interface assignment into configuration file
        echo "br0netmask = $br0netmask" | cat >>$log

        # Capture current system gateway - remove any 0.0.0.0 entries - remove any blank lines
        # delete BOTH leading and trailing whitespace from each line
        /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >br0gateway.temp
        # Read current network gateway address form temporary file
        br0gateway=`cat <br0gateway.temp`
        # Whiptail input box to manually enter Gateway Address
        module='IP Gateway - br0'
        whiptail --title "$module - gateway" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of your network gateway or Router, if you are unsure contact your network administrator.

Please enter your network gateway or slelct OK accept the currently assigned value.
NOTE: The current network gateway is displayed below." 16 68 $br0gateway 2>br0gateway.temp

        # Read current network gateway address form temporary file
        br0gateway=`cat <br0gateway.temp`
        # Check for null entry    
        {    
            if [ "$br0gateway" = "" ] ; then
        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                rm -rf *.temp
                exit
            else
                continue
            fi
        }
        # Output interface assignment into configuration file
        echo "br0gateway = $br0gateway" | cat >>$log
        # Remove any files with the .temp extension
        rm -rf *.temp
    fi
}
# Execute next script in sequence
./network-br-config.sh