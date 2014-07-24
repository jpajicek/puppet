class nagios::nrpe {

 if ($::osfamily == 'Debian') {
  package { 
    "nagios-nrpe-server": ensure => installed;
    "nagios-nrpe-plugin": ensure => installed;
  }

  file { "/etc/nagios/nrpe.cfg":
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => 644,
     content => template("nagios/nrpe.erb"),
     require => Package["nagios-nrpe-server"],
     notify  => Class['nagios::nrpe::service'],
  }

  file { "/etc/nagios/nrpe.d":
     ensure  => directory,
     source  => "puppet:///modules/nagios/nrpe.d",
     owner   => root,
     group   => root,
     recurse => true,
     mode    => 644,
     require => Package["nagios-nrpe-server"],
     notify  => Class['nagios::nrpe::service'],
  }

  include nagios::nrpe::service
  Package["nagios-nrpe-server"] ~> Class['nagios::nrpe::service']

 }

}
