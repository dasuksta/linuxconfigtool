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
#         NAME: network-br.sh
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
# Enter number of interfaces into configuration file.
nicno=`cat <nicno.temp`
echo "nicno = $nicno" | cat >>$log
rm -rf nicno.temp
nicno=`cat <$log | grep nicno | awk '{print $3}'`

# Whiptail message box giving summary regarding Bridged interface configuration
module='Network Bridging Inforamtion'
whiptail --title "$module" --backtitle "$product for $distro $version - $url"  --msgbox --nocancel "
A scan of your system has found $nicno or more network interfaces. The Installer will \
configure your network interfaces as Bridged Objects.

NOTE: If you have Two or more interfaces, then BRIDGING is recommended as the installer \
will automatically create the configuration, using the first FOUR cards found!

HELP: Bridging multiple interfaces is a more advanced configuration, but is very useful \
in multiple scenarios. One scenario is setting up a bridge with multiple network \
interfaces, then using a firewall to filter traffic between two network segments. Another \
scenario is using bridge on a system with one interface to allow virtual machines direct \
access to the outside network." 24 68

# Check the number of Interafce and invoke apporiate sub-script.
{
    if [ "$nicno" = "one" ]; then
        echo "hostrole = standalone" | cat >>$log
        # Write bridging logic into temp file
        echo "br0name = br0" | cat >br0.config
        echo "br0ports = eth0" | cat >>br0.config
        echo "eth0mac = $eth0mac" | cat >>br0.config
        echo "Bridge Name: br0" | cat >br0.temp
        echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
        ./network-br0.sh
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
        # Enter interface assignment into temp file.
        echo $hostrole | sed 's/\(.*\)/\L\1/' | cat >hostrole.temp
        # Enter interface assignment into configuration file.
        hostrole=`cat <hostrole.temp`
        echo "hostrole = $hostrole" | cat >>$log
        hostrole=`cat <$log | grep hostrole | awk '{print $3}'`

        # System interface configuration logic - Standalone mode
        {
            if [ "$hostrole" = "standalone" ]; then
                {
                    if [ "$nicno" = "one" ]; then
                        # Write bridging logic into temp file
                        echo "br0name = br0" | cat >br0.config
                        echo "br0ports = eth0" | cat >>br0.config
                        echo "eth0mac = $eth0mac" | cat >>br0.config
                        echo "Bridge Name: br0" | cat >br0.temp
                        echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                    else
                        continue
                   fi
                }
                {
                    if [ "$nicno" = "two" ]; then
                        # Write bridging logic into temp file
                        echo "br0name = br0" | cat >br0.config
                        echo "br0ports = eth0 eth1" | cat >>br0.config
                        echo "eth0mac = $eth0mac" | cat >>br0.config
                        echo "Bridge Name: br0" | cat >br0.temp
                        echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                        echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br0.temp
                    else
                        continue
                    fi
                }
                {
                    if [ "$nicno" = "three" ]; then
                        # Write bridging logic into temp file
                        echo "br0name = br0" | cat >br0.config
                        echo "br0ports = eth0 eth1 eth2" | cat >>br0.config
                        echo "eth0mac = $eth0mac" | cat >>br0.config
                        echo "eth1mac = $eth1mac" | cat >>br0.config
                        echo "eth2mac = $eth2mac" | cat >>br0.config
                        echo "Bridge Name: br0" | cat >br0.temp
                        echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                        echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br0.temp
                        echo "Bridged Inteface: eth2  Inteface MAC: $eth2mac" | cat >>br0.temp
                    else
                        continue
                    fi
                }
                {
                    if [ "$nicno" = "four" ]; then
                        # Write bridging logic into temp file
                        echo "br0name = br0" | cat >br0.config
                        echo "br0ports = eth0 eth1 eth2 eth3" | cat >>br0.config
                        echo "eth0mac = $eth0mac" | cat >>br0.config
                        echo "eth1mac = $eth1mac" | cat >>br0.config
                        echo "eth2mac = $eth2mac" | cat >>br0.config
                        echo "eth3mac = $eth3mac" | cat >>br0.config
                        echo "Bridge Name: br0" | cat >br0.temp
                        echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                        echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br0.temp
                        echo "Bridged Inteface: eth2  Inteface MAC: $eth2mac" | cat >>br0.temo
                        echo "Bridged Inteface: eth3  Inteface MAC: $eth3mac" | cat >>br0.temp
                    else
                        continue
                    fi
                ./network-br0.sh
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
                    # Write bridging logic into temp file
                    echo "br0name = br0" | cat >br0.config
                    echo "br0ports = eth0" | cat >>br0.config
                    echo "eth0mac = $eth0mac" | cat >>br0.config
                    echo "Bridge Name: br0" | cat >br0.temp
                    echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                    # Write bridging logic into temp file
                    echo "br1name = br1" | cat >br1.config
                    echo "br1ports = eth1" | cat >>br1.config
                    echo "eth1mac = $eth1mac" | cat >>br1.config
                    echo "Bridge Name: br1" | cat >br1.temp
                    echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br1.temp
                else
                    continue
                fi
            }
            {
                if [ "$nicno" = "three" ]; then
                    # Write bridging logic into temp file
                    echo "br0name = br0" | cat >br0.config
                    echo "br0ports = eth0 eth2" | cat >>br0.config
                    echo "eth0mac = $eth0mac" | cat >>br0.config
                    echo "Bridge Name: br0" | cat >br0.temp
                    echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                    # Write bridging logic into temp file
                    echo "br1name = br1" | cat >br1.config
                    echo "br1ports = eth1" | cat >>br1.config
                    echo "eth1mac = $eth1mac" | cat >>br1.config
                    echo "eth2mac = $eth2mac" | cat >>br1.config
                    echo "Bridge Name: br1" | cat >br1.temp
                    echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br1.temp
                    echo "Bridged Inteface: eth2  Inteface MAC: $eth2mac" | cat >>br1.temp
                else
                    continue
                fi
            }
            {
                if [ "$nicno" = "four" ]; then
                    # Write bridging logic into temp file
                    echo "br0name = br0" | cat >br0.config
                    echo "br0ports = eth0 eth2" | cat >>br0.config
                    echo "eth0mac = $eth0mac" | cat >>br0.config
                    echo "eth2mac = $eth2mac" | cat >>br0.config
                    echo "Bridge Name: br0" | cat >br0.temp
                    echo "Bridged Inteface: eth0  Inteface MAC: $eth0mac" | cat >>br0.temp
                    echo "Bridged Inteface: eth2  Inteface MAC: $eth2mac" | cat >>br0.temp
                    # Write bridging logic into temp file
                    echo "br1name = br1" | cat >br1.config
                    echo "br1ports = eth1 eth3" | cat >>br1.config
                    echo "eth1mac = $eth1mac" | cat >>br1.config
                    echo "eth3mac = $eth3mac" | cat >>br1.config
                    echo "Bridge Name: br1" | cat >br1.temp
                    echo "Bridged Inteface: eth1  Inteface MAC: $eth1mac" | cat >>br1.temp
                    echo "Bridged Inteface: eth3  Inteface MAC: $eth3mac" | cat >>br1.temp
                else
                    continue
                fi
            }
            # Whiptail menu to select external internal interface combination
            module='Interface Zone Selection'
            whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu  --scrolltext --nocancel "
A scan of your system has found $nicno active interfaces, the Installer will now \
Auto-Configure the Bridged Network Objects.

Installer will create two Bridged Devices, please see below for a summary of the created \
opjects and the hardware assigned to each object:
`cat <br0.temp`
`cat <br1.temp`
As you have selected Gateway Mode for this system, please select  the interface zone:

INETRNAL = The device that will be connected to you local network or LAN Switch.

EXTERNAL = The device that will be connected to the Router or Switch that is connected \
to the Internet or other external network." 24 68 2 \
\
br0 "= EXTERNAL and br1 = INTERNAL" \
\
br1 "= EXTERNAL and br0 = INTERNAL" \
2>externalnic.temp

            # Read current interface assignment form temp file
            externalnic=`cat <externalnic.temp`
            # Write Inteface assignment to logfile
            {
                if [ "$externalnic" = "br0" ]; then
                    echo "external = br0" | cat >>$log
                    echo "internal = br1" | cat >>$log
                else
                    echo "external = br1" | cat >>$log
                    echo "internal = br0" | cat >>$log
                fi
            }
            ./network-br1.sh
        else
            continue
        fi
    }
    exit
    fi
}