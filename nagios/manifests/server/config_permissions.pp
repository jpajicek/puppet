
class nagios::server::config_permissions {

  exec {'nagios-cfg-readable':
    command     => "find /etc/nagios3/conf.d -type f -name '*cfg' | xargs chmod +r",
    refreshonly => true,
  } 

}
