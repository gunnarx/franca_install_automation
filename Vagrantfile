# -*- mode: ruby -*-
# vim: set ft=ruby sw=3 ts=3 et:

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   config.vm.box = "precise64"

   config.vm.hostname = "francalab-precise64"

   # If above box does not exist locally, fetch it here:
   config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

   # To run eclipse we need more than default RAM 512MB And we might as well
   # set a useful name also, which I prefer to have equal to the hostname that
   # was defined above, but to make it unique a timestamp is added also.
   # Increase video RAM as well, it doesn't cost much and we will run
   # graphical desktops after all.
   vmname = config.vm.hostname + "-" + `date +%Y%m%d%H%M`.to_s
   vmname.chomp!      # Without this there is a newline character in the name :-o
   config.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      vb.gui = true

      vb.customize [ "modifyvm", :id, "--name", vmname ]
      vb.customize [ "modifyvm", :id, "--memory", "1536" ]
      vb.customize [ "modifyvm", :id, "--vram", "128" ]
   end

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
   'sudo apt-get install -y lxde

    echo "***************************************************************"
    echo "Reminder:"
    echo "You will see errors in dpkg-preconfigure and similar ones."
    echo "They seem to be because Vagrant is not running in an interactive"
    echo "terminal.  So you can ignore them and try the VM."
    echo "***************************************************************"
    echo
    echo "Provisioning is done, now halt the VM by typing:"
    echo
    echo "$ vagrant halt"
    echo
    echo "Then reboot with a GUI from Virtualbox, i.e. not using vagrant..."
    echo "Log in as vagrant, password: vagrant"
    echo "Eclipse is in ~vagrant/tools/autoeclipse/eclipse and should be "
    echo "available as an icon on the desktop also."
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
