class bitbucket::migrate {

  require bitbucket

  File {
    owner => $bitbucket::user,
    group => $bitbucket::group,
  }

  file {"$bitbucket::homedir/.ssh":
    ensure  => directory,
    require => Class["bitbucket::install"],
  } ->

  file {"$bitbucket::homedir/.ssh/authorized_keys":
    ensure  => file,
    source  => "puppet:///modules/bitbucket/authorized_keys",
    mode    => 0600,
  } ->

  file {"$bitbucket::homedir/.ssh/id_rsa":
    ensure  => file,
    source  => "puppet:///modules/bitbucket/id_rsa",
    mode    => 0600,
  }

  file { "${bitbucket::homedir}/migrate_static.sh":
    content => template("bitbucket/migrate_static.sh.erb"),
    mode    => '0700',
    owner   => root,
  }


}

