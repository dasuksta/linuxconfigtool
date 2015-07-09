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
#         NAME: network-eth.sh
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
echo "Network Config Started: $time" | cat >$log

# Maxium of 4 cards, others will be ingored for manual editing.
# Check ifconfig for installed network interface cards & output Put results into 
# 4 separate files to contain all configuration information for said interface.
ifconfig -a | grep eth0 | cat >eth0.temp
ifconfig -a | grep eth1 | cat >eth1.temp
ifconfig -a | grep eth2 | cat >eth2.temp
ifconfig -a | grep eth3 | cat >eth3.temp

# Check temp files for entries, if not remove blank files.
{
    if [ -s eth0.temp ]; then
        # Get device info form .temp file
        eth0=`cat <eth0.temp | awk '{print $1}'`
        eth0link=`cat <eth0.temp | awk '{print $3}'`
        eth0mac=`cat <eth0.temp | awk '{print $5}'`
        echo "one" | cat >nicno.temp
    else
        ./network-nil.sh
    fi
}
{
    if [ -s eth1.temp ]; then
        # Get device info form .temp file
        eth1=`cat <eth1.temp | awk '{print $1}'`
        eth1link=`cat <eth1.temp | awk '{print $3}'`
        eth1mac=`cat <eth1.temp | awk '{print $5}'`
        echo "two" | cat >nicno.temp
    else
        rm -rf eth1.temp
        continue
    fi
}
{
    if [ -s eth2.temp ]; then
        # Get device info form .temp file
        eth2=`cat <eth2.temp | awk '{print $1}'`
        eth2link=`cat <eth2.temp | awk '{print $3}'`
        eth2mac=`cat <eth2.temp | awk '{print $5}'`
        echo "three" | cat >nicno.temp
    else
        rm -rf eth2.temp
        continue
    fi
}
{
    if [ -s eth3.temp ]; then
        # Get device info form .temp file
        eth3=`cat <eth3.temp | awk '{print $1}'`
        eth3link=`cat <eth3.temp | awk '{print $3}'`
        eth3mac=`cat <eth3.temp | awk '{print $5}'`
        echo "four" | cat >nicno.temp
    else
        rm -rf eth3.temp
        continue
    fi
}
# Output number of interfaces into configuration file.
nicno=`cat <nicno.temp`
echo "nicno = $nicno" | cat >>$log
rm -rf nicno.temp
nicno=`cat <$log | grep nicno | awk '{print $3}'`


