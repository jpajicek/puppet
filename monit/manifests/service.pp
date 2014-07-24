 
define monit::service(
   $ensure='present'
) {

  file { "/etc/monit/conf.d/${name}":
    ensure  => $ensure,
    source  => "puppet:///modules/monit/conf.d/${name}",
    owner   => root,
    group   => root,
    require => Package["monit"],
    notify  => Service["monit"],
    mode    => 0644,
   }

}

