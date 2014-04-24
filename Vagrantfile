# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "debian73"

	config.vm.hostname = "francalab-debian73"

	# If above box does not exist locally, fetch it here:
	config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-puppet.box"

   # To run eclipse we need more than default RAM 512MB And we might as well
   # set a useful name also, which I prefer to have equal to the hostname that
   # was defined above, but to make it unique a timestamp is added also.
   vmname = config.vm.hostname + "-" + `date +%Y%m%d%H%M`
   config.vm.provider :virtualbox do |vb|
        vb.customize [ "modifyvm", :id, "--name", vmname ]
        vb.customize [ "modifyvm", :id, "--memory", "1536" ]
   end

   # Warning to user
	config.vm.provision :shell, inline:
		'echo "***************************************************************"
       echo "Starting provisioning. "
       echo
       echo "When provisioning is done, halt the VM, then boot normally "
       echo "with a GUI inside Virtualbox, i.e. not using vagrant..."
       echo
       echo "Then run eclipse, probably at: ~vagrant/tools/autoeclipse/eclipse"
       echo "See README for more details"
       echo "***************************************************************"'

   # Install prerequisites
	config.vm.provision :shell, inline:
      'sudo apt-get update; sudo apt-get install -y wget unzip openjdk-6-jre'

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
Exec=/home/vagrant/tools/autoeclipse/eclipse/eclipse
EOT

chmod 755 $shortcut

# The above created files, and others are owned by root after provisioning 
# Fix that:
sudo chown -R vagrant:vagrant /home/vagrant
'

   # Warning, again
	config.vm.provision :shell, inline:
		'echo "***************************************************************"
       echo "Executing final step: install LXDE graphical environment"
       echo
       echo "When provisioning is done, halt the VM, then boot normally "
       echo "with a GUI inside Virtualbox, i.e. not using vagrant..."
       echo ""
       echo "Then run eclipse, probably at: ~vagrant/tools/autoeclipse/eclipse"
       echo "See README for more details"
       echo "***************************************************************"'

   # Install graphical environment
	config.vm.provision :shell, inline:
      'sudo apt-get install -y lxde'

# ----------------------------------------------
# If VM will run some network services e.g. web browser
# make a port forward so we can test them from the host:
# host:4567 -->  Virtual Machine port 80
# ----------------------------------------------

#	   config.vm.network :forwarded_port, host: 4567, guest: 80

end
