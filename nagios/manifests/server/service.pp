
class nagios::server::service {

  service { "nagios3":
    ensure      => running,
    enable      => true,
    # require	=> Class [nagios::server],
  }

}
