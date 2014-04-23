# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "precise64"

	config.vm.hostname = "francalab-precise64"

	# If above box does not exist locally, fetch it here:
	config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

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
