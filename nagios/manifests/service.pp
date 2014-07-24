define nagios::service (
  $ensure			= present,
  $nagios_tag     		= $nagios::params::nagios_tag,
  $check_command 		= '',
  $use				= 'generic-service',
  $service_description  	= 'absent',
  $host_name 			= 'absent',
  $hostgroup_name		= 'absent',
  $check_command 		= 'absent',
  $check_period 		= '',
  $normal_check_interval 	= '',
  $retry_check_interval  	= '',
  $max_check_attempts    	= '',
  $notification_interval 	= '',
  $notification_period   	= '',
  $notification_options  	= '',
  $contact_groups		= '',
  $register			= '0'
  )  {


  if ($register == '0') { 
    $target_real = 'templates'
  } else {
    $target_real = 'defined'
  }
  
  @@nagios_service { $name:
    ensure        => $ensure,
    use 	  => $use,
    service_description => $service_description ?{
        'absent'  => $name,
        default   => $service_description,
      }, 
    check_command => $check_command,
    target        => "${nagios::params::confd_services}/${target_real}/service-${name}.cfg",
#    owner  	  => 'root',
#    mode   	  => '0644',
    register      => $register,
    tag           => $nagios_tag,
    notify        => Class["nagios::server::service"],
  }

  if ($host_name != 'absent') {
    Nagios_service["${name}"] { host_name => $host_name }
  }

  if ($hostgroup_name != 'absent') {
    Nagios_service["${name}"] { hostgroup_name => $hostgroup_name }
  }

  if ($check_period != '') {
    Nagios_service["${name}"] { check_period => $check_period }
  }
  
  if ($normal_check_interval != '') {
    Nagios_service["${name}"] { normal_check_interval => $normal_check_interval }
  }
  
  if ($retry_check_interval != '') {
    Nagios_service["${name}"] { retry_check_interval => $retry_check_interval }
  }
  
  if ($max_check_attempts != '') {
    Nagios_service["${name}"] { max_check_attempts => $max_check_attempts }
  }
  
  if ($notification_interval != '') {
    Nagios_service["${name}"] { notification_interval => $notification_interval }
  }
  
  if ($notification_period != '') {
    Nagios_service["${name}"] { notification_period => $notification_period }
  }
  
  if ($notification_options != '') {
    Nagios_service["${name}"] { notification_options => $notification_options }
  }
  
  if ($contact_groups != '') {
    Nagios_service["${name}"] { contact_groups => $contact_groups }
  }

}
