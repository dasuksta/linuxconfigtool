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
#         NAME: install-gitlab.sh
#      CREATED: 03-11-2014
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
cwd=`cat <$log | grep cwd | awk '{print $3}'`
sysadmin=`cat <$log | grep "sysadmin =" | awk '{print $3}'`
hostname=`cat <$log | grep "hostname =" | awk '{print $3}'`
domain=`cat <$log | grep "domain =" | awk '{print $3}'`
suffix=`cat <$log | grep "suffix =" | awk '{print $3}'`
fullname=`cat <$log | grep "fullname =" | awk '{print $3}'`
internaladdress=`cat <$log | grep "internaladdress =" | awk '{print $3}'`
kerberos=`cat <$log | grep "kerberos =" | awk '{print $3}'`
fqdn=`cat <$log | grep "fqdn =" | awk '{print $3}'`
cakey=`cat <$log | grep "cakey =" | awk '{print $3}'`
cacert=`cat <$log | grep "cacert =" | awk '{print $3}'`
ldapadmin=`cat <$log | grep "ldapadmin =" | awk '{print $3}'`
ldappasswd=`cat <$log | grep "ldappasswd =" | awk '{print $3}'`
uidstart=`cat <$log | grep "uidstart =" | awk '{print $3}'`
uidend=`cat <$log | grep "uidend =" | awk '{print $3}'`
gidstart=`cat <$log | grep "gidstart =" | awk '{print $3}'`
gidend=`cat <$log | grep "gidend =" | awk '{print $3}'`
midstart=`cat <$log | grep "midstart =" | awk '{print $3}'`
midend=`cat <$log | grep "midend =" | awk '{print $3}'`
netadmin=`cat <$log | grep "netadmin =" | awk '{print $3}'`
netadmingrp=`cat <$log | grep "netadmingrp =" | awk '{print $3}'`
netadminpasswd=`cat <$log | grep "netadminpasswd =" | awk '{print $3}'`
realm=`cat <$log | grep "realm =" | awk '{print $3}'`
kdc=`cat <$log | grep "kdc =" | awk '{print $3}'`
admin_server=`cat <$log | grep "admin_server =" | awk '{print $3}'`
mainshare=`cat <$log | grep "mainshare =" | awk '{print $3}'`

# Suggest alternative Port number for Gitlab
echo "20000" | cat >gitlabport.temp
gitlabport=`cat <gitlabport.temp`

# Whiptail input box where user can enter value
module='Gitlab Port'
whiptail --title "$module" --backtitle "$product for $distro $version - $url" --inputbox --nocancel "
Open source software to collaborate on code

The Gitlab installer contains everything it needs in one package, all its depencies \
(Ruby, PostgreSQL, Redis, Nginx, Unicorn, etc.).
However the bundled webserver (Nginx) defaults to run on Port 80, but this port is \
also used by the Apache webserver, in order to avoid any conflicts please select an \
alternative port number on which to serve Gitlab to your network.

NOTE: DO NOT USE PORTS 80 & 443

Please enter Port Number to serve Gitlab:" 20 68 $gitlabport 2>gitlabport.temp

gitlabport=`cat <gitlabport.temp`
	# Check for null entry
	{
    	if [ "$gitlabport" = "" ] ; then
    		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
No value has been entered for the $module module. The installer will now exit and remove any changes." 10 68
	    		rm -rf *.temp
            	exit
        	else
	    	continue
    	fi
	}
		# Check for Port 80
	{
    	if [ "$gitlabport" = "80" ] ; then
    		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The value entered cannot be used for the $module module. The installer will remove any changes and restart." 10 68
	    		rm -rf *.temp
	    		./install-gitlab.sh
        	else
	    	continue
    	fi
	}
			# Check for Port 443
	{
    	if [ "$gitlabport" = "443" ] ; then
    		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The value entered cannot be used for the $module module. The installer will remove any changes and restart." 10 68
	    		rm -rf *.temp
	    		./install-gitlab.sh
        	else
	    	continue
    	fi
	}

			# Check for Port 10000, thi will prevent clashes with Webmin
	{
    	if [ "$gitlabport" = "10000" ] ; then
    		whiptail --title "$error" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The value entered cannot be used for the $module module. The installer will remove any changes and restart." 10 68
	    		rm -rf *.temp
	    		./install-gitlab.sh
        	else
	    	continue
    	fi
	}

