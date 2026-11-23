# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Evita problemas com atualizações automáticas do apt durante o provisionamento
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    systemctl stop apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true
    systemctl disable apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true
  SHELL

  # Instala o Docker em todas as máquinas virtuais
  config.vm.provision "shell", path: "scripts/Docker-install.sh"

  nodes = {
    "master" => "192.168.56.10",
    "node01" => "192.168.56.11",
    "node02" => "192.168.56.12",
    "node03" => "192.168.56.13"
  }

  nodes.each do |name, ip|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: ip

      node.vm.provider "virtualbox" do |vb|
        vb.name = name
        vb.memory = (name == "master") ? "1536" : "1024"
        vb.cpus = (name == "master") ? "2" : "1"
      end

      if name == "master"
        node.vm.provision "shell",
          path: "scripts/master-swarm.sh",
          args: [ip]
      else
        node.vm.provision "shell",
          path: "scripts/worker-swarm.sh",
          args: ["192.168.56.10", ip]
      end
    end
  end
end
