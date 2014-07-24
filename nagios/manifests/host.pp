class nagios::host (
$ensure		= 'present',
$parents 	= 'absent',
$address 	= $::ipaddress,
$nagios_alias 	= $::hostname,
$use		= 'generic-host',
$check_command	= 'check-host-alive!3000.0,80%!5000.0,100%!10',		
$hostgroups 	= 'absent',
$nagios_tag	= $nagios::params::nagios_tag
) inherits nagios::params {

  @@nagios_host { $::hostname:
    ensure	  => $ensure,
    address       => $::ipaddress,
    alias 	  => $nagios_alias,
    use           => $use,
    check_command => $check_command,
    target        => "$confd_hosts/puppet/host_${::hostname}.cfg",
    tag		  => $nagios_tag,
  }

 if ($parents != 'absent') {
    Nagios_host["${::hostname}"] { parents => $parents }
  }

  if ($hostgroups != 'absent') {
    Nagios_host["${::hostname}"] { hostgroups => $hostgroups }  
  }

}
