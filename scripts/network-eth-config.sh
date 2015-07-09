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
#         NAME: network-eth-config.sh
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
nicconfig=`cat <$log | grep nicconfig | awk '{print $3}'`
hostrole=`cat <$log | grep hostrole | awk '{print $3}'`
external=`cat <$log | grep external | awk '{print $3}'`
internal=`cat <$log | grep internal | awk '{print $3}'`
eth0config=`cat <$log | grep eth0config | awk '{print $3}'`
NetworkInterface0=`cat <$log | grep NetworkInterface0 | awk '{print $3}'`
eth0name=`cat <$log | grep eth0name | awk '{print $3}'`
eth0ports=`cat <$log | grep eth0ports | awk '{print $3" "$4" "$5}'`
eth0mac=`cat <$log | grep eth0mac | awk '{print $3}'`
eth2mac=`cat <$log | grep eth2mac | awk '{print $3}'`
eth0ipaddress=`cat <$log | grep eth0ipaddress | awk '{print $3}'`
eth0network=`cat <$log | grep eth0network | awk '{print $3}'`
eth0broadcast=`cat <$log | grep eth0broadcast | awk '{print $3}'`
eth0netmask=`cat <$log | grep eth0netmask | awk '{print $3}'`
eth0gateway=`cat <$log | grep eth0gateway | awk '{print $3}'`
eth1config=`cat <$log | grep eth1config | awk '{print $3}'`
NetworkInterface1=`cat <$log | grep NetworkInterface1 | awk '{print $3}'`
eth1name=`cat <$log | grep eth1name | awk '{print $3}'`
eth1ports=`cat <$log | grep eth1ports | awk '{print $3" "$4" "$5}'`
eth1mac=`cat <$log | grep eth1mac | awk '{print $3}'`
eth3mac=`cat <$log | grep eth3mac | awk '{print $3}'`
eth1ipaddress=`cat <$log | grep eth1ipaddress | awk '{print $3}'`
eth1network=`cat <$log | grep eth1network | awk '{print $3}'`
eth1broadcast=`cat <$log | grep eth1broadcast | awk '{print $3}'`
eth1netmask=`cat <$log | grep eth1netmask | awk '{print $3}'`
eth1gateway=`cat <$log | grep eth1gateway | awk '{print $3}'`

# Populate the INSTALL.INFO file
install=install.info

{
    if [ "$hostrole" = "standalone" ]; then
        echo "hostrole = standalone" | cat >>$install
        echo "nicno = $nicno" | cat >>$install
        echo "internalif = eth0" | cat >>$install
        echo "internalhw = $eth0ports" | cat >>$install
        echo "internalconfig = static" | cat >>$install
        echo "internaladdress = $eth0ipaddress" | cat >>$install
        echo "internalnetwork = $eth0network" | cat >>$install
        echo "internalbroadcast = $eth0broadcast" | cat >>$install
        echo "internalnetmask = $eth0netmask" | cat >>$install
        echo "internalgateway = $eth0gateway" | cat >>$install
    else
        echo "hostrole = gateway" | cat >>$install
        echo "nicno = $nicno" | cat >>$install
        {
            if [ "$external" = "eth0" ]; then
                echo "externalif = eth0" | cat >>$install
                echo "externalhw = $eth0ports" | cat >>$install
                {
                    if [ $eth0config = "dynamic" ]; then
                        echo "externalconfig = dhcp" | cat >>$install
                    else
                        echo "externalconfig = static" | cat >>$install
                        echo "externaladdress = $eth0ipaddress" | cat >>$install
                        echo "externalnetwork = $eth0network" | cat >>$install
                        echo "externalbroadcast = $eth0broadcast" | cat >>$install
                        echo "externalnetmask = $eth0netmask" | cat >>$install
                        echo "externalgateway = $eth0gateway" | cat >>$install
                    fi
                }
                echo "internalif = eth1" | cat >>$install
                echo "internalhw = $eth1ports" | cat >>$install
                {
                    if [ $eth1config = "dynamic" ]; then
                        echo "internalconfig = dhcp" | cat >>$install
                    else
                        echo "internalconfig = static" | cat >>$install
                        echo "internaladdress = $eth1ipaddress" | cat >>$install
                        echo "internalnetwork = $eth1network" | cat >>$install
                        echo "internalbroadcast = $eth1broadcast" | cat >>$install
                        echo "internalnetmask = $eth1netmask" | cat >>$install
                        echo "internalgateway = $eth1gateway" | cat >>$install
                    fi
                }
            else
                echo "externalif = eth1" | cat >>$install
                echo "externalhw = $eth1ports" | cat >>$install
                {
                    if [ $eth1config = "dynamic" ]; then
                        echo "externalconfig = dhcp" | cat >>$install
                    else
                        echo "externalconfig = static" | cat >>$install
                        echo "externaladdress = $eth1ipaddress" | cat >>$install
                        echo "externalnetwork = $eth1network" | cat >>$install
                        echo "externalbroadcast = $eth1broadcast" | cat >>$install
                        echo "externalnetmask = $eth1netmask" | cat >>$install
                        echo "externalgateway = $eth1gateway" | cat >>$install
                    fi
                }
                echo "internalif = eth0" | cat >>$install
                echo "internalhw = $eth0ports" | cat >>$install
                {
                    if [ $eth0config = "dynamic" ]; then
                        echo "internalconfig = dhcp" | cat >>$install
                    else
                        echo "internalconfig = static" | cat >>$install
                        echo "internaladdress = $eth0ipaddress" | cat >>$install
                        echo "internalnetwork = $eth0network" | cat >>$install
                        echo "internalbroadcast = $eth0broadcast" | cat >>$install
                        echo "internalnetmask = $eth0netmask" | cat >>$install
                        echo "internalgateway = $eth0gateway" | cat >>$install
                    fi
                }
            fi
        }
    fi
}
# Read out Internal IP Address form install.config

internaladdress=`cat <install.info | grep internaladdress | awk '{print $3}'`

# Split IP address into component octets
# Octet1
echo $internaladdress | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1~p" | cat >ipoctet1.temp
# Octet2
echo $internaladdress | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\2~p" | cat >ipoctet2.temp
# Octet3
echo $internaladdress | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\3~p" | cat >ipoctet3.temp
# Octet4
echo $internaladdress | sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4~p" | cat >ipoctet4.temp

# Read temporary values
ipoctet1=`cat <ipoctet1.temp`
ipoctet2=`cat <ipoctet2.temp`
ipoctet3=`cat <ipoctet3.temp`
ipoctet4=`cat <ipoctet4.temp`
# Output values into master.rpcf file
echo "internaloctet1 = $ipoctet1" | cat >>$install
echo "internaloctet2 = $ipoctet2" | cat >>$install
echo "internaloctet3 = $ipoctet3" | cat >>$install
echo "internaloctet4 = $ipoctet4" | cat >>$install

rm -rf *.temp
# Execute next script in sequence
./network-apply.sh