 class crowd::config {

  require crowd

  File {
    owner => $crowd::user,
    group => $crowd::group,
  }


  file { "${crowd::crowddir_real}/apache-tomcat/bin/setenv.sh":
    content => template('crowd/setenv.sh.erb'),
    mode    => '0755',
  } ->

  file { "${crowd::crowddir_real}/crowd-webapp/WEB-INF/classes/crowd-init.properties":
    mode    => '0755',
    content => template('crowd/crowd-init.properties.erb'),
  }

  file { "${crowd::homedir}/crowd.cfg.xml":
    content => template("crowd/dbconfig.${crowd::db}.xml.erb"),
    mode    => '0600',
  }

  file { "${crowd::homedir}/crowd.properties":
    content => template("crowd/crowd.properties.erb"),
    mode    => '0600',
  }

}
