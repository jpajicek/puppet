## Install Mod Gearman worker
## Usage:

class nagios::gearman::worker (
  $ensure       		= 'installed',
  $debug			= 0,
  $jobserver   			= 'localhost:4730',
  $dubserver			= undef,
  $eventhandler			= undef,
  $services			= undef,
  $hosts			= undef,
  $hostgroups			= undef,
  $servicegroups		= undef,
  $encryption			= 'yes',
  $key				= 'shouldbechanged',
  $job_timeout			= 90,
  $min_worker			= 5,
  $max_worker			= 50,
  $idle_timeout			= 30,
  $max_jobs			= 1000,
  $spawn_rate			= 1,
  $dup_results_are_passive	= undef 			
) {

  Package { ensure => $ensure }

  package { "mod-gearman-tools":} ->
  package { "mod-gearman-worker":} ->


  file { '/etc/mod-gearman/worker.conf':
    content     => template('nagios/gearman/worker.erb'),
    mode        => '0644',
  } ->

  file { '/run/mod-gearman': 
   ensure	=> "directory",
   owner	=> nagios,
  } ->

  service {'mod-gearman-worker':
    ensure => $ensure ? {
        'absent' => stopped,
        default  => running,
      },
    hasstatus   => true,
    hasrestart  => true,
    provider	=> init,
    status	=> "/etc/init.d/mod-gearman-worker status",
    restart	=> "/etc/init.d/mod-gearman-worker restart",
    start	=> "/etc/init.d/mod-gearman-worker start",
    stop	=> "/etc/init.d/mod-gearman-worker stop",
    subscribe   => File['/etc/mod-gearman/worker.conf'],
  }

}

