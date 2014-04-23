# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "precise64"

	config.vm.hostname = "francalab-precise64"

	# If above box does not exist locally, fetch it here:
	config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box" 

   # Install prerequisites
	config.vm.provision :shell, inline: 
      'sudo apt-get update; sudo apt-get install -y wget unzip openjdk-6-jre'

	# Tell Vagrant to run this script inside the VM
	config.vm.provision :shell, :path => "script.sh"

   # Graphical environment
	config.vm.provision :shell, inline:
		'echo "***************************************************************"
       echo "Unfortunately the graphical environment install needs to be manual:" 
       echo "run \"vagrant ssh\"" 
       echo "then inside VM :"
       echo "$ sudo apt-get install lxde"
       echo ""
       echo "Then halt the VM \"sudo halt\""
       echo "or exit VM"
       echo "and run \"vagrant halt\"
       echo ""
       echo "Then start the VM normally using VirtualBox (not headless)"
       echo "And run eclipse (probably at: ~vagrant/tools/autoeclipse/eclipse)"
       echo "***************************************************************"'

# ----------------------------------------------
# If VM will run some network services e.g. web browser
# make a port forward so we can test them from the host:
# host:4567 -->  Virtual Machine port 80
# ----------------------------------------------

#	   config.vm.network :forwarded_port, host: 4567, guest: 80

end
