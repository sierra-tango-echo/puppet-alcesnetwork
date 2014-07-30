################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesnetwork::firewall (
  $firewall,
  $shorewall=true,
)
{
  #FIXME support roles rather than defined templates for different networks
  if $firewall {
  if $shorewall {

    $man_interface=inline_template("<%=scope.lookupvar('alcesnetwork::network::interfaces').select {|i| (scope.function_hiera([\"alcesnetwork::networkrole_#{i}\"]) rescue raise) == 'management'}.compact.first%>")
    $pub_interface=inline_template("<%=scope.lookupvar('alcesnetwork::network::interfaces').select {|i| (scope.function_hiera([\"alcesnetwork::networkrole_#{i}\"]) rescue '') == 'public'}.compact.first%>")
    $pri_interface=inline_template("<%=scope.lookupvar('alcesnetwork::network::interfaces').select {|i| (scope.function_hiera([\"alcesnetwork::networkrole_#{i}\"]) rescue '') == 'private'}.compact.first%>")
    $ib_interface=inline_template("<%=scope.lookupvar('alcesnetwork::network::interfaces').select {|i| (scope.function_hiera([\"alcesnetwork::networkrole_#{i}\"]) rescue '') == 'infiniband'}.compact.first%>")

    package {'shorewall':
      ensure=>installed,
    }
    service {'shorewall':
      #Don't do this as we're not sure the interfaces are yet setup correctly and risk lock out
      #ensure=>running,
      enable=>true
    }
    file {'/etc/shorewall/hosts':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=> multitemplate (
	  "alcesnetwork/dynamic/firewall/$alcesnetwork::profile/hosts.erb",
	  "alcesnetwork/dynamic/firewall/generic/hosts.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/interfaces':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=> multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/interfaces.erb",
	"alcesnetwork/dynamic/firewall/generic/interfaces.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/masq':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/masq.erb",
	"alcesnetwork/dynamic/firewall/generic/masq.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/policy':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/policy.erb",
	"alcesnetwork/dynamic/firewall/generic/policy.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/rules':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/rules.erb",
	"alcesnetwork/dynamic/firewall/generic/rules.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/shorewall.conf':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/shorewall.conf.erb",
	"alcesnetwork/dynamic/firewall/generic/shorewall.conf.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/zones':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/dynamic/firewall/$alcesnetwork::profile/zones.erb",
	"alcesnetwork/dynamic/firewall/generic/zones.erb"),
      require=>Package['shorewall'],
    }
  }
  }
}
