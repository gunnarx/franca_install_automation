# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "precise64"

	config.vm.hostname = "francalab-precise64"

	# If above box does not exist locally, fetch it here:
	config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

   # To run eclipse we need more than default RAM 512MB
   # And we might as well set a useful name also, which I
   # prefer to have equal to the hostname defined above.
   #
   # If memory is not enough you can modify it here.
   config.vm.customize [
      "modifyvm", :id,
      "--name", "#{config.vm.hostname}",
      "--memory", "1536"
   ]

   # Warning to user
	config.vm.provision :shell, inline:
		'echo "***************************************************************"
       echo "Starting provisioning. "
       echo
       echo "!!!!!!!!!!!!"
       echo "!!!      !!! You may see errors in dpkg-preconfigure."
       echo "!!! NOTE !!! It will look like a significant error in the final step"
       echo "!!!      !!! (cannot reopen stdin, etc). This can be ignored."
       echo "!!!!!!!!!!!!"
       echo
       echo "When provisioning is done, halt the VM, then boot normally "
       echo "with a GUI inside Virtualbox, i.e. not using vagrant..."
       echo
       echo "Then run eclipse, probably at: ~vagrant/tools/autoeclipse/eclipse"
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
   shortcut=/home/vagrant/Desktop/Eclipse
   cat <<EOT >$shortcut
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Eclipse with Franca
Name[en_US]=Eclipse with Franca
Icon=/home/vagrant/tools/autoeclipse/eclipse/icon.xpm
Exec=/home/vagrant/tools/autoeclipse/eclipse/eclipse
EOT

# The above created files, and others are owned by root after provisioning 
# Fix that:
sudo chown -R vagrant:vagrant /home/vagrant
'

   # Warning, again
	config.vm.provision :shell, inline:
		'echo "***************************************************************"
       echo "Executing final step: install LXDE graphical environment"
       echo
       echo "!!!!!!!!!!!! Reminder:"
       echo "!!! NOTE !!! Installing LXDE fails in dpkg-preconfigure."
       echo "!!!!!!!!!!!! This can be ignored, it seems OK anyway - try it."
       echo
       echo "When provisioning is done, halt the VM, then boot normally "
       echo "with a GUI inside Virtualbox, i.e. not using vagrant..."
       echo ""
       echo "Then run eclipse, probably at: ~vagrant/tools/autoeclipse/eclipse"
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
