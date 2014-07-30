################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class alcesnetwork::network (
  $bonds,
  $interfaces,
  $bridges,

  #PRIVATE NETWORK
  $private_gateway,
  $private_netmask,
  $private_network,
  $private_domain,
  $private_dns,
  $private_dhcp,
  $force_private_ip,

  #MANAGEMENT NETWORK
  $management_netmask,
  $management_network,
  $management_gateway,
  $management_domain,
  $management_dns,
  $management_dhcp,
  $force_management_ip,

  #BMC NETWORK
  $bmc_netmask,
  $bmc_network,
  $bmc_gateway,
  $bmc_domain,
  $bmc_dns,
  $bmc_dhcp,
  $force_bmc_ip,

  #INFINIBAND_NETWORK
  $infiniband_netmask,
  $infiniband_network,
  $infiniband_gateway,
  $infiniband_domain,
  $infiniband_dns,
  $infiniband_dhcp,
  $force_infiniband_ip,

  #PUBLIC_NETWORK
  $public_netmask,
  $public_network,
  $public_domain,
  $public_gateway,
  $public_dns,
  $public_dhcp,
  $force_public_ip,

  #SECURE NETWORK
  $secure_network,
  $secure_netmask,
  $secure_gateway,
  $secure_domain,
  $secure_dns,
  $secure_dhcp,
  $force_secure_ip,

  #CLIENT NETWORK
  $client_network,
  $client_netmask,
  $client_gateway,
  $client_domain,
  $client_dns,
  $client_dhcp,
  $force_client_ip,

  $defaultgateway_role,
  $primary_role,

  $extra_networks,

  $dnsnetworks,
  $dnssearchdomains,
  $forwarddns,

  $externaldnsname,

  $destructive=$alcesnetwork::destructive,
)
{
  #Lookup ip's
  if $force_private_ip == '' { $private_ip=lookupip("${alces_hostname}.${private_domain}") } else { $private_ip=$force_private_ip }
  if $force_management_ip == '' { $management_ip=lookupip("${alces_hostname}.${management_domain}") } else { $management_ip=$force_management_ip }
  if $force_bmc_ip == '' { $bmc_ip=lookupip("${alces_hostname}.${bmc_domain}") } else { $bmc_ip=$force_bmc_ip }
  if $force_infiniband_ip == '' { $infiniband_ip=lookupip("${alces_hostname}.${infiniband_domain}") } else { $infiniband_ip=$force_infiniband_ip }
  if $force_public_ip == '' { $public_ip=lookupip("${alces_hostname}.${public_domain}") } else { $public_ip=$force_public_ip }
  if $force_secure_ip == '' { $secure_ip=lookupip("${alces_hostname}.${secure_domain}") } else { $secure_ip=$force_secure_ip }
  if $force_client_ip == '' { $client_ip=lookupip("${alces_hostname}.${client_domain}") } else { $client_ip=$force_client_ip }

  #Set primary domain vars
  $primary_netmask = inline_template("<%=scope.lookupvar(\"#{@primary_role}_netmask\")%>")
  $primary_network = inline_template("<%=scope.lookupvar(\"#{@primary_role}_network\")%>")
  $primary_gateway = inline_template("<%=scope.lookupvar(\"#{@primary_role}_gateway\")%>")
  $primary_dhcp = str2bool(inline_template("<%=scope.lookupvar(\"#{@primary_role}_dhcp\")%>"))
  $primary_domain = inline_template("<%=scope.lookupvar(\"#{@primary_role}_domain\")%>")
  $primary_dns = inline_template("<%=scope.lookupvar(\"#{@primary_role}_dns\")%>")
  $primary_interface = inline_template("<%=scope.lookupvar('alcesnetwork::network::interfaces').select {|i| (scope.function_hiera([\"alcesnetwork::networkrole_#{i}\"]) rescue '') == scope.lookupvar('primary_role')}.compact.first%>")

  #NETWORK INTERFACES
  if $destructive {
    alcesnetwork::network_interface { $interfaces:
      require=>Service['NetworkManager']
    }
    file {'/etc/modprobe.d/alces-bonding.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template('alcesnetwork/network_interface/el6/alces-bonding.conf'),
    }
    service {'NetworkManager':,
      enable=>false,
      ensure=>stopped
    }
    if ! $primary_dhcp {
      augeas {'sysconfignetwork-hostname':
        context => "/files/etc/sysconfig/network",
        changes => "set HOSTNAME $::alces_hostname.$primary_domain",
      }
    }
    augeas {'sysconfignetwork-networking':
      context => "/files/etc/sysconfig/network",
      changes => "set NETWORKING yes",
    }
    augeas {'sysconfignetwork-networking-ipv6':
      context => "/files/etc/sysconfig/network",
      changes => "set NETWORKING_IPV6 no",
    }

    file {'/etc/sysconfig/static-routes':
      ensure=>present,
      mode=>0644,
      owner=>root,
      group=>root,
      content=>'',
      replace=>no,
     }

     #resolv.conf
     file {'/etc/resolv.conf':
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      content=>template("alcesnetwork/resolv.conf.erb"),
     }
  }
}
