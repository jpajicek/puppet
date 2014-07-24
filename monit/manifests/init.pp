
class monit ($monitint = '10'){

  $configdir = "/etc/monit/conf.d"

  package { "monit":
    ensure => installed;
  } ->
	
  file { "/etc/default/monit":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("monit/monit"),
    notify  => Service["monit"],
  } -> 

  file { "/etc/monit/monitrc":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 600,
    content => template("monit/monitrc.erb"),
    notify  => Service["monit"],
  } -> 

  file { "/etc/monit/monit_delay":
    ensure  => present,
    mode    => 777,
    content => template("monit/monit_delay"),
    notify  => Service["monit"],
  } -> 
  
  file { "/etc/init.d/monit":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 751,
    source  => "puppet:///modules/monit/init.d/monit",
    notify  => Service["monit"],
  } -> 
	 
  service { "monit":
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    provider    => init;
  }


}
