# Should be removed from live server!
# Example usage:
#
# class {"jira::migrate": remote_server => "ldnxpjira01", remote_user => "jira1", remote_home => '/usr/local/jira_home', remote_dirs => ['plugins', 'data', 'caches', 'logos'], }
#

class jira::migrate (
  $remote_server  = '',
  $remote_user    = 'jira',
  $remote_home    = '/data/jira_home',
  $remote_dirs    = ['plugins', 'data', 'caches', 'logos']
  ) {

  require jira

  $remote_path_pref = prefix($remote_dirs, ":${remote_home}/")
  $remote_path_real = suffix($remote_path_pref, ' ')

  file {"$jira::homedir/.ssh":
    ensure  => directory,
    owner   => "${jira::user}",
    group   => "${jira::user}",
    require => Class["jira::install"],
  } ->

  file {"$jira::homedir/.ssh/authorized_keys":
    ensure  => file,
    owner   => "${jira::user}",
    group   => "${jira::user}",
    source  => "puppet:///modules/jira/authorized_keys",
    mode    => 0600,
  } ->

  file {"$jira::homedir/.ssh/id_rsa":
    ensure  => file,
    owner   => "${jira::user}",
    group   => "${jira::user}",
    source  => "puppet:///modules/jira/id_rsa",
    mode    => 0600,
  } ->

  exec { "jira_sync":
    command => "rsync -az -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ${remote_user}@${remote_server}${remote_path_real} ${jira::homedir}/; touch ${jira::homedir}/.migrated",
    creates => "${jira::homedir}/.migrated",
    timeout => 0,
    user    => "${jira::user}",
  }


}

