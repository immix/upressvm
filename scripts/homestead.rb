class Homestead
  def Homestead.configure(config, settings)
    # Configure The Box
    config.vm.box = "laravel/homestead"
    config.vm.hostname = "homestead"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      # vb.name = 'homestead'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Configure Port Forwarding To The Box
    #config.vm.network "forwarded_port", guest: 80, host: 8000
    #config.vm.network "forwarded_port", guest: 443, host: 44300
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    #config.vm.network "forwarded_port", guest: 5432, host: 54320

    # Configure The Public Key For SSH Access
    config.vm.provision "shell" do |s|
      s.inline = "echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
      s.args = [File.read(File.expand_path(settings["authorize"]))]
    end

    # Copy The SSH Private Keys To The Box
    settings["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
        s.args = [File.read(File.expand_path(key)), key.split('/').last]
      end
    end

    # Copy The Bash Aliases
    config.vm.provision "shell" do |s|
      s.inline = "cp /vagrant/aliases /home/vagrant/.bash_aliases"
    end

    # Register All Of The Configured Shared Folders
    settings["folders"].each do |folder|
      config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
    end

    # Install All The Configured Nginx Sites
    settings["sites"].each do |site|
      config.vm.provision "shell" do |s|
          if (site.has_key?("hhvm") && site["hhvm"])
            s.inline = "bash /vagrant/scripts/serve-hhvm.sh $1 $2"
            s.args = [site["map"], site["to"]]
          else
            s.inline = "bash /vagrant/scripts/serve.sh $1 $2"
            s.args = [site["map"], site["to"]]
          end
      end
      config.vm.provision "shell" do |s|
          if (site.has_key?("hhvm") && site["hhvm"])
            s.inline = "bash /vagrant/scripts/serve-hhvm-https.sh $1 $2"
            s.args = [site["map"], site["to"]]
          else
            s.inline = "bash /vagrant/scripts/serve-https.sh $1 $2"
            s.args = [site["map"], site["to"]]
          end
      end
    end

    def Homestead.install_cron_tabs(config, settings)
      # empty /home/vagrant/.crontabs file
      config.vm.provision "shell" do |s|
        s.inline = "cat /dev/null > /home/vagrant/.crontabs"
      end

      # fill /home/vagrant/.crontabs file with crontab rows
      settings["crontabs"].each do |crontab|
        config.vm.provision "shell" do |s|
          s.inline = "echo #{Homestead.crontab_value_of(crontab["minute"])} #{Homestead.crontab_value_of(crontab["hour"])} #{Homestead.crontab_value_of(crontab["monthday"])} #{Homestead.crontab_value_of(crontab["month"])} #{Homestead.crontab_value_of(crontab["weekday"])} #{crontab["command"] } >> /home/vagrant/.crontabs"
        end
      end

      # install all crontabs from /home/vagrant/.crontabs file for 'root'
      config.vm.provision "shell" do |s|
        s.inline = "crontab -u root /home/vagrant/.crontabs"
      end
    end

    def Homestead.crontab_value_of(input)
      input != nil && input != '*' ? input : "\\*"
    end

    # install crontabs
    Homestead.install_cron_tabs(config, settings)

    # Updating the hosts file with all the sites that are defined in Homestead.yaml
    if Vagrant.has_plugin?("vagrant-hostsupdater")
      hosts = []
      settings["sites"].each do |site|
        hosts.push(site["map"])
      end
      config.hostsupdater.aliases = hosts
    end

    # Configure All Of The Configured Databases
    settings["databases"].each do |db|
        config.vm.provision "shell" do |s|
            s.inline = "bash /vagrant/scripts/create-mysql.sh $1"
            s.args = [db]
        end
    end

    # Configure All Of The Server Environment Variables
    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
            s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php5/fpm/php-fpm.conf"
            s.args = [var["key"], var["value"]]
        end
      end
      config.vm.provision "shell" do |s|
          s.inline = "service php5-fpm restart"
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end

    # Run the immix provision script
    config.vm.provision "shell" do |s|
      s.inline = "bash /vagrant/scripts/after.sh"
    end

  end
end
