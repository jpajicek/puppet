# This module is a fork of the original puppet-jira module by Bryce Johnson https://github.com/brycejohnson/puppet-jira
# 

class jira::install {

  require jira

  exec { "download-${jira::product}-${jira::version}":
     cwd     => "${jira::installdir}",
     command => "/usr/bin/wget -O atlassian-${jira::product}-${jira::version}.${jira::format} ${jira::downloadURL}/atlassian-${jira::product}-${jira::version}.${jira::format}",
     creates => "${jira::installdir}/atlassian-${jira::product}-${jira::version}.${jira::format}",
     timeout => 1200,        
  } ->

  exec {"extract-${jira::product}-${jira::version}":
     cwd     => "${jira::installdir}",
     command => "/bin/tar -xzf atlassian-${jira::product}-${jira::version}.${jira::format}",
     creates => "${jira::installdir}/atlassian-${jira::product}-${jira::version}-standalone",
     notify  => Exec["chown_${jira::jiradir_real}"],
  } ->

  user { $jira::user:
    comment          => 'Jira daemon account',
    shell            => '/bin/bash',
    home             => $jira::homedir,
    password         => '*',
    managehome       => true,
  } ->

  file {"$jira::jiradir":
    ensure  => 'link',
    target  => "${jira::installdir}/atlassian-${jira::product}-${jira::version}-standalone",
    owner   => "${jira::user}",
    group   => "${jira::user}",
  } -> 

  file { $jira::homedir:
    ensure  => 'directory',
    owner   => $jira::user,
    group   => $jira::group,
    # recurse => true,
  } ->

  exec { "chown_${jira::jiradir_real}":
    command     => "/bin/chown ${jira::user}:${jira::group} -R ${jira::jiradir_real}",
    refreshonly => true,
    subscribe   => User[$jira::user],
  } ->

  file { '/etc/init.d/jira':
    content => template('jira/etc/jira.erb'),
    mode    => '0755',
  }


}
