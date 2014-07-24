class nagios::livestatus {

  package { "check-mk-livestatus" :
    ensure	=> installed,
    require	=> Class["nagios::server"],
  }


  class {"xinetd": service_hasstatus => true }


  xinetd::service { 'livestatus':
    service_type => 'UNLISTED',
    port        => '6557',
    server      => '/usr/local/bin/unixcat',
    server_args => '/var/lib/nagios3/livestatus.sock',
    socket_type => 'stream',
    user	=> 'nagios',
    protocol    => 'tcp',
    cps         => '100 3',
    flags       => 'IPv4',
    per_source  => '100',
    wait	=> 'no',
  }

}
