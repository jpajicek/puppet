
class nagios::server (
  $nagios_tag		= $nagios::params::nagios_tag,
  $livestatus		= $nagios::params::livestatus,
  $thruk                = $nagios::params::thruk,
  $thruk_template	= $nagios::params::thruk_template,
  $pnp                  = $nagios::params::pnp,
  $adagios              = $nagios::params::adagios,
  $gearman_mod          = $nagios::params::gearman_mod
) inherits nagios::params {

  include nagios::server::package
  include nagios::server::tidy
  class { "nagios::server::config": 
     nagios_server	  => $nagios_server,
     livestatus           => $livestatus,
     thruk                => $thruk,
     pnp                  => $pnp,
     adagios              => $adagios,
     gearman_mod          => $gearman_mod
  }

  include nagios::server::service  
  include nagios::server::config_permissions

  if $livestatus {
    include nagios::livestatus
  }

  if $thruk {
    class {"nagios::thruk": thruk_template => $thruk_template }
  }

  if $adagios {
    include nagios::adagios
  }

  if $pnp {
    include nagios::pnp
  }

  Nagios_host <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require	=> Class["nagios::server::config"],
  }

  Nagios_command <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_contact <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_contactgroup <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_hostdependency <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_hostgroup <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_service <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_servicegroup <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Nagios_timeperiod <<| tag == "${nagios_tag}" |>> {
    notify      => [ Class["nagios::server::config_permissions"], Class["nagios::server::service"]],
    require     => Class["nagios::server::config"],
  }

  Class["nagios::server::package"] -> Class["nagios::server::tidy"] -> Class["nagios::server::config"] -> Class["nagios::server::service"]
}
