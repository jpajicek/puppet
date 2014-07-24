class crowd::install {

  require crowd

  File {
    owner   => $crowd::user,
    group   => $crowd::group,
  }

  file { "$crowd::installdir":
     ensure	=> 'directory',
     owner	=> root,
     group	=> root,
  } ->

  user { $crowd::user:
    comment     => 'crowd daemon account',
    shell       => '/bin/bash',
    home        => $crowd::homedir,
    password    => '*',
    managehome  => true,
  } ->

  exec { "download-${crowd::product}-${crowd::version}":
     cwd     	=> "${crowd::installdir}",
     command	=> "/usr/bin/wget -O atlassian-${crowd::product}-${crowd::version}.${crowd::format} ${crowd::downloadURL}/atlassian-${crowd::product}-${crowd::version}.${crowd::format}",
     creates 	=> "${crowd::installdir}/atlassian-${crowd::product}-${crowd::version}.${crowd::format}",
     timeout	=> 1200,        
  } ->

  exec 	{"extract-${crowd::product}-${crowd::version}":
     cwd    	=> "${crowd::installdir}",
     command 	=> "/bin/tar -xzf atlassian-${crowd::product}-${crowd::version}.${crowd::format}",
     creates 	=> "${crowd::installdir}/atlassian-${crowd::product}-${crowd::version}",
     notify  	=> Exec["chown_${crowd::crowddir_real}"],
  } ->

  file {"$crowd::crowddir":
    ensure  	=> 'link',
    target  	=> "${crowd::installdir}/atlassian-${crowd::product}-${crowd::version}",
  } -> 

  file { $crowd::homedir:
    ensure 	 => 'directory',
  } ->

  exec { "chown_${crowd::crowddir_real}":
    command     => "/bin/chown ${crowd::user}:${crowd::group} -R ${crowd::crowddir_real}",
    refreshonly => true,
    subscribe   => User[$crowd::user],
  } ->

  file { '/etc/init.d/crowd':
    content	=> template('crowd/etc/crowd.erb'),
    mode   	=> '0755',
  }


}
