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
#         NAME: enable-apache-tls.sh
#      CREATED: 25-11-2014
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
cakey=`cat <$log | grep "cakey =" | awk '{print $3}'`
cacert=`cat <$log | grep "cacert =" | awk '{print $3}'`
serverkey=`cat <$log | grep "serverkey =" | awk '{print $3}'`
servercert=`cat <$log | grep "servercert =" | awk '{print $3}'`
#===============================================================================

# First disable any running SSL modules in apache
sudo a2dismod ssl

# Install the required packages ot enable TLS in apache
sudo apt-get -y --force-yes install libapache2-mod-gnutls

# Generate corrected /etc/apache2/sites-available/default-tls file
echo "<IfModule mod_gnutls.c> " | cat >default-tls
echo "<VirtualHost _default_:443>" | cat >>default-tls
echo "	ServerAdmin webmaster@localhost" | cat >>default-tls
echo "	DocumentRoot /var/www/html" | cat >>default-tls
echo "	<Directory />" | cat >>default-tls
echo "		Options FollowSymLinks" | cat >>default-tls
echo "		AllowOverride None" | cat >>default-tls
echo "	</Directory>" | cat >>default-tls
echo "	<Directory /var/www/html/>" | cat >>default-tls
echo "		Options Indexes FollowSymLinks MultiViews" | cat >>default-tls
echo "		AllowOverride None" | cat >>default-tls
echo "		Order allow,deny" | cat >>default-tls
echo "		allow from all" | cat >>default-tls
echo "	</Directory>" | cat >>default-tls
echo "	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" | cat >>default-tls
echo "	<Directory "/usr/lib/cgi-bin">" | cat >>default-tls
echo "		AllowOverride None" | cat >>default-tls
echo "		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" | cat >>default-tls
echo "		Order allow,deny" | cat >>default-tls
echo "		Allow from all" | cat >>default-tls
echo "	</Directory>" | cat >>default-tls
echo "	ErrorLog ${APACHE_LOG_DIR}/error.log" | cat >>default-tls
echo "	# Possible values include: debug, info, notice, warn, error, crit, alert, emerg." | cat >>default-tls
echo "	LogLevel warn" | cat >>default-tls
echo "	CustomLog ${APACHE_LOG_DIR}/ssl_access.log combined" | cat >>default-tls
echo "	#   GnuTLS Switch: Enable/Disable SSL/TLS for this virtual host." | cat >>default-tls
echo "	GnuTLSEnable On" | cat >>default-tls
echo "	#   A self-signed (snakeoil) certificate can be created by installing the ssl-cert package. See /usr/share/doc/apache2.2-common/README.Debian.gz for more info." | cat >>default-tls
echo "	GnuTLSCertificateFile	/etc/ssl/certs/$servercert" | cat >>default-tls
echo "	GnuTLSKeyFile /etc/ssl/private/$serverkey" | cat >>default-tls
echo "	#   See http://www.outoforder.cc/projects/apache/mod_gnutls/docs/#GnuTLSPriorities" | cat >>default-tls
echo "	GnuTLSPriorities NORMAL " | cat >>default-tls
echo "</VirtualHost> " | cat >>default-tls
echo "</IfModule>" | cat >>default-tls

# Copy generated TLS into place as Config file
sudo mv -v default-tls /etc/apache2/sites-available/default-tls.conf

# Disable the SSL Module
sudo a2dissite default-ssl.conf

# Enable GnuTLS Module
sudo a2ensite default-tls.conf

# Restart Apache
sudo service apache2 restart

# Make log entry for other scripts to read
echo "https = gnutls" | cat >>$log