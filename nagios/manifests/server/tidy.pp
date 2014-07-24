class nagios::server::tidy {

  notify {"debug tidy":}

  exec {"tidy_nagios_dir":
    command => "find /etc/nagios3/conf.d -maxdepth 1 -name '*_nagios2.cfg' -exec rm -rf {} \;",
    onlyif  => "find /etc/nagios3/conf.d -maxdepth 1 -name '*.cfg' | egrep '*_nagios2.cfg'",
  }
 
  ## Doesnt work on first run, bug?
  # tidy { "/etc/nagios3/conf.d":
  #   recurse => 1,
  #   matches => [ "*_nagios2.cfg" ],
  # } 

}
