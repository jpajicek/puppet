class network::centrifydc (
$ensure=join,
$install="installed",
$domain='',
$svc_user='',
$svc_pass='',
$dns_server='',
$ou="",
$group_allow=''
)
{

  if $ensure in [ join, leave ] {
        $ensure_real = $ensure
      } else {
        fail('ensure parameter must be join or leave')
  }


  package {"centrifydc": 
    ensure => $install,
  }
  
  package {"centrifydc-openssh":	
    ensure  => $install,
    require => Package["centrifydc"],
  }

  file {"centrifydc-cfg":
    path    => "/etc/centrifydc/centrifydc.conf",
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("network/centrifydc/centrifydc.conf.erb"),
    # require => Package["centrifydc"],
  
  }
  
  file {"centrify-sshd-cfg":
    path    => "/etc/centrifydc/ssh/sshd_config",
    owner   => root,
    group   => root,
    mode    => 600,
    content => template("network/centrifydc/sshd_config.erb"),
    # require => Package["centrifydc-openssh"],

  }
  
 if ($ensure == join) {
    network::adjoin { '$domain': svc_user => $svc_user, svc_pass => $svc_pass, domain => $domain, ou => $ou}
    network::addns { '$domain': svc_user => $svc_user, svc_pass => $svc_pass, domain => $domain, dns_server => $dns_server }
    Package["centrifydc"] -> Package["centrifydc-openssh"] -> File["centrifydc-cfg"] -> File["centrify-sshd-cfg"] -> Exec["adjoin-$domain"] -> Service["centrifydc"] -> Service["centrify-sshd"] -> Exec["addns-$domain"]

    service { "centrifydc":
      ensure       => running,
      subscribe    => File["centrifydc-cfg"],
    }

    service { "centrify-sshd":
      pattern     => "/usr/share/centrifydc/sbin/sshd",
      ensure      => running,
      hasstatus   => false,
      hasrestart  => true,
      subscribe   => File["centrify-sshd-cfg"],
    }
 } 
 
 if ($ensure == leave) {
  network::adleave { '$domain': domain => $domain }
 } 
	
}