# Check for Gitlab .deb package
{
   	if [ -f gitlab-ce_7.11.4~omnibus-1_amd64.deb ] ; then   	
   		continue
   	else
   		whiptail --title "GitLab CE Omnibus package MISSING!!!" --backtitle "$product for $distro $version - $url" --msgbox --nocancel "
The GitLab CE Omnibus package (installer) is missing, this is required for GitLab CE to be \
installed and configured. The installer will attempt to fetch that latest version and \
complete installation.

You can manually download the latest version form: \
https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/gitlab-ce_7.11.4~omnibus-1_amd64.deb/download" 14 68

		# Attempt to fetch the latest script
		clear
		echo "Connecting to: https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty"
		echo "pulling down GitLab CE Omnibus package"
		wget https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/gitlab-ce_7.11.4~omnibus-1_amd64.deb/download
        # Re-Start Module
        #./install-dazzle.sh
        	{
   				if [ -f dazzle.sh ] ; then
   					continue
   				else
   					echo "dazzle.sh script not found - exiting..."
   					exit
   				fi
   			}
    fi
}

# Install Gitlab from package
echo "Installing Gitlab Omnibus Package"
echo "this may take some time, please wait..."
echo ""
sudo dpkg -i gitlab-ce_7.11.4~omnibus-1_amd64.deb

# Make a local copy of the Gitlab configuration file
sudo cat /var/opt/gitlab/gitlab-rails/etc/gitlab.yml >gitlabyml.temp

