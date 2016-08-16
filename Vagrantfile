# -*- mode: ruby -*-
# vim: set ft=ruby sw=4 ts=4 tw=0 et:

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Apparently this needs to be specified if Vagrant has alternative options
# (trying this with other Vagrant providers is currently untested and users
#  must try that on their own._)
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

   # This allows to set a web proxy from outside the vagrant environment by
   # passing it in the shell environment variable.

   if Vagrant.has_plugin?("vagrant-proxyconf")
      if ENV['http_proxy']
         puts 'NOTE: Found WEB PROXY defined in shell environment.  Will reuse the following settings inside Vagrant:'

         config.proxy.ftp   = ENV['ftp_proxy']   || "not defined"
         config.proxy.http  = ENV['http_proxy']  || "not defined"
         config.proxy.https = ENV['https_proxy'] || "not defined"
         config.proxy.no_proxy = "localhost,127.0.0.1"

         # Print settings, but try to protect password if by chance 
         # user:pass was defined as part of Proxy URL (no guarantees!)
         puts "$http_proxy = #{config.proxy.http.sub(/(\w+:\/\/)(\w+):(\S+)@/,'\1\2:**************@')}"
         puts "$https_proxy = #{config.proxy.https.sub(/(\w+:\/\/)(\w+):(\S+)@/,'\1\2:**************@')}"
         puts "$ftp_proxy = #{config.proxy.http.sub(/(\w+:\/\/)(\w+):(\S+)@/,'\1\2:**************@')}"
         puts "Bypass proxy for #{config.proxy.no_proxy}"
      end
   else
      puts "Vagrant has no proxy plugin => skipped proxy configuration."
   end

   config.vm.box = "trusty64"

   config.vm.hostname = "francalab-trusty64"

   # If above box does not exist locally, fetch it here:
   config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

   # To run eclipse we need more than default RAM 512MB And we might as well
   # set a useful name also, which I prefer to have equal to the hostname that
   # was defined above, but to make it unique a timestamp is added also.
   # Increase video RAM as well, it doesn't cost much and we will run
   # graphical desktops after all.
   vmname = config.vm.hostname + "-" + Time.now.strftime("%Y%m%d%H%M")
   config.vm.provider :virtualbox do |vb|
      # Leave it commented to boot in headless mode (useful for automated tests)
      # vb.gui = true

      vb.customize [ "modifyvm", :id, "--name", vmname ]
      vb.customize [ "modifyvm", :id, "--memory", "2560" ]
      vb.customize [ "modifyvm", :id, "--vram", "128" ]
   end

   # Make sure proxy settings affect also sudo commands
   # (by default the environment is cleared for sudo)
   config.vm.provision :shell, inline:
      'sudo echo "Defaults	env_keep = \"http_proxy https_proxy ftp_proxy\"" >>/etc/sudoers' 

   # Warning to user
   config.vm.provision :shell, inline:
      'echo "***************************************************************"
       echo "Starting provisioning. "
       echo
       echo "!!!!!!!!!!!!"
       echo "!!!      !!! You may see errors in dpkg-preconfigure."
       echo "!!! NOTE !!! Please let everything run to the end. "
       echo "!!!      !!! "
       echo "!!!!!!!!!!!!"
       echo
       echo "***************************************************************"'

   # Install prerequisites
   config.vm.provision :shell, inline:
      'sudo apt-get update; sudo apt-get install -y wget unzip openjdk-7-jre'

   # Run the eclipse + franca installer script
   config.vm.provision :shell, :path => "script.sh"

   # Create desktop icon
   config.vm.provision :shell, inline:
      'desktopdir=/home/vagrant/Desktop
   sudo mkdir -p $desktopdir
   shortcut=/home/vagrant/Desktop/Eclipse.desktop
   cat <<EOT >$shortcut
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Eclipse with Franca
Name[en_US]=Eclipse with Franca
Icon=/home/vagrant/tools/autoeclipse/eclipse/icon.xpm
Exec=/home/vagrant/tools/autoeclipse/eclipse/eclipse -data /home/vagrant/workspace
EOT

chmod 755 $shortcut

# The above created files, and others are owned by root after provisioning 
# Fix that:
sudo chown -R vagrant:vagrant /home/vagrant

# Remove other users than vagrant -- makes things less confusing
sudo deluser ubuntu   # Might fail but that is ok
true                  # Make sure Vagrant does not stop on error
'

   config.vm.provision :shell, inline:
   'echo "***************************************************************"
    echo "Executing final step: install graphical environment"
    echo "***************************************************************"
   '

   # Install graphical environment
   config.vm.provision :shell, inline:
   'sudo apt-get install -y ubuntu-desktop

    echo "***************************************************************"
    echo "Reminder:"
    echo "You will see errors in dpkg-preconfigure and similar ones."
    echo "They seem to be because Vagrant is not running in an interactive"
    echo "terminal.  So you can ignore them and try the VM."
    echo "***************************************************************"
    echo
    echo "Provisioning is done, now reboot the VM by typing:"
    echo
    echo "$ vagrant reload"
    echo "Login is: user:vagrant password:vagrant"
    echo
    echo "Eclipse is in ~vagrant/tools/autoeclipse/eclipse and should"
    echo "also be available as an icon on the desktop."
    echo
    echo "Read the project README!"
    echo "***************************************************************"
   '

   # ----------------------------------------------
   # If VM will run some network services e.g. web browser
   # make a port forward so we can test them from the host:
   # host:4567 -->  Virtual Machine port 80
   # ----------------------------------------------

   # config.vm.network :forwarded_port, host: 4567, guest: 80

end
