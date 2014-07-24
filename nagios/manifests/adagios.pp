
class nagios::adagios {

 include sudo

  sudo::conf { 'admins':
    priority => 10,
    content  => "%nagios ALL=(ALL) NOPASSWD: ALL",
  }

  Package { ensure => installed, require => [ Class["apache"], Class["nagios::server"]], }

  package { "Django": ensure => "1.4.1", provider => pip} -> 
  package { "pynag":} ->
  package { "adagios":} ->

 file { "/etc/apache2/conf.d/adagios.conf":
    content => template('nagios/adagios/apache.cfg'),
    notify  => Class["apache::service"],
  } -> 

  file { "/etc/adagios/adagios.conf":
    content => template('nagios/adagios/adagios.conf.erb'),
    notify  => Class["apache::service"],
  }

}
