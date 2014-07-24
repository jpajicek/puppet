
class confluence::install {

  require confluence

  exec { "download-${confluence::product}-${confluence::version}":
     cwd     => "${confluence::installdir}",
     command => "/usr/bin/wget -O atlassian-${confluence::product}-${confluence::version}.${confluence::format} ${confluence::downloadURL}/atlassian-${confluence::product}-${confluence::version}.${confluence::format}",
     creates => "${confluence::installdir}/atlassian-${confluence::product}-${confluence::version}.${confluence::format}",
     timeout => 1200,        
  } ->

  exec {"extract-${confluence::product}-${confluence::version}":
     cwd     => "${confluence::installdir}",
     command => "/bin/tar -xzf atlassian-${confluence::product}-${confluence::version}.${confluence::format}",
     creates => "${confluence::installdir}/atlassian-${confluence::product}-${confluence::version}",
     notify  => Exec["chown_${confluence::confluencedir_real}"],
  } ->

  user { $confluence::user:
    comment          => 'Confluence daemon account',
    shell            => '/bin/bash',
    home             => $confluence::homedir,
    password         => '*',
    managehome       => true,
  } ->

  file {"$confluence::confluencedir":
    ensure  => 'link',
    target  => "${confluence::installdir}/atlassian-${confluence::product}-${confluence::version}",
    owner   => "${confluence::user}",
    group   => "${confluence::user}",
  } -> 

  file { $confluence::homedir:
    ensure  => 'directory',
    owner   => $confluence::user,
    group   => $confluence::group,
#   recurse => true,
  } ->

  exec { "chown_${confluence::confluencedir_real}":
    command     => "/bin/chown ${confluence::user}:${confluence::group} -R ${confluence::confluencedir_real}",
    refreshonly => true,
    subscribe   => User[$confluence::user],
  } ->

  file { '/etc/init.d/confluence':
    content => template('confluence/etc/confluence.erb'),
    mode    => '0755',
  }


}
