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
#         NAME: network-eth1.sh
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

hostrole=`cat <$log | grep hostrole | awk '{print $3}'`
{
    if [ "$hostrole" = "standalone" ]; then
        # Whiptail menu to select interface configuration
        module='eth0 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Standalone Mode, the Installer will now Auto-Configure the Bridged Network Object.

Installer will create One Bridged Device, please see below for a summary of the created \
object and the hardware assigned:
`cat <eth0.temp`
Please select what IP address configuration will be used with the Network Interface known as: eth0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>eth0config.temp

        # Enter interface configuration into install log.
        echo "eth0config = `cat <eth0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf eth0config.temp
        # Check temp file for Interface configuration
        eth0config=`cat <$log | grep eth0config | awk '{print $3}'`
        {
            if [ "$eth0config" = "dynamic" ]; then
                # Write Bridged interface hardware config into log file
                cat <eth0.config | cat >>$log
                echo "eth0config = dhcp"
            else
                # Write Bridged interface hardware config into log file
                cat <eth0.config | cat >>$log

                # Capture current system IP Address - remove internal loopback address
                # delete BOTH leading and trailing whitespace from each line delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '2d' | cat >eth0ipaddress.temp
                # Read current system IP address form temporary file
                eth0ipaddress=`cat <eth0ipaddress.temp`
                # Whiptail input box to manually enter IP Address
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

                # Capture current system Subnet - remove any text - remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line - delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  eth0netmask.temp
                # Read current system Netmask address form temporary file
                eth0netmask=`cat <eth0netmask.temp`
                # Whiptail input box to manually enter Subnet
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
                # Output interface assignment into configuration file
                echo "eth0netmask = $eth0netmask" | cat >>$log

                # Capture current system gateway - remove any 0.0.0.0 entries
                # remove any blank lines - delete BOTH leading and trailing whitespace from each line
                /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >eth0gateway.temp
                # Read current network gateway address form temporary file
                eth0gateway=`cat <eth0gateway.temp`
                # Whiptail to manually enter Gateway Address
                module='IP Gateway - eth0'
                whiptail --title "$module - gateway" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of your network gateway or Router, if you are unsure contact your network administrator.

Please enter your network gateway or slelct OK accept the currently assigned value.
NOTE: The current network gateway is displayed below." 16 68 $eth0gateway 2>eth0gateway.temp
                # Read current network gateway address form temporary file
                eth0gateway=`cat <eth0gateway.temp`
                # CHeckfor null entry    
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
    else
    	# Configure Gateway mode
    	# Whiptail menu to select interface configuration
        module='eth0 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Gateway Mode, the Installer will now Auto-Configure the Bridged Network Objects.

Installer will create Two Bridged Devices, please see below for a summary of the First \
object and the hardware assigned:
`cat <eth0.temp`
Please select what IP address configuration will be used with the Network Interface known as: eth0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>eth0config.temp
        # Output interface configuration into install log.
        echo "eth0config = `cat <eth0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf eth0config.temp
        # Check temp file for Interface configuration
        eth0config=`cat <$log | grep eth0config | awk '{print $3}'`
        # eth0 - CONFIGURE INTERFACE
        cat <$log 
        {
            if [ "$eth0config" = "dynamic" ]; then
                # Write interface hardware config into log file
                cat <eth0.config | cat >>$log
                echo "eth0config = dhcp"
            else
                # Write interface hardware config into log file
                cat <eth0.config | cat >>$log
                # Capture current system IP Address - emove internal loopback address
                # delete BOTH leading and trailing whitespace from each line delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '2d' | cat >eth0ipaddress.temp
                # Read current system IP address form temporary file
                eth0ipaddress=`cat <eth0ipaddress.temp`
                # Whiptail input box to manually enter IP Address
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

                # Capture current system Subnet - remove any text - remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line - delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  eth0netmask.temp
                # Read current system Netmask address form temporary file
                eth0netmask=`cat <eth0netmask.temp`
                # Whiptail input box to manually enter Subnet
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
                # Output interface assignment into configuration file
                echo "eth0netmask = $eth0netmask" | cat >>$log
                
                external=`cat <$log | grep external | awk '{print $3}'`
                {
                    if [ "$external" = "eth0" ]; then
                        # Capture current system gateway - remove any 0.0.0.0 entries - remove any blank lines
                        # delete BOTH leading and trailing whitespace from each line
                        /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >eth0gateway.temp
                        # Read current network gateway address form temporary file
                        eth0gateway=`cat <eth0gateway.temp`
                        # Whiptail input box to manually enter Gateway Address
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
                    else
                        continue
                    fi
                }
            fi
        }
        # eth1 - CONFIGURE GATEWAY MODE
        # Whiptail menu to select interface configuration
        module='eth1 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Gateway Mode, the Installer will now Auto-Configure the Bridged Network Objects.

Installer will create Two Bridged Devices, please see below for a summary of the Second \
object and the hardware assigned:
`cat <eth1.temp`
Please select what IP address configuration will be used with the Network Interface known as: eth1

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>eth1config.temp
        # Output interface configuration into install log.
        echo "eth1config = `cat <eth1config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf eth1config.temp
        
        # Check temp file for Interface configuration
        eth0config=`cat <$log | grep eth0config | awk '{print $3}'`
        eth1config=`cat <$log | grep eth1config | awk '{print $3}'`
        {
            if [ "$eth0config" = "$eth1config" ]; then
                whiptail --title "$error - Notice" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
A scan of your system as found that you have Selected to configure Both network objects with the same configuration!

If you have slected Manual for both interfaces, this is OK, but it you have selected Dynamic, then it is recommended that at least one object have a Fixed or Manually assigned IP Address. Unless you have another host on the network that will assign addresses.

NOTE: This Notice if for information only, select OK to continue." 20 68
            fi
        }
        # eth1 - CONFIGURE INTERFACE
        {
            if [ "$eth1config" = "dynamic" ]; then
                # Write interface hardware config into log file
                cat <eth1.config | cat >>$log
                echo "eth1config = dhcp"
            else
                # Write interface hardware config into log file
                cat <eth1.config | cat >>$log
                # Capture current system IP Address - remove internal loopback address
                # delete BOTH leading and trailing whitespace from each line - delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '1d' | cat >eth1ipaddress.temp
                # Read current system IP address form temporary file
                eth1ipaddress=`cat <eth1ipaddress.temp`
                # Whiptail input box to manually enter IP Address
                module='IP Address - eth1'
                whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter a unique FIXED system address that is assigned to this host ONLY. If you are unsure contact your network administrator.

Please enter new System IP Address or slelct OK accept the currently assigned address.
NOTE: The current system address is displayed below." 16 68 $eth1ipaddress 2>eth1ipaddress.temp

                # Read assigned system IP address form temporary file
                eth1ipaddress=`cat <eth1ipaddress.temp`
                    # Check for null entry
                    {
                        if [ "$eth1ipaddress" = "" ] ; then
                            whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                            rm -rf *.temp
                            exit
                        else
                            continue
                        fi
                    }
                # Use IP Address calculate network value
                sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.0~p" eth1ipaddress.temp | cat >eth1network.temp
                eth1network=`cat <eth1network.temp`
                # Use IP Address to calculate broadcast values
                sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.255~p" eth1ipaddress.temp | cat >eth1broadcast.temp
                eth1broadcast=`cat <eth1broadcast.temp`
                # Output values into log file
                echo "eth1ipaddress = $eth1ipaddress" | cat >>$log
                echo "eth1network = $eth1network" | cat >>$log
                echo "eth1broadcast = $eth1broadcast" | cat >>$log
                # Capture current system Subnet - remove any text - remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line - delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  eth1netmask.temp
                # Read current system Netmask address form temporary file
                eth1netmask=`cat <eth1netmask.temp`
                # Whiptail inout box to manually enter Subnet
                module='IP Subnet - eth1'
                whiptail --title "$module - Subnet" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter your network subnet. If you are unsure contact your network administrator.

Please enter network subnet or slelct OK accept the currently assigned value.
NOTE: The current system subnet is displayed below."  16 68 $eth1netmask 2>eth1netmask.temp

                # Read assigned system IP address form temporary file
                eth1netmask=`cat <eth1netmask.temp`
                # Check for null entry
                {
                    if [ "$eth1netmask" = "" ] ; then
                	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                        rm -rf *.temp
                        exit
                    else
                        continue
                    fi
                }
                # Output interface assignment into configuration file
                echo "eth1netmask = $eth1netmask" | cat >>$log
                
                external=`cat <$log | grep external | awk '{print $3}'`
                {
                    if [ "$external" = "eth1" ]; then
                        # Capture current system gateway - remove any 0.0.0.0 entries - remove any blank lines
                        # delete BOTH leading and trailing whitespace from each line
                        /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >eth1gateway.temp
                        # Read current network gateway address form temporary file
                        eth1gateway=`cat <eth1gateway.temp`
                        # Whiptail input box to manually enter gateway
                        module='IP Gateway - eth1'
                        whiptail --title "$module - gateway" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of your network gateway or Router, if you are unsure contact your network administrator.

Please enter your network gateway or slelct OK accept the currently assigned value.
NOTE: The current network gateway is displayed below." 16 68 $eth1gateway 2>eth1gateway.temp

                        # Read current network gateway address form temporary file
                        eth1gateway=`cat <eth1gateway.temp`
                        # Check for null entry    
                        {    
                            if [ "$eth1gateway" = "" ] ; then
                        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                                rm -rf *.temp
                                exit
                            else
                                continue
                            fi
                        }
                        # Output interface assignment into configuration file
                        echo "eth1gateway = $eth1gateway" | cat >>$log
                        # Remove any files with the .temp extension
                        rm -rf *.temp
                    else
                        continue
                    fi
                }
            fi
        }
    fi
}
# Execute next script in sequence
./network-eth-config.sh