################################################################################
###
### Alces HPC Software Stack - Puppet configuration files
### Copyright (c) 2008-2013 Alces Software Ltd
###
#################################################################################
require 'yaml'
ALCES_CONFIG='/etc/alces_stack.yaml' unless defined? ALCES_CONFIG

Facter.add("alces_kernelrelease") do
  setcode do
    Facter.value('kernelrelease').to_s.gsub(".#{Facter.value('architecture')}",'').to_s
  end
end

def load_config(value)
  (YAML::load_file(ALCES_CONFIG)[value] rescue nil) || raise("Cannot load profile, please create a valid profile file at '#{ALCES_CONFIG}'")
end

def hostname
  load_config(:hostname) rescue Facter.value("hostname")
end

def machine
  (load_config(:machine) rescue nil) || "#{profile}machine"
end

def role
  begin
    load_config(:role)
  rescue
    case profile
    when 'headnode'
      'master'
    else
      'slave'
    end
  end
end

Facter.add("alces_os") do
  setcode do
    Facter.value("operatingsystem").to_s.upcase + Facter.value("operatingsystemrelease")
  end
end

Facter.add("alces_hostname") do
  setcode do
    hostname
  end
end

Facter.add("alces_machine") do
  setcode do
    machine
  end
end
Facter.add("alces_role") do
  setcode do
    role
  end
end
