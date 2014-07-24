# Usage: nagios::nrpe::plugin {"check_tcp_connections.py":}

define nagios::nrpe::plugin (
  $source = '',
  $source_prefix = 'puppet:///modules/',
  $ensure = present,
) {

  if ($::osfamily == 'Debian') {

    if ($source == undef or $source == '') {
      $source_path = "${source_prefix}nagios/plugins/${name}"
    } else {
      $source_path = "${source}"
    }

    if $source_path or $content {
      file { "Nrpe_plugin_${name}":
        ensure   => $ensure,
        path     => "/usr/lib/nagios/plugins/${name}",
        owner    => root,
        group    => root,
        mode     => '0755',
        require  => Class['Nagios::Nrpe'],
        notify   => Class['Nagios::Nrpe::service'],
        source   => $source_path,
      }
    }
  }
}