# Generating /var/opt/gitlab/gitlab-rails/etc/gitlabyml.temp
echo "# This file is managed by gitlab-ctl. Manual changes will be" | cat >gitlabyml.temp
echo "# erased! To change the contents below, edit /etc/gitlab/gitlab.rb" | cat >>gitlabyml.temp
echo "# and run \`sudo gitlab-ctl reconfigure\`." | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "production: &base" | cat >>gitlabyml.temp
echo "  #" | cat >>gitlabyml.temp
echo "  # 1. GitLab app settings" | cat >>gitlabyml.temp
echo "  # ==========================" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## GitLab settings" | cat >>gitlabyml.temp
echo "  gitlab:" | cat >>gitlabyml.temp
echo "    ## Web server settings (note: host is the FQDN, do not include http://)" | cat >>gitlabyml.temp
echo "    host: $fullname" | cat >>gitlabyml.temp
echo "    port: $gitlabport" | cat >>gitlabyml.temp
echo "    https: false" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # Uncommment this line below if your ssh host is different from HTTP/HTTPS one" | cat >>gitlabyml.temp
echo "    # (you'd obviously need to replace ssh.host_example.com with your own host)." | cat >>gitlabyml.temp
echo "    # Otherwise, ssh host will be set to the \`host:\` value above" | cat >>gitlabyml.temp
echo "    ssh_host: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # WARNING: See config/application.rb under \"Relative url support\" for the list of" | cat >>gitlabyml.temp
echo "    # other files that need to be changed for relative url support" | cat >>gitlabyml.temp
echo "    # relative_url_root: /gitlab" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # Uncomment and customize if you can't use the default user to run GitLab (default: 'git')" | cat >>gitlabyml.temp
echo "    user: git" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Email settings" | cat >>gitlabyml.temp
echo "    # Email address used in the \"From\" field in mails sent by GitLab" | cat >>gitlabyml.temp
echo "    email_from: gitlab@$fullname" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # Email server smtp settings are in [a separate file](initializers/smtp_settings.rb.sample)." | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## User settings" | cat >>gitlabyml.temp
echo "    default_projects_limit: " | cat >>gitlabyml.temp
echo "    default_can_create_group:   # default: true" | cat >>gitlabyml.temp
echo "    username_changing_enabled:  # default: true - User can change her username/namespace" | cat >>gitlabyml.temp
echo "    ## Default theme" | cat >>gitlabyml.temp
echo "    ##   BASIC  = 1" | cat >>gitlabyml.temp
echo "    ##   MARS   = 2" | cat >>gitlabyml.temp
echo "    ##   MODERN = 3" | cat >>gitlabyml.temp
echo "    ##   GRAY   = 4" | cat >>gitlabyml.temp
echo "    ##   COLOR  = 5" | cat >>gitlabyml.temp
echo "    default_theme:  # default: 2" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Users can create accounts" | cat >>gitlabyml.temp
echo "    # This also allows normal users to sign up for accounts themselves" | cat >>gitlabyml.temp
echo "    # default: false - By default GitLab administrators must create all new accounts" | cat >>gitlabyml.temp
echo "    signup_enabled: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Standard login settings" | cat >>gitlabyml.temp
echo "    # The standard login can be disabled to force login via LDAP" | cat >>gitlabyml.temp
echo "    # default: true - If set to false the standard login form won't be shown on the sign-in page" | cat >>gitlabyml.temp
echo "    signin_enabled: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # Restrict setting visibility levels for non-admin users." | cat >>gitlabyml.temp
echo "    # The default is to allow all levels." | cat >>gitlabyml.temp
echo "    restricted_visibility_levels: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Automatic issue closing" | cat >>gitlabyml.temp
echo "    # If a commit message matches this regular expression, all issues referenced from the matched text will be closed." | cat >>gitlabyml.temp
echo "    # This happens when the commit is pushed or merged into the default branch of a project." | cat >>gitlabyml.temp
echo "    # When not specified the default issue_closing_pattern as specified below will be used." | cat >>gitlabyml.temp
echo "    # Tip: you can test your closing pattern at http://rubular.com" | cat >>gitlabyml.temp
echo "    issue_closing_pattern: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Default project features settings" | cat >>gitlabyml.temp
echo "    default_projects_features:" | cat >>gitlabyml.temp
echo "      issues: " | cat >>gitlabyml.temp
echo "      merge_requests: " | cat >>gitlabyml.temp
echo "      wiki: " | cat >>gitlabyml.temp
echo "      snippets: " | cat >>gitlabyml.temp
echo "      visibility_level:   # can be \"private\" | \"internal\" | \"public\"" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Webhook settings" | cat >>gitlabyml.temp
echo "    # Number of seconds to wait for HTTP response after sending webhook HTTP POST request (default: 10)" | cat >>gitlabyml.temp
echo "    webhook_timeout: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Repository downloads directory" | cat >>gitlabyml.temp
echo "    # When a user clicks e.g. 'Download zip' on a project, a temporary zip file is created in the following directory." | cat >>gitlabyml.temp
echo "    # The default is 'tmp/repositories' relative to the root of the Rails app." | cat >>gitlabyml.temp
echo "    repository_downloads_path: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## External issues trackers" | cat >>gitlabyml.temp
echo "  issues_tracker:" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## Gravatar" | cat >>gitlabyml.temp
echo "  ## For Libravatar see: http://doc.gitlab.com/ce/customization/libravatar.html" | cat >>gitlabyml.temp
echo "  gravatar:" | cat >>gitlabyml.temp
echo "    enabled: true            # Use user avatar image from Gravatar.com (default: true)" | cat >>gitlabyml.temp
echo "    # gravatar urls: possible placeholders: %{hash} %{size} %{email}" | cat >>gitlabyml.temp
echo "    plain_url:      # default: http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon" | cat >>gitlabyml.temp
echo "    ssl_url:       # default: https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  #" | cat >>gitlabyml.temp
echo "  # 2. Auth settings" | cat >>gitlabyml.temp
echo "  # ==========================" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## LDAP settings" | cat >>gitlabyml.temp
echo "  # You can inspect a sample of the LDAP users with login access by running:" | cat >>gitlabyml.temp
echo "  #   bundle exec rake gitlab:ldap:check RAILS_ENV=production" | cat >>gitlabyml.temp
echo "  ldap:" | cat >>gitlabyml.temp
echo "    enabled: true" | cat >>gitlabyml.temp
echo "    host: '$fqdn'" | cat >>gitlabyml.temp
echo "    port: 389" | cat >>gitlabyml.temp
echo "    uid: 'uid'" | cat >>gitlabyml.temp
echo "    method: 'plain'  # \"tls\" or \"ssl\" or \"plain\"" | cat >>gitlabyml.temp
echo "    bind_dn: 'cn=admin,dc=$domain,dc=$suffix'" | cat >>gitlabyml.temp
echo "    password: $ldappasswd" | cat >>gitlabyml.temp
echo "    active_directory: false " | cat >>gitlabyml.temp
echo "    allow_username_or_email_login: true" | cat >>gitlabyml.temp
echo "    base: 'dc=$domain,dc=$suffix'" | cat >>gitlabyml.temp
echo "    user_filter: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## EE only" | cat >>gitlabyml.temp
echo "    group_base: " | cat >>gitlabyml.temp
echo "    admin_group: " | cat >>gitlabyml.temp
echo "    sync_ssh_keys: " | cat >>gitlabyml.temp
echo "    sync_time: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## OmniAuth settings" | cat >>gitlabyml.temp
echo "  omniauth:" | cat >>gitlabyml.temp
echo "    # Allow login via Twitter, Google, etc. using OmniAuth providers" | cat >>gitlabyml.temp
echo "    enabled: false" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # CAUTION!" | cat >>gitlabyml.temp
echo "    # This allows users to login without having a user account first (default: false)." | cat >>gitlabyml.temp
echo "    # User accounts will be created automatically when authentication was successful." | cat >>gitlabyml.temp
echo "    allow_single_sign_on: " | cat >>gitlabyml.temp
echo "    # Locks down those users until they have been cleared by the admin (default: true)." | cat >>gitlabyml.temp
echo "    block_auto_created_users: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    ## Auth providers" | cat >>gitlabyml.temp
echo "    # Uncomment the following lines and fill in the data of the auth provider you want to use" | cat >>gitlabyml.temp
echo "    # If your favorite auth provider is not listed you can use others:" | cat >>gitlabyml.temp
echo "    # see https://github.com/gitlabhq/gitlab-public-wiki/wiki/Custom-omniauth-provider-configurations" | cat >>gitlabyml.temp
echo "    # The 'app_id' and 'app_secret' parameters are always passed as the first two" | cat >>gitlabyml.temp
echo "    # arguments, followed by optional 'args' which can be either a hash or an array." | cat >>gitlabyml.temp
echo "    # Documentation for this is available at http://doc.gitlab.com/ce/integration/omniauth.html" | cat >>gitlabyml.temp
echo "    providers:" | cat >>gitlabyml.temp
echo "      # - { name: 'google_oauth2', app_id: 'YOUR APP ID'," | cat >>gitlabyml.temp
echo "      #     app_secret: 'YOUR APP SECRET'," | cat >>gitlabyml.temp
echo "      #     args: { access_type: 'offline', approval_prompt: '' } }" | cat >>gitlabyml.temp
echo "      # - { name: 'twitter', app_id: 'YOUR APP ID'," | cat >>gitlabyml.temp
echo "      #     app_secret: 'YOUR APP SECRET'}" | cat >>gitlabyml.temp
echo "      # - { name: 'github', app_id: 'YOUR APP ID'," | cat >>gitlabyml.temp
echo "      #     app_secret: 'YOUR APP SECRET'," | cat >>gitlabyml.temp
echo "      #     args: { scope: 'user:email' } }" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  #" | cat >>gitlabyml.temp
echo "  # 3. Advanced settings" | cat >>gitlabyml.temp
echo "  # ==========================" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  # GitLab Satellites" | cat >>gitlabyml.temp
echo "  satellites:" | cat >>gitlabyml.temp
echo "    # Relative paths are relative to Rails.root (default: tmp/repo_satellites/)" | cat >>gitlabyml.temp
echo "    path: /var/opt/gitlab/git-data/gitlab-satellites" | cat >>gitlabyml.temp
echo "    timeout: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## Backup settings" | cat >>gitlabyml.temp
echo "  backup:" | cat >>gitlabyml.temp
echo "    path: \"/var/opt/gitlab/backups\"   # Relative paths are relative to Rails.root (default: tmp/backups/)" | cat >>gitlabyml.temp
echo "    keep_time:    # default: 0 (forever) (in seconds)" | cat >>gitlabyml.temp
echo "    upload:" | cat >>gitlabyml.temp
echo "      # Fog storage connection settings, see http://fog.io/storage/ ." | cat >>gitlabyml.temp
echo "      connection: " | cat >>gitlabyml.temp
echo "      # The remote 'directory' to store your backups. For S3, this would be the bucket name." | cat >>gitlabyml.temp
echo "      remote_directory: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## GitLab Shell settings" | cat >>gitlabyml.temp
echo "  gitlab_shell:" | cat >>gitlabyml.temp
echo "    path: /opt/gitlab/embedded/service/gitlab-shell/" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # REPOS_PATH MUST NOT BE A SYMLINK!!!" | cat >>gitlabyml.temp
echo "    repos_path: /var/opt/gitlab/git-data/repositories" | cat >>gitlabyml.temp
echo "    hooks_path: /opt/gitlab/embedded/service/gitlab-shell/hooks/" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # Git over HTTP" | cat >>gitlabyml.temp
echo "    upload_pack: " | cat >>gitlabyml.temp
echo "    receive_pack: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # If you use non-standard ssh port you need to specify it" | cat >>gitlabyml.temp
echo "    ssh_port: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  ## Git settings" | cat >>gitlabyml.temp
echo "  # CAUTION!" | cat >>gitlabyml.temp
echo "  # Use the default values unless you really know what you are doing" | cat >>gitlabyml.temp
echo "  git:" | cat >>gitlabyml.temp
echo "    bin_path: /opt/gitlab/embedded/bin/git" | cat >>gitlabyml.temp
echo "    # The next value is the maximum memory size grit can use" | cat >>gitlabyml.temp
echo "    # Given in number of bytes per git object (e.g. a commit)" | cat >>gitlabyml.temp
echo "    # This value can be increased if you have very large commits" | cat >>gitlabyml.temp
echo "    max_size: " | cat >>gitlabyml.temp
echo "    # Git timeout to read a commit, in seconds" | cat >>gitlabyml.temp
echo "    timeout: " | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  #" | cat >>gitlabyml.temp
echo "  # 4. Extra customization" | cat >>gitlabyml.temp
echo "  # ==========================" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "  extra:" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "development:" | cat >>gitlabyml.temp
echo "  <<: *base" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "test:" | cat >>gitlabyml.temp
echo "  <<: *base" | cat >>gitlabyml.temp
echo "  gravatar:" | cat >>gitlabyml.temp
echo "    enabled: true" | cat >>gitlabyml.temp
echo "  gitlab:" | cat >>gitlabyml.temp
echo "    host: localhost" | cat >>gitlabyml.temp
echo "    port: 80" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "    # When you run tests we clone and setup gitlab-shell" | cat >>gitlabyml.temp
echo "    # In order to setup it correctly you need to specify" | cat >>gitlabyml.temp
echo "    # your system username you use to run GitLab" | cat >>gitlabyml.temp
echo "    # user: YOUR_USERNAME" | cat >>gitlabyml.temp
echo "  satellites:" | cat >>gitlabyml.temp
echo "    path: tmp/tests/gitlab-satellites/" | cat >>gitlabyml.temp
echo "  gitlab_shell:" | cat >>gitlabyml.temp
echo "    path: tmp/tests/gitlab-shell/" | cat >>gitlabyml.temp
echo "    repos_path: tmp/tests/repositories/" | cat >>gitlabyml.temp
echo "    hooks_path: tmp/tests/gitlab-shell/hooks/" | cat >>gitlabyml.temp
echo "  issues_tracker:" | cat >>gitlabyml.temp
echo "    redmine:" | cat >>gitlabyml.temp
echo "      title: \"Redmine\"" | cat >>gitlabyml.temp
echo "      project_url: \"http://redmine/projects/:issues_tracker_id\"" | cat >>gitlabyml.temp
echo "      issues_url: \"http://redmine/:project_id/:issues_tracker_id/:id\"" | cat >>gitlabyml.temp
echo "      new_issue_url: \"http://redmine/projects/:issues_tracker_id/issues/new\"" | cat >>gitlabyml.temp
echo "  ldap:" | cat >>gitlabyml.temp
echo "    enabled: false" | cat >>gitlabyml.temp
echo "    servers:" | cat >>gitlabyml.temp
echo "      main:" | cat >>gitlabyml.temp
echo "        label: ldap" | cat >>gitlabyml.temp
echo "        host: 127.0.0.1" | cat >>gitlabyml.temp
echo "        port: 3890" | cat >>gitlabyml.temp
echo "        uid: 'uid'" | cat >>gitlabyml.temp
echo "        method: 'plain' # \"tls\" or \"ssl\" or \"plain\"" | cat >>gitlabyml.temp
echo "        base: 'dc=example,dc=com'" | cat >>gitlabyml.temp
echo "        user_filter: ''" | cat >>gitlabyml.temp
echo "        group_base: 'ou=groups,dc=example,dc=com'" | cat >>gitlabyml.temp
echo "        admin_group: ''" | cat >>gitlabyml.temp
echo "        sync_ssh_keys: false" | cat >>gitlabyml.temp
echo "" | cat >>gitlabyml.temp
echo "staging:" | cat >>gitlabyml.temp
echo "  <<: *base" | cat >>gitlabyml.temp

