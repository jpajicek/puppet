#

class jira::service {

  service { 'jira':
    ensure    => 'running',
    start     => '/etc/init.d/jira start',
    restart   => '/etc/init.d/jira restart',
    stop      => '/etc/init.d/jira stop',
    status    => '/etc/init.d/jira status',
  }

}
