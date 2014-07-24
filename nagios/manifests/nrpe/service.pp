class nagios::nrpe::service {

 service { "nagios-nrpe-server":
     ensure     => running,
     enable     => true,
     pattern    => "nrpe",
     start      => "/etc/init.d/nagios-nrpe-server start",
     stop       => "/etc/init.d/nagios-nrpe-server stop",
     restart    => "/etc/init.d/nagios-nrpe-server restart",
  }

}
