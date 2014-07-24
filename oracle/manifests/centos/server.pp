class oracle::centos::server {

  file { "/opt/oracle-xe-11.2.0-1.0.x86_64.rpm.zip":
      mode => 0755,
      source => "puppet:///modules/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip";
  }

  exec { "oracle-extract":
      command => "unzip /opt/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d /opt/oracle-inst",
      unless  => "ls -ld /opt/oracle-inst",
      require => File["/opt/oracle-xe-11.2.0-1.0.x86_64.rpm.zip"],
  }

  package {"oracle-xe":
      ensure  => installed,
      provider => rpm,
      require => [ Exec["oracle-extract"], Class["oracle::centos::deps"]],
      source  => "/opt/oracle-inst/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm"
  }

  file {
    "/etc/profile.d/oracle-env.sh":
      source => "puppet:///modules/oracle/oracle-env.sh";
    "/tmp/xe.rsp":
      source => "puppet:///modules/oracle/xe.rsp";
  }

  exec {
    "configure xe":
      command => "/etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp >> /tmp/xe-install.log",
      timeout => 1800,
      require => [Package["oracle-xe"],
                  File["/etc/profile.d/oracle-env.sh"],
                  File["/tmp/xe.rsp"]],
      creates => "/etc/sysconfig/oracle-xe";
  }

  service {
        "oracle-xe":
          ensure => "running",
          require => [Package["oracle-xe"], Exec["configure xe"]],
  }
	
}
