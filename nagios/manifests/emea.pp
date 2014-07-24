class nagios::emea {


  file { "/root/.ssh":
    ensure  => directory,
    mode    => 0700,
  } -> 

  file { "/root/.ssh/id_rsa.pub":
    ensure  => file,
    source  => "puppet:///modules/nagios/server/emea/id_rsa.pub",
    mode    => 0644,	
  } -> 

  file { "/root/.ssh/id_rsa":
    ensure  => file,
    source  => "puppet:///modules/nagios/server/emea/id_rsa",
    mode    => 0600,
  } -> 

  file { "/root/emea_checkout.sh":
    ensure  => file,
    source  => "puppet:///modules/nagios/server/emea/emea_checkout.sh",
    mode    => 0774,
  }

}
