# This module is a fork of the original puppet-jira module by Bryce Johnson https://github.com/brycejohnson/puppet-jira
# 

class jira::config {

  require jira

#  File {
#    owner => $jira::user,
#    group => $jira::group,
#  }

  file { "${jira::jiradir_real}/bin/user.sh":
    content => template('jira/user.sh.erb'),
    mode    => '0755',
    owner => $jira::user,
    group => $jira::group,
  } ->

  file { "${jira::jiradir_real}/bin/setenv.sh":
    content => template('jira/setenv.sh.erb'),
    mode    => '0755',
    owner => $jira::user,
    group => $jira::group,
#    notify  => Class['jira::service'],
  } ->

  file { "${jira::jiradir_real}/atlassian-jira/WEB-INF/classes/jira-application.properties":
    content => template('jira/jira-application.properties.erb'),
    mode    => '0755',
    owner => $jira::user,
    group => $jira::group,
#    notify  => Class['jira::service'],
  } ->

  file { "${jira::homedir}/dbconfig.xml":
    content => template("jira/dbconfig.${jira::db}.xml.erb"),
    mode    => '0600',
    owner => $jira::user,
    group => $jira::group,
#    notify  => Class['jira::service'],
  }

   file { "${jira::jiradir_real}/conf/server.xml":
    content => template("jira/server.xml.erb"),
    mode    => '0600',
    owner => $jira::user,
    group => $jira::group,
#    notify  => Class['jira::service'],
  }

}
