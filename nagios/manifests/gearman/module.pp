## Install Mod Gearman NEB module	
## Dependecy: stdlib module
## Usage:

class nagios::gearman::module (
  $ensure                       = 'installed',
  $debug                        = 0,
  $jobserver                    = 'localhost:4730',
  $dubserver                    = undef,
  $eventhandler                 = undef,
  $services                     = undef,
  $hosts                        = undef,
  $hostgroups                   = undef,
  $servicegroups                = undef,
  $do_hostchecks		= 'yes',
  $encryption                   = 'yes',
  $key                          = 'shouldbechanged',
  $use_uniq_jobs		= 'on',
  $localhostgroups		= '',
  $localservicegroups		= '',
  $queue_custom_variable	= undef,
  $result_workers		= 1,
  $perfdata			= 'no',
  $perfdata_mode		= 1,
  $orphan_host_checks		= 'yes',
  $orphan_service_checks	= 'yes',
  $accept_clear_results		= 'no'
) {

  Package { ensure => $ensure }

  package { "mod-gearman-module":} ->
 
  file { '/etc/mod-gearman/module.conf':
    content     => template('nagios/gearman/module.erb'),
    mode        => '0644',
  } 
  
  file { '/var/log/mod_gearman_neb.log':
    ensure	=> present,
    mode	=> 0644,
    owner	=> nagios,
  }

  file_line { "event_broker_options":
    path  => "/etc/nagios3/nagios.cfg",
    line  => "event_broker_options=-1",
    match => "^event_broker_options=",
  }
  
  file_line { "enable_broker_module_gearman":
    path  => "/etc/nagios3/nagios.cfg",
    line  => "broker_module=/usr/lib/mod_gearman/mod_gearman.o config=/etc/mod-gearman/module.conf",
  }

}
