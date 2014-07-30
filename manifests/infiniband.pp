################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class alcesnetwork::infiniband (
  $rdma=false,
  $lustre,
  $melanox,
  $qlogic,
)
{

  if $rdma {
  
    $ofedpackages='@ofed infinipath-psm-devel infinipath-psm kernel-devel'
    exec {'installofed':
      command=>"/usr/bin/yum --nogpgcheck -y -e0 install ${ofedpackages}",
      logoutput=>on_failure,
      timeout=>300,
    }

    service {'rdma':
      ensure=>running,
      enable=>true,
      require=>Exec['installofed'],
    }
    #patch rh ofed script for lustre & IB
    if $::osfamily == 'RedHat' {
      file {'/etc/udev/rules.d/60-ipath.rules':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        source=>'puppet:///modules/alcesnetwork/infiniband/60-ipath.rules',
        require=>Exec['installofed'],
      }
    }
    if $lustre {
      if $::osfamily == 'RedHat' {
        file_line {'patch_redhat_rdma':
          path=>'/etc/init.d/rdma',
          ensure=>present,
          line=>'    local apps="ibacm opensm osmtest srp_daemon kiblnd"',
          match=>".*local apps=.*$",
          require=>Exec['installofed'],
        }
      }
    }
    #Apply mlx4 module tweaks
    if $melanox {
      file {'/etc/modprobe.d/alces-mlx.conf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        source=>'puppet:///modules/alcesnetwork/infiniband/alces-mlx4.conf',
        require=>Exec['installofed'],
      }
    }

    #force setting IB hostname
    if $qlogic {
      file_line {'IB-hostname-ql':
        ensure=>present,
        path=>'/etc/rc.local',
        line=>"for dev in `ls -d /sys/class/infiniband/qib*` ; do echo `hostname -s` > \$dev/node_desc; done",
	require=>Exec['installofed'],
      }
    }
    if $melanox {
      file_line {'IB-hostname-mlx':
        ensure=>present,
        path=>'/etc/rc.local',
        line=>"for dev in `ls -d /sys/class/infiniband/mlx4_*` ; do echo `hostname -s` > \$dev/node_desc; done",
	require=>Exec['installofed'],
      }
    }
  }
}
