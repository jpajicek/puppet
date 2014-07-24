class nscp {

  if ($operatingsystem == 'windows') {

    package { 'NSClient++ (x64)':
      ensure  => installed,
      source  => 'c:\temp\NSCP-0.4.1.101-x64.msi',
      require => File["C:/temp/NSCP-0.4.1.101-x64.msi"], 
    }

    service { 'nscp':
      ensure  => running,
      enable  => true,
      require => Package['NSClient++ (x64)'],
    }

    file { 'C:/temp/NSCP-0.4.1.101-x64.msi':
      ensure  => file,
      owner   => 'SYSTEM',
      mode    => '0664',
      source  => 'puppet:///modules/nscp/installer/NSCP-0.4.1.101-x64.msi',
    }

    file { 'C:/Program Files/NSClient++/nsclient.ini':
      ensure  => file,
      owner   => 'SYSTEM',
      mode    => '0664',
      source  => 'puppet:///modules/nscp/nsclient.ini',
      require => Package['NSClient++ (x64)'],
      notify  => Service['nscp'],
    }
    
    file { 'C:/Program Files/NSClient++/scripts/plugins':
      ensure  => directory,
      mode    => '0777',
      recurse => true,
      source  => 'puppet:///modules/nscp/plugins',
      require => Package['NSClient++ (x64)'],
      notify  => Service['nscp'],
    }

  }
 
}
