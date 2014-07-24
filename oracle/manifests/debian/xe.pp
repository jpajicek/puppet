class oracle::debian::xe {
  file {
    "/etc/profile.d/oracle-env.sh":
      source => "puppet:///modules/oracle/oracle-env.sh";
    "/tmp/xe.rsp":
      source => "puppet:///modules/oracle/xe.rsp";
    "/bin/awk":
      ensure => link,
      target => "/usr/bin/awk";
    "/var/lock/subsys":
      ensure => directory;
    "/var/lock/subsys/listener":
      ensure => present;
  }

  exec {
    "configure xe":
      command => "pkill tnslsnr; /etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp >> /tmp/xe-install.log",
      timeout => 1800,
      require => [Package["oracle-xe"],
                  File["/etc/profile.d/oracle-env.sh"],
                  File["/tmp/xe.rsp"],
                  File["/var/lock/subsys/listener"],
                  Exec["set up shm"],
                  Exec["enable swapfile"]],
      creates => "/etc/default/oracle-xe";
  }

 ## Package from private apt repository
  package {
    "oracle-xe":
      ensure => latest,
      require => Exec["oracle-apt-update"],
  }

  service {
        "oracle-xe":
          ensure => "running",
          require => [Package["oracle-xe"], Exec["configure xe"]],
  }
}