# Setting Global Gitlab varibale
echo "$gitlabport"
echo "# Check and change the external_url to the address your users will type in their browser" | cat >gitlabrb.temp
sudo echo "external_url 'http://$fqdn:$gitlabport'" | cat >>gitlabrb.temp
sudo sh -c "cp -v gitlabrb.temp /etc/gitlab/gitlab.rb"
sudo sh -c "chmod 600 /etc/gitlab/gitlab.rb"
sudo sh -c "chown root:root /etc/gitlab/gitlab.rb"

echo "sleeping for a few seconds"
sleep 4

echo "Configuring Gitlab"
sudo gitlab-ctl reconfigure

sudo sh -c "cp -v /var/opt/gitlab/gitlab-rails/etc/gitlab.yml /var/opt/gitlab/gitlab-rails/etc/gitlab.yml-$date"
sudo sh -c "cp -v gitlabyml.temp /var/opt/gitlab/gitlab-rails/etc/gitlab.yml"
sudo sh -c "chown root:root /var/opt/gitlab/gitlab-rails/etc/gitlab.yml"

# Make note of default Gitlab port in logfile
echo "gitlabport = $gitlabport" | cat >>$log

# Whiptail info to give installed information regarding Gitlab
module='Gitlab Installed'
whiptail --title "$module" --backtitle "$product for $distro $version - $url"  --nocancel --msgbox "
Installation of Gitlab Server complete.

You can access Gitlab Server interface form any browser with access to this system on: \
http//$fqdn:$gitlabport or http://$internaladdress:$gitlabport
Gitlab Username:root
Gitlab Password:5iveL!fe

NOTE: To setup gitlab you will first need to login as the Gitlab Root user (see above) \
and change the Gitlab Root user password.

Select OK to continue..." 18 68

# Writing out InstallNotes.txt reference file.
notes=InstallNotes.txt
echo ""
echo "============================================================" | cat >>$notes
echo "Gitlab Server: Enabled" | cat >>$notes
echo "Gitlab Port No: $gitlabport" | cat >>$notes
echo "Gitlab Admin User: root" | cat >>$notes
echo "Gitlab Admin Password: 5iveL!fe" | cat >>$notes

# Removing .temp files
rm -rf *.temp