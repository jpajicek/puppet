class bitbucket::install {

  require bitbucket

     exec	{ "download-${bitbucket::product}-${bitbucket::version}":
     cwd     	=> "${bitbucket::installdir}",
     command	=> "/usr/bin/wget -O atlassian-${bitbucket::product}-${bitbucket::version}.${bitbucket::format} ${bitbucket::downloadURL}/atlassian-${bitbucket::product}-${bitbucket::version}.${bitbucket::format}",
     creates 	=> "${bitbucket::installdir}/atlassian-${bitbucket::product}-${bitbucket::version}.${bitbucket::format}",
     timeout	=> 1200,        
  } ->

     exec 	{"extract-${bitbucket::product}-${bitbucket::version}":
     cwd    	=> "${bitbucket::installdir}",
     command 	=> "/bin/tar -xzf atlassian-${bitbucket::product}-${bitbucket::version}.${bitbucket::format}",
     creates 	=> "${bitbucket::installdir}/atlassian-${bitbucket::product}-${bitbucket::version}",
     notify  	=> Exec["chown_${bitbucket::bitbucketdir_real}"],
  } ->

  user { $bitbucket::user:
    comment     => 'bitbucket daemon account',
    shell       => '/bin/bash',
    home        => $bitbucket::homedir,
    password    => '*',
    managehome  => true,
  } ->

  file {"$bitbucket::bitbucketdir":
    ensure  	=> 'link',
    target  	=> "${bitbucket::installdir}/atlassian-${bitbucket::product}-${bitbucket::version}",
    owner  	=> "${bitbucket::user}",
    group   	=> "${bitbucket::user}",
  } -> 

  file { ["$bitbucket::homedir", "$bitbucket::homedir/shared"]:
    ensure 	 => 'directory',
    owner  	 => $bitbucket::user,
    group  	 => $bitbucket::group,
#   recurse 	 => true,
  } ->

  exec { "chown_${bitbucket::bitbucketdir_real}":
    command     => "/bin/chown ${bitbucket::user}:${bitbucket::group} -R ${bitbucket::bitbucketdir_real}",
    refreshonly => true,
    subscribe   => User[$bitbucket::user],
  } ->

  file { '/etc/init.d/bitbucket':
    content	=> template('bitbucket/etc/stash.erb'),
    mode   	=> '0755',
  }


}
