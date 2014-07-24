
class nagios::server::package {

  package {"nagios3":
    ensure	=> installed,
  }
  
}
