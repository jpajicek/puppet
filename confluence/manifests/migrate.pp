
class confluence::migrate (
  $remote_server  = '', 
  $remote_user    = 'confluence', 
  $remote_home 	  = '/usr/local/confluence_home', 
  $remote_dirs	  = ['attachments', 'imgEffects', 'resources', 'thumbnails', 'viewfile' ]
  ) {
  
  require confluence

  $remote_path_pref = prefix($remote_dirs, ":${remote_home}/")
  $remote_path_real = suffix($remote_path_pref, ' ')

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
  } ->
  
  exec { "confluence_sync":
    command => "rsync -az -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ${remote_user}@${remote_server}${remote_path_real} ${confluence::homedir}/; touch ${confluence::homedir}/.migrated",
    creates => "${confluence::homedir}/.migrated",
    timeout => 0,
    user    => "${confluence::user}",
  } 
  

}
