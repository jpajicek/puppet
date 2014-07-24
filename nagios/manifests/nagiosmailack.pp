class nagios::nagiosmailack (
 $nagiosid='',
 $mailserver='',
 $username='',
 $password='',
 $port='993',
 $ssl='true'
) {

  file { "/usr/bin/nagMailAck":
    ensure => 'directory',
  } -> 
 
  file { "/usr/bin/nagMailAck/nagMailACK.rb":
    ensure   => present,
    mode     => 0775,
    content  => template('nagios/nagiosmailack/nagMailACK.rb.erb'),
  } -> 

  file { "/etc/init.d/nagiosmailack":
    ensure   => present,
    mode     => 0775,
    source   => "puppet:///modules/nagios/nagiosmailack/init.d/nagiosmailack",    
  } ->

  service { "nagiosmailack":
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    start      => "/etc/init.d/nagiosmailack start",
    stop       => "/etc/init.d/nagiosmailack stop",
    restart    => "/etc/init.d/nagiosmailack restart",
  }


}