# Check the number of Interafce and invoke apporiate sub-script.
{
    if [ "$nicno" = "one" ]; then
        echo "hostrole = standalone" | cat >>$log
        # Write networking logic into temp file
        echo "eth0name = eth0" | cat >eth0.config
        echo "eth0ports = eth0" | cat >>eth0.config
        echo "eth0mac = $eth0mac" | cat >>eth0.config
        ./network-eth0.sh
    else 
        # Whiptail menu to select host role as Standalone or Gateway
        module='Host Role Selection'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
A scan of your system has found $nicno or more network interfaces. Please select what \
mode you would like this system to operate in?

STANDALONE - In this mode the system will provide services and resources to the network \
or domain such as:
Network Services, Domain & Directory, File Sharing etc...
In this mode NO network Traffic is forwarded (i.e. to the Internet) to other networks, \
besides DNS queries.

GATEWAY    - In addition the above services, in this mode this system will act as the \
primary gateway to the internet (or other networks) for all hosts within this network \
or domain.
Where applicable Outbount traffic (i.e. to the Internet) will be sent thourgh this \
system, where additional rules or restrictions can be applied to this traffic.

HELP: If you are unsure, please consult your network administrator or system docuemntation." 24 68 2 \
\
STANDALONE ": Connect to Internet via another system." \
\
GATEWAY ": Connects other systems to the Internet." \
2>hostrole.temp

        hostrole=`cat <hostrole.temp`
        # Output interface assignment into temp file.
        echo $hostrole | sed 's/\(.*\)/\L\1/' | cat >hostrole.temp
        # Output interface assignment into configuration file.
        hostrole=`cat <hostrole.temp`
        echo "hostrole = $hostrole" | cat >>$log
        hostrole=`cat <$log | grep hostrole | awk '{print $3}'`

        # System interface configuration logic - Standalone mode
        {
            if [ "$hostrole" = "standalone" ]; then
                {
                    if [ "$nicno" = "one" ]; then
                        # Write networking logic into temp file
                        echo "eth0name = eth0" | cat >eth0.config
                        echo "eth0ports = eth0" | cat >>eth0.config
                        echo "eth0mac = $eth0mac" | cat >>eth0.config
                    else
                        continue
                   fi
                }
                {
                    if [ "$nicno" = "two" ]; then
                        # Write networking logic into temp file
                        echo "eth0name = eth0" | cat >eth0.config
                        echo "eth0ports = eth0" | cat >>eth0.config
                        echo "eth0mac = $eth0mac" | cat >>eth0.config
                    else
                        continue
                    fi
                }
                {
                    if [ "$nicno" = "three" ]; then
                        # Write networking logic into temp file
                        echo "eth0name = eth0" | cat >eth0.config
                        echo "eth0ports = eth0" | cat >>eth0.config
                        echo "eth0mac = $eth0mac" | cat >>eth0.config
                    else
                        continue
                    fi
                }
                {
                    if [ "$nicno" = "four" ]; then
                        # Write networking logic into temp file
                        echo "eth0name = eth0" | cat >eth0.config
                        echo "eth0ports = eth0" | cat >>eth0.config
                        echo "eth0mac = $eth0mac" | cat >>eth0.config
                    else
                        continue
                    fi
                ./network-eth0.sh
                }
            else
                continue
            fi
        }
        {
            if [ "$hostrole" = "gateway" ]; then
        	# System interface configuration logic - Gateway mode
            {
                if [ "$nicno" = "two" ]; then
                    # Write networking logic into temp file
                    echo "eth0name = eth0" | cat >eth0.config
                    echo "eth0ports = eth0" | cat >>eth0.config
                    echo "eth0mac = $eth0mac" | cat >>eth0.config
                    # Write networking logic into temp file
                    echo "eth1name = eth1" | cat >eth1.config
                    echo "eth1ports = eth1" | cat >>eth1.config
                    echo "eth1mac = $eth1mac" | cat >>eth1.config
                else
                    continue
                fi
            }
            {
                if [ "$nicno" = "three" ]; then
                    # Write networking logic into temp file
                    echo "eth0name = eth0" | cat >eth0.config
                    echo "eth0ports = eth0" | cat >>eth0.config
                    echo "eth0mac = $eth0mac" | cat >>eth0.config
                    # Write networking logic into temp file
                    echo "eth1name = eth1" | cat >eth1.config
                    echo "eth1ports = eth1" | cat >>eth1.config
                    echo "eth1mac = $eth1mac" | cat >>eth1.config
                else
                    continue
                fi
            }
            {
                if [ "$nicno" = "four" ]; then
                    # Write networking logic into temp file
                    echo "eth0name = eth0" | cat >eth0.config
                    echo "eth0ports = eth0" | cat >>eth0.config
                    echo "eth0mac = $eth0mac" | cat >>eth0.config
                    # Write networking logic into temp file
                    echo "eth1name = eth1" | cat >eth1.config
                    echo "eth1ports = eth1" | cat >>eth1.config
                    echo "eth1mac = $eth1mac" | cat >>eth1.config
                else
                    continue
                fi
            }
            # Whiptail menu to select external internal interface combination
            module='Interface Zone Selection'
            whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu  --scrolltext --nocancel "
A scan of your system has found $nicno active interfaces, the Installer will now \
Auto-Configure the First Two (eth0 & eth1) Network Interfaces.

Installer will configure two Network Devices, please see below for a summary of the \
network interfaces and their hardware address:
`cat <eth0.temp`
`cat <eth1.temp`
As you have selected Gateway Mode for this system, please select the interface zone:

INETRNAL = The device that will be connected to you local network or LAN Switch.

EXTERNAL = The device that will be connected to the Router or Switch that is connected \
to the Internet or other external network." 24 68 2 \
\
eth0 "= EXTERNAL and eth1 = INTERNAL" \
\
eth1 "= EXTERNAL and eth0 = INTERNAL" \
2>externalnic.temp

            # Read current interface assignment form temp file
            externalnic=`cat <externalnic.temp`
            # Outpur Inteface assignment to logfile
            {
                if [ "$externalnic" = "eth0" ]; then
                    echo "external = eth0" | cat >>$log
                    echo "internal = eth1" | cat >>$log
                else
                    echo "external = eth1" | cat >>$log
                    echo "internal = eth0" | cat >>$log
                fi
            }
            ./network-eth1.sh
        else
            continue
        fi
    }
    exit
    fi
}