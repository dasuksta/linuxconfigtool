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
#         NAME: network-br1.sh
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

hostrole=`cat <$log | grep hostrole | awk '{print $3}'`
{
    if [ "$hostrole" = "standalone" ]; then
        # Whiptail menu to select interface configuration
        module='br0 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Standalone Mode, the Installer will now Auto-Configure the Bridged Network Object.

Installer will create One Bridged Device, please see below for a summary of the created \
object and the hardware assigned:
`cat <br0.temp`
Please select what IP address configuration will be used with the Network Interface known as: br0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>br0config.temp

        # Enter interface configuration into install log.
        echo "br0config = `cat <br0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf br0config.temp
        # Check temp file for Interface configuration
        br0config=`cat <$log | grep br0config | awk '{print $3}'`
        {
            if [ "$br0config" = "dynamic" ]; then
                # Write Birdged interface hardware config into log file
                cat <br0.config | cat >>$log
                echo "br0config = dhcp"
            else
                # Write Birdged interface hardware config into log file
                cat <br0.config | cat >>$log
                # Capture Current system IP Address - remove internal loopback address
                # delete BOTH leading and trailing whitespace from each line - delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '2d' | cat >br0ipaddress.temp
                # Read current system IP address form temporary file
                br0ipaddress=`cat <br0ipaddress.temp`
                # Whiptail input box to enter enter IP Address
                module='IP Address - br0'
                whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter a unique FIXED system address that is assigned to this host ONLY. If you are unsure contact your network administrator.

Please enter new System IP Address or slelct OK accept the currently assigned address.
NOTE: The current system address is displayed below." 16 68 $br0ipaddress 2>br0ipaddress.temp
                # Read assigned system IP address form temporary file
                br0ipaddress=`cat <br0ipaddress.temp`
                    # Check for NULL entry
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
                # Write values into log file
                echo "br0ipaddress = $br0ipaddress" | cat >>$log
                echo "br0network = $br0network" | cat >>$log
                echo "br0broadcast = $br0broadcast" | cat >>$log
                # Capture Current system Subnet - remove any text - remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line
                # delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  br0netmask.temp
                # Read current system Netmask address form temporary file
                br0netmask=`cat <br0netmask.temp`
                # Whiptail input box to manually enter Subnet Netmask
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
                # Enter interface assignment into configuration file
                echo "br0netmask = $br0netmask" | cat >>$log
                # Capture Current system gateway - remove any 0.0.0.0 entries - remove any blank 
                # lines - delete BOTH leading and trailing whitespace from each line
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
    else
    	# Configure Gateway mode
        # Whiptail menu to select interface configuration
        module='br0 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Gateway Mode, the Installer will now Auto-Configure the Bridged Network Objects.

Installer will create Two Bridged Devices, please see below for a summary of the First \
object and the hardware assigned:
`cat <br0.temp`
Please select what IP address configuration will be used with the Network Interface known as: br0

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>br0config.temp
        # Output interface configuration into install log.
        echo "br0config = `cat <br0config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf br0config.temp
        # Check temp file for interface configuration
        br0config=`cat <$log | grep br0config | awk '{print $3}'`
        # BR0 - CONFIGURE INTERFACE
        cat <$log 
        {
            if [ "$br0config" = "dynamic" ]; then
                # Write Birdged interface hardware config into log file
                cat <br0.config | cat >>$log
                echo "br0config = dhcp"
            else
                # Write Birdged interface hardware config into log file
                cat <br0.config | cat >>$log
                # Capture current system IP Address - remove internal loopback address
                # delete BOTH leading and trailing whitespace from each line delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '2d' | cat >br0ipaddress.temp
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
                # Capture current system Subnet - remove any text remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line
                # delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  br0netmask.temp
                # Read current system Netmask address form temporary file
                br0netmask=`cat <br0netmask.temp`
                # Whiptail input box to manually enter Subnet Netmask
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
                external=`cat <$log | grep external | awk '{print $3}'`
                {
                    if [ "$external" = "br0" ]; then
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
                    else
                        continue
                    fi
                }
            fi
        }
        # BR1 - CONFIGURE GATEWAY MODE 
        # Whiptail menu to select interfcae configuration
        module='br1 - Network Address Configuration'
        whiptail --title "$module" --backtitle "$product for $distro $version - $url" --menu --nocancel --scrolltext "
You have selected to configure this system in Gateway Mode, the Installer will now Auto-Configure the Bridged Network Objects.

Installer will create Two Bridged Devices, please see below for a summary of the Second \
object and the hardware assigned:
`cat <br1.temp`
Please select what IP address configuration will be used with the Network Interface known as: br1

HELP: If you are unsure, please consult your network administrator or system docuemntation." 20 68 2 \
\
DYNAMIC ": Dynamically assigned address via DHCP." \
\
MANUAL ": Fixed or manually assigned IP address." \
2>br1config.temp
        # Output interface configuration into install log
        echo "br1config = `cat <br1config.temp`" | sed 's/\(.*\)/\L\1/' | cat >>$log
        rm -rf br1config.temp
        
        # Check temp file for interface configuration
        br0config=`cat <$log | grep br0config | awk '{print $3}'`
        br1config=`cat <$log | grep br1config | awk '{print $3}'`
        {
            if [ "$br0config" = "$br1config" ]; then
                # Whiptail info box to inform of configuration
                whiptail --title "$error - Notice" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
A scan of your system as found that you have Selected to configure Both network objects with the same configuration!

If you have slected Manual for both interfaces, this is OK, but it you have selected \
Dynamic, then it is recommended that at least one object have a Fixed or Manually \
assigned IP Address. Unless you have another host on the network that will assign addresses.

NOTE: This Notice if for information only, select OK to continue." 20 68
            fi
        }
        # BR1 - CONFIGURE INTERFACE
        {
            if [ "$br1config" = "dynamic" ]; then
                # Write Birdged interface hardware config into log file
                cat <br1.config | cat >>$log
                echo "br1config = dhcp"
            else
                # Write Birdged interface hardware config into log file
                cat <br1.config | cat >>$log
                # Capture current system IP Address - remove internal loopback address
                # delete BOTH leading and trailing whitespace from each line delete the last line of file
                ifconfig | sed -rn 's/.*r:([^ ]+) .*/\1/p' | sed -e 's/^127.0.0.1//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | sed '1d' | cat >br1ipaddress.temp
                # Read current system IP address form temporary file
                br1ipaddress=`cat <br1ipaddress.temp`
                # Whiptail inout box to manually enter IP Address
                module='IP Address - br1'
                whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter a unique FIXED system address that is assigned to this host ONLY. If you are unsure contact your network administrator.

Please enter new System IP Address or slelct OK accept the currently assigned address.
NOTE: The current system address is displayed below." 16 68 $br1ipaddress 2>br1ipaddress.temp

                # Read assigned system IP address form temporary file
                br1ipaddress=`cat <br1ipaddress.temp`
                    # Checkfor null entry
                    {
                        if [ "$br1ipaddress" = "" ] ; then
                            whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                            rm -rf *.temp
                            exit
                        else
                            continue
                        fi
                    }
                # Use IP Address calculate network value
                sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.0~p" br1ipaddress.temp | cat >br1network.temp
                br1network=`cat <br1network.temp`
                # Use IP Address to calculate broadcast values
                sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\1.\2.\3.255~p" br1ipaddress.temp | cat >br1broadcast.temp
                br1broadcast=`cat <br1broadcast.temp`
                # Output values into log file
                echo "br1ipaddress = $br1ipaddress" | cat >>$log
                echo "br1network = $br1network" | cat >>$log
                echo "br1broadcast = $br1broadcast" | cat >>$log
                # Capture current system Subnet - remove any text remove loopback subnet
                # delete BOTH leading and trailing whitespace from each line - delete all trailing blank lines at end of file
                ifconfig | sed -n '/dr:/{;s/.*://;s/ .*//;p;}' | sed -e 's/^[Aa-Zz]*//' | sed -e 's/^255.0.0.0//' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | cat >  br1netmask.temp
                # Read current system Netmask address form temporary file
                br1netmask=`cat <br1netmask.temp`
                # Whiptail input box to manually enter Subnet
                module='IP Subnet - br1'
                whiptail --title "$module - Subnet" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter your network subnet. If you are unsure contact your network administrator.

Please enter network subnet or slelct OK accept the currently assigned value.
NOTE: The current system subnet is displayed below."  16 68 $br1netmask 2>br1netmask.temp

                # Read assigned system IP address form temporary file
                br1netmask=`cat <br1netmask.temp`
                # Check for null entry
                {
                    if [ "$br1netmask" = "" ] ; then
                	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                        rm -rf *.temp
                        exit
                    else
                        continue
                    fi
                }
                # Output interface assignment into configuration file
                echo "br1netmask = $br1netmask" | cat >>$log
                
                external=`cat <$log | grep external | awk '{print $3}'`
                {
                    if [ "$external" = "br1" ]; then
                        # Capture current system gateway - remove any 0.0.0.0 entries - remove any blank lines
                        # delete BOTH leading and trailing whitespace from each line
                        /sbin/route -n | grep 0.0.0.0 | awk '{print $2}' | sed -e 's/0.0.0.0*//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | cat >br1gateway.temp
                        # Read current network gateway address form temporary file
                        br1gateway=`cat <br1gateway.temp`
                        # Whiptail input box to manually enter Gateway IP
                        module='IP Gateway - br1'
                        whiptail --title "$module - gateway" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Please enter the IP address of your network gateway or Router, if you are unsure contact your network administrator.

Please enter your network gateway or slelct OK accept the currently assigned value.
NOTE: The current network gateway is displayed below." 16 68 $br1gateway 2>br1gateway.temp

                        # Read current network gateway address form temporary file
                        br1gateway=`cat <br1gateway.temp`
                        # Check for null entry    
                        {    
                            if [ "$br1gateway" = "" ] ; then
                        	whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
                                rm -rf *.temp
                                exit
                            else
                                continue
                            fi
                        }
                        # Output interface assignment into configuration file
                        echo "br1gateway = $br1gateway" | cat >>$log
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
./network-br-config.sh