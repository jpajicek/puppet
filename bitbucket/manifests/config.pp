 class bitbucket::config {

  require bitbucket
  
  File {
    owner => $bitbucket::user,
    group => $bitbucket::group,
  }

  file { "${bitbucket::bitbucketdir_real}/bin/user.sh":
    content => template('bitbucket/user.sh.erb'),
    mode    => '0755',
  } ->

  file { "${bitbucket::bitbucketdir_real}/bin/setenv.sh":
    content => template('bitbucket/setenv.sh.erb'),
    mode    => '0755',
#   notify  => Class['bitbucket::service'],
  } ->

  file { "${bitbucket::sharedir}/bitbucket.properties":
    content => template("bitbucket/dbconfig.${bitbucket::db}.erb"),
    mode    => '0600',
#   notify  => Class['bitbucket::service'],
  } ->

  
  file { "${bitbucket::bitbucketdir_real}/conf/server.xml":
    content => template('bitbucket/server.xml.erb'),
    mode    => '0755',
  } 

}
