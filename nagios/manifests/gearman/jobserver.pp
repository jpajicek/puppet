## Install Gearman Job Server
## usage: 

class nagios::gearman::jobserver ( 
  $ensure 	= 'installed',
  $gearman_ip   = $::ipaddress
) {

  package { "gearman-job-server":
    ensure  	=> $ensure
  } -> 

  file { "/etc/default/gearman-job-server":
    content 	=> template('nagios/gearman/gearman-job-server.erb'),
    mode    	=> '0644',
  } ->

  service {"gearman-job-server": 
    ensure => $ensure ? {
        'absent' => stopped,
        default  => running,
      },
    hasstatus 	=> true,
    hasrestart 	=> true,
    subscribe	=> File['/etc/default/gearman-job-server'],

  }

}
