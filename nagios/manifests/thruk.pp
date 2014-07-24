class nagios::thruk ($thruk_template){
 
  package {"thruk":
    ensure      => installed,
    require 	=> [ Class["apache"], Class["nagios::server"]],
  } ->

  file { "/etc/apache2/conf.d/thruk.conf":
    content => template('nagios/thruk/apache.conf.erb'),
    notify  => Class["apache::service"],
  } -> 

  file { "/etc/thruk/cgi.cfg":
    content => template('nagios/thruk/cgi.cfg.erb'),
    notify  => Class["apache::service"],
  } -> 

  file { "/etc/thruk/thruk_local.conf":
    content => template("nagios/thruk/${thruk_template}.erb"),
    notify  => Class["apache::service"],
  }
 
}
