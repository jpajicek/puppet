## Example
## nagios::command {'check_service': command_line => '/usr/lib/nagios/plugins/check_service -H $HOSTADDRESS$ -c $ARG1$ -a $ARG2$' }

define nagios::command (
  $command_line,
  $nagios_tag    = $nagios::params::nagios_tag,
  $ensure        = present,
  ) {

  include nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  @@nagios_command { $name:
    ensure        => $ensure,
    command_line  => $command_line,
    target        => "${nagios::params::plugin_configdir}/command-${fname}.cfg",
    owner  	  => 'root',
    mode          => '0644',
    notify        => Class["nagios::server::service"],
    tag           => $nagios_tag,
  }

}






