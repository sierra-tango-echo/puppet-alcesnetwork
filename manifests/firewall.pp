################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesnetwork::firewall (
  $shorewall=true,
)
{
  #FIXME support roles rather than defined templates for different networks

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
	  "alcesnetwork/firewall/$alcesnetwork::profile/hosts.erb",
	  "alcesnetwork/firewall/generic/hosts.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/interfaces':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=> multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/interfaces.erb",
	"alcesnetwork/firewall/generic/interfaces.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/masq':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/masq.erb",
	"alcesnetwork/firewall/generic/masq.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/policy':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/policy.erb",
	"alcesnetwork/firewall/generic/policy.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/rules':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/rules.erb",
	"alcesnetwork/firewall/generic/rules.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/shorewall.conf':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/shorewall.conf.erb",
	"alcesnetwork/firewall/generic/shorewall.conf.erb"),
      require=>Package['shorewall'],
    }
    file {'/etc/shorewall/zones':
      ensure=>present,
      mode=>0600,
      owner=>'root',
      group=>'root',
      content=>multitemplate(
	"alcesnetwork/firewall/$alcesnetwork::profile/zones.erb",
	"alcesnetwork/firewall/generic/zones.erb"),
      require=>Package['shorewall'],
    }
  }
}
