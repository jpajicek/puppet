#

class confluence::service {

  service { 'confluence':
    ensure    => 'running',
    start     => '/etc/init.d/confluence start',
    restart   => '/etc/init.d/confluence restart',
    stop      => '/etc/init.d/confluence stop',
    status    => '/etc/init.d/confluence status',
  }

}
