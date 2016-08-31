#

class bitbucket::service {

  service { 'bitbucket':
    ensure    => 'running',
    start     => '/etc/init.d/bitbucket start',
    restart   => '/etc/init.d/bitbucket restart',
    stop      => '/etc/init.d/bitbucket stop',
    status    => '/etc/init.d/bitbucket status',
  }

}

