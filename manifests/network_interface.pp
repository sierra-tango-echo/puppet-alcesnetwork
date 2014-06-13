################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
define alcesnetwork::network_interface (
  $interfacename=$title,
  $networkscript_filename_header="/etc/sysconfig/network-scripts/ifcfg-", 
)
{
  $role=inline_template("<%= scope.function_hiera([\"alcesnetwork::networkrole_#{@interfacename}\"]) || 'none' rescue raise%>")
  $bondslave=str2bool(inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::bonds\") || []).include? @role%>"))
  $bond=str2bool(inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::bonds\") || []).include? @interfacename%>"))
  $bridgeslave=str2bool(inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::bridges\") || []).include? @role%>"))
  $bridge=str2bool(inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::bridges\") || []).include? @interfacename%>"))
  $dhcp=str2bool(inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::#{@role}_dhcp\") rescue raise)%>"))
  $force_ip=inline_template("<%=(scope.lookupvar(\"alcesnetwork::network::#{@role}_ip\"))%>")
  if $force_ip == ''
    {
    #$ip=lookupip(inline_template("<%=scope.lookupvar(\"alces_hostname\")%>.<%=scope.lookupvar(\"alcesnetwork::network::#{@role}_domain\")%>"))
    } else {
    $ip=$force_ip
    }
  file {"configfile-${title}":
        name=>"${networkscript_filename_header}${interfacename}",
        ensure=> present,
        mode=>0644,
        content=>template('alcesnetwork/network_interface/el6.erb'),
  }
}
