 
class confluence::config {

  require confluence

  File {
    owner => $confluence::user,
    group => $confluence::group,
  }

  file { "${confluence::confluencedir_real}/bin/user.sh":
    content => template('confluence/user.sh.erb'),
    mode    => '0755',
  } ->

  file { "${confluence::confluencedir_real}/bin/setenv.sh":
    content => template('confluence/setenv.sh.erb'),
    mode    => '0755',
#    notify  => Class['confluence::service'],
  } ->

  file { "${confluence::confluencedir_real}/confluence/WEB-INF/classes/confluence-init.properties":
    content => template('confluence/confluence-init.properties.erb'),
    mode    => '0755',
#    notify  => Class['confluence::service'],
  } ->

  file { "${confluence::homedir}/confluence.cfg.xml":
    content => template("confluence/dbconfig.${confluence::db}.xml.erb"),
    mode    => '0600',
#    notify  => Class['confluence::service'],
  }

}
