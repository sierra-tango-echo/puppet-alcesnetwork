################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class alcesnetwork (
  #Generic Alces variables
  #Supported profiles:
  # - generic
  # - hpc_headnode
  # - hpc_login
  $profile = hiera('alcesbase::profile','generic'),
  #Supported roles:
  # - slave
  # - master
  $role = hiera('alcesbase::role','slave'),
  #Be more destructive
  $destructive
)
{
  class { 'alcesnetwork::network':
    bonds => hiera('alcesnetwork::bonds',[]),
    interfaces => hiera('alcesnetwork::networkinterfaces', []),
    bridges => hiera('alcesnetwork::bridges',[]),

    #FIXME - Take network roles from array to allow any number of roles 
 
    #PRIVATE NETWORK
    private_gateway=>hiera("alcesnetwork::private_gateway","192.168.10.10"),
    private_netmask=>hiera("alcesnetwork::private_netmask","255.255.255.0"),
    private_network=>hiera("alcesnetwork::private_network","192.168.10.0"),
    private_domain=>hiera("alcesnetwork::private_domain"),
    private_dns=>hiera("alcesnetwork::private_dns",[]),
    private_dhcp=>hiera("alcesnetwork::private_dhcp",false),
    force_private_ip=>hiera("alcesnetwork::private_ip",undef), #Leave '' to perform DNS lookup for FQDN

    #MANAGEMENT NETWORK
    management_netmask=>hiera("alcesnetwork::management_netmask","255.255.255.0"),
    management_network=>hiera("alcesnetwork::management_network","192.168.11.0"),
    management_gateway=>hiera("alcesnetwork::management_gateway","192.168.11.1"),
    management_domain=>hiera("alcesnetwork::management_domain"),
    management_dns=>hiera("alcesnetwork::management_dns",[]),
    management_dhcp=>hiera("alcesnetwork::management_dhcp",false),
    force_management_ip=>hiera("alcesnetwork::management_ip",''), #Leave '' to perform DNS lookup for FQDN

    #BMC NETWORK
    bmc_netmask=>hiera("alcesnetwork::bmc_netmask",hiera("alcesnetwork::management_netmask","255.255.255.0")),
    bmc_network=>hiera("alcesnetwork::bmc_network",hiera("alcesnetwork::management_network","192.168.11.0")),
    bmc_gateway=>hiera("alcesnetwork::bmc_gateway",hiera("alcesnetwork::management_gateway","192.168.11.1")),
    bmc_domain=>hiera("alcesnetwork::bmc_domain"),
    bmc_dns=>hiera("alcesnetwork::bmc_dns",[]),
    bmc_dhcp=>hiera("alcesnetwork::bmc_dhcp",false),
    force_bmc_ip=>hiera("alcesnetwork::bmc_ip",''), #Leave '' to perform DNS lookup for FQDN

    #INFINIBAND_NETWORK
    infiniband_netmask=>hiera("alcesnetwork::infiniband_netmask","255.255.0.0"),
    infiniband_network=>hiera("alcesnetwork::infiniband_network","10.12.0.0"),
    infiniband_gateway=>hiera("alcesnetwork::infiniband_gateway","10.12.0.11"),
    infiniband_domain=>hiera("alcesnetwork::infiniband_domain"),
    infiniband_dns=>hiera("alcesnetwork::infiniband_dns",[]),
    infiniband_dhcp=>hiera("alcesnetwork::infiniband_dhcp",false),
    force_infiniband_ip=>hiera("alcesnetwork::infiniband_ip",''), #Leave '' to perform DNS lookup for host
    
    #PUBLIC_NETWORK
    public_netmask=>hiera("alcesnetwork::public_netmask"), #set to '' to confirm dhcp
    public_network=>hiera("alcesnetwork::public_network"), #set to '' to confirm dhcp
    public_domain=>hiera("alcesnetwork::public_domain"),   #set to '' to confirm dhcp
    public_gateway=>hiera("alcesnetwork::public_gateway"), #set to '' to confirm dhcp
    public_dns=>hiera("alcesnetwork::public_dns",[]),
    public_dhcp=>hiera("alcesnetwork::public_dhcp",true),
    force_public_ip=>hiera("alcesnetwork::public_ip",''), #Leave '' to perform DNS lookup for host

    #SECURE NETWORK
    secure_network=>hiera(alcesnetwork::secure_network,"10.13.0.0"),
    secure_netmask=>hiera(alcesnetwork::secure_netmask,"255.255.0.0"),
    secure_gateway=>hiera(alcesnetwork::secure_gateway,"10.13.0.1"),
    secure_domain=>hiera(alcesnetwork::secure_domain),
    secure_dns=>hiera("alcesnetwork::secure_dns",[]),
    secure_dhcp=>hiera("alcesnetwork::secure_dhcp",false),
    force_secure_ip=>hiera("alcesnetwork::secure_ip",''), #Leave '' to perform DNS lookup for host

    #CLIENT NETWORK
    client_network=>hiera(alcesnetwork::client_network,"10.14.0.0"),
    client_netmask=>hiera(alcesnetwork::client_netmask,"255.255.0.0"),
    client_gateway=>hiera(alcesnetwork::client_gateway,"10.14.0.0"),
    client_domain=>hiera(alcesnetwork::client_domain,"vpn.${domain}"),
    client_dns=>hiera("alcesnetwork::client_dns",[]),
    client_dhcp=>hiera("alcesnetwork::client_dhcp",[]),
    force_client_ip=>hiera("alcesnetwork::client_ip",''), #Leave '' to perform DNS lookup for host

    #Direct hiera references!
    #FIXME - don't like these
    #FIXME - remove all hiera calls to these from child manifests / templates
    #Also required are the following for each interface in interfaces
    #alcesnetwork::networkrole_<interface>=networkname
    #alcesnetwork::<role>_ip=ip (if not using dns lookup)
    #For bonds you need to specify these in heira
    #alcesnetwork::<bondname>_type=1
    #alcesnetwork::<bondname>_options='miimon=80 primary=p4p1'
     
    defaultgateway_role => 'private',
    primary_role => hiera("alcesnetwork::primary_role",'private'),

    extra_networks => hiera("alcesnetwork::extra_networks",[]),

    dnsnetworks => hiera("alcesnetwork::dnsnetworks",[]),
    dnssearchdomains => hiera("alcesnetwork::dnssearchdomains",[$alcesnetwork::network::private_domain,$alces_network::management_domain,$alces_network::secure_domain,$alces_network::infiniband_domain]),
    forwarddns => hiera("alcesnetwork::forwarddns",[]),

    externaldnsname => hiera("alcesnetwork::externaldnsname",undef)
  }

  #Configure firewall
  class { 'alcesnetwork::firewall':

  }
}
