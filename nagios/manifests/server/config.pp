
class nagios::server::config (
  $nagios_server	= $nagios::params::nagios_server,
  $livestatus           = $nagios::params::livestatus,
  $thruk                = $nagios::params::thruk,
  $pnp                  = $nagios::params::pnp,
  $adagios              = $nagios::params::adagios,
  $gearman_mod          = $nagios::params::gearman_mod
) inherits nagios::params { 
  
  File {
    owner => root,
    group => root,
    mode  => '0644',
  }

  user { 'nagios':
    shell	=> '/bin/bash',
    home	=> $user_home,
    groups	=> sudo,
    password	=> '*',
    managehome	=> true,
  }
  
  ## www-data to the Nagios Group workaround, permissions to /var/lib/nagios3/rw/nagios.cmd

  User <| title == www-data |> { groups +> "nagios" }

  file { "/var/lib/nagios/.esxipass":
    ensure	=> "present",
    replace	=> "no",
    content	=> "root Password",
    require	=> User["nagios"],
  } -> 
 
  file { "/var/lib/nagios/.esxpass":
    ensure      => "present",
    replace     => "no",
    content     => "username=root\npassword=passowrd",
    require     => User["nagios"],
  } -> 

  file { [ "$confd_hosts", "$confd_hostgroups", "$confd_services", "$confd_dependecies", "$confd_servicegroups" ]:
    ensure      => "directory",
    mode        => 0755,
  } -> 
  
  file { [ "$confd_hosts/puppet", "$confd_gui" ]:
    ensure      => "directory",
    mode        => 0755,
    owner	=> nagios,
  } ->

  file { "$confd_services/templates":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/services/templates",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_services/defined":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/services/defined",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_hosts/templates":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/hosts/templates",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_hosts/defined":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/hosts/defined",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_hostgroups/templates":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/hostgroups/templates",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->
 
  file { "$confd_hostgroups/defined":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/conf.d/hostgroups/defined",
    recurse => true,
    notify  => Class["nagios::server::service"],
  } ->

  file { "/usr/share/nagios/htdocs/images/logos/base":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/images/base",
    recurse => true,
  } ->

  file { "/usr/share/nagios3/plugins/eventhandlers":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/eventhandlers",
    recurse => true,
    mode    => 0775,
  } ->

  file { "/etc/nagios3/htpasswd.users":
    source  => "puppet:///modules/nagios/server/conf.d/htpasswd.users",
  } ->
  
  file { "/etc/nagios3/commands.cfg":
    source  => "puppet:///modules/nagios/server/conf.d/commands.cfg",
    notify  => Class["nagios::server::service"],
  } ->

  file { "/etc/nagios3/nagios.cfg":
    content => template('nagios/server/nagios.cfg.erb'),
    notify  => Class["nagios::server::service"],
  } ->

  file { "/etc/nagios3/cgi.cfg":
    content => template('nagios/server/cgi.cfg.erb'),
    notify  => Class["nagios::server::service"],
  } ->

  file { "/etc/nagios3/apache2.conf":
    source  => "puppet:///modules/nagios/server/conf.d/apache2.conf",
  } ->

  file { "/etc/nagios3/verify_config":
    source  => "puppet:///modules/nagios/server/conf.d/verify_config",
    mode    => '0777',
  } ->

  file { "/etc/nagios3/conf.d/contacts.cfg":
    source  => "puppet:///modules/nagios/server/conf.d/contacts.cfg",
    notify  => Class["nagios::server::service"],
  } ->

  file { "/etc/nagios3/conf.d/timeperiods.cfg":
    source  => "puppet:///modules/nagios/server/conf.d/timeperiods.cfg",
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_hosts/localhost.cfg":
    content => template('nagios/server/localhost.cfg.erb'),
    notify  => Class["nagios::server::service"],
  } ->

  file { "$confd_services/defined/localhost_ping.cfg":
    content => template('nagios/server/localhost_ping.cfg.erb'),
    notify  => Class["nagios::server::service"],
  } 


}
