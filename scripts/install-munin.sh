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
#         NAME: install-munin.sh
#      CREATED: 20-11-2014
#      REVISED: 28-06-2015
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
cwd=`cat <$log | grep "cwd =" | awk '{print $3}'`
sysadmin=`cat <$log | grep "sysadmin =" | awk '{print $3}'`
hostname=`cat <$log | grep "hostname =" | awk '{print $3}'`
domain=`cat <$log | grep "domain =" | awk '{print $3}'`
suffix=`cat <$log | grep "suffix =" | awk '{print $3}'`
fullname=`cat <$log | grep "fullname =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`

## Install Munin and extras
sudo apt-get -y --force-yes install munin munin-node munin-plugins-extra

# Change values in /etc/munin/munin.conf
# Set the directory for Munin in /var/www/munin
cat </etc/munin/munin.conf | sed 's/#dbdir/dbdir/' \
| sed 's/#htmldir/htmldir/' | sed 's/\/var\/cache\/munin\/www/\/var\/www\/munin/' \
| sed 's/#logdir/logdir/' | sed 's/#rundir/rundir/' \
| sed 's/#tmpldir/tmpldir/' \
| sed 's/\[localhost.localdomain\]/\['"$fqdn"'\]/' | cat >munin.conf

sudo cp /etc/munin/munin.conf /etc/munin/munin.conf-$date
sudo chown root:root munin.conf
sudo chmod 644 munin.conf
sudo mv -v munin.conf /etc/munin/munin.conf

# Changing values in /etc/munin/apache.conf
cat </etc/munin/apache.conf | sed 's/Alias \/munin \/var\/cache\/munin\/www/Alias \/munin \/var\/www\/munin/' \
| sed 's/<Directory \/var\/cache\/munin\/www>/<Directory \/var\/www\/munin>/' \
| sed 's/Allow from localhost 127.0.0.0\/8 ::1/Allow from all/' | cat >apache.conf

sudo cp /etc/munin/apache.conf /etc/munin/apache.conf-$date
sudo chown root:root apache.conf
sudo chmod 644 apache.conf
sudo mv -v apache.conf /etc/munin/apache.conf

sudo mkdir /var/www/munin
sudo chown munin:munin /var/www/munin

sudo service munin-node restart
sudo service apache2 restart

echo ""
echo "Munin Installed, you can access Munin Monitoring information at:"
echo "http://$fqdn/munin"
sleep 2
echo "NOTE: Please allow about 5 minutes for information to populate"
sleep 3

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "Munin: Installed" | cat >>$notes
echo "URL: http://$fqdn/munin" | cat >>$notes

# Removing .temp files
rm -rf *.temp