class nagios::pnp {

  File {
    owner => root,
    group => root,
  }

  package {"pnp4nagios": 
    ensure	=> installed,
    require     => [ Class["apache"], Class["nagios::server"]],
  } -> 

  file { "/etc/apache2/conf.d/pnp4nagios.conf":
    content => template('nagios/pnp/apache.conf.erb'),
    notify  => Class["apache::service"],
  } ->

  file { "/etc/nagios3/conf.d/pnp4nagios.cfg":
    ensure => 'link',
    target => '/etc/pnp4nagios/nagios.cfg',
  } -> 

  file { "/usr/share/pnp4nagios/html/templates.dist":
    ensure  => directory,
    source  => "puppet:///modules/nagios/pnp/templates",
    recurse => true,
    purge   => false,
  } ->

  file { "/etc/pnp4nagios/check_commands":
    ensure  => directory,
    source  => "puppet:///modules/nagios/pnp/check_commands",
    recurse => true,
    purge   => false,
  }
}
