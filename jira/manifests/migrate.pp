# To include migrate script
# Example usage:
#
# include jira::migrate
#

class jira::migrate {

  require jira

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

  file { "${jira::homedir}/migrate_static.sh":
    content => template("jira/migrate_static.sh.erb"),
    mode    => '0700',
    owner   => root,
  }

}

