
class confluence::migrate {
 
  require confluence

  file {"$confluence::homedir/.ssh":
    ensure  => directory,
    owner   => "${confluence::user}",
    group   => "${confluence::user}",
    require => Class["confluence::install"],
  } ->

  file {"$confluence::homedir/.ssh/authorized_keys":
    ensure  => file,
    owner   => "${confluence::user}",
    group   => "${confluence::user}",
    source  => "puppet:///modules/confluence/authorized_keys",
    mode    => 0600,    
  } ->

  file {"$confluence::homedir/.ssh/id_rsa":
    ensure  => file,
    owner   => "${confluence::user}",
    group   => "${confluence::user}",
    source  => "puppet:///modules/confluence/id_rsa",
    mode    => 0600,
  } 
  
  file { "${confluence::homedir}/migrate_static.sh":
    content => template("confluence/migrate_static.sh.erb"),
    mode    => '0700',
    owner   => root,
  }
  

}
