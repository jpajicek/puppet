# install sun-java 1.6
# Requirements: AKQA APT Repository
# Usage: include java:sun
# or class {"java::sun": stage => essentials }


class java::oracle::jdk6 {


case $::operatingsystem {
    debian, ubuntu: {
	
	exec { "sun-apt-update":
                path => "/bin:/usr/bin",
                command => "apt-get update",
                unless => "apt-cache search sun-java | grep sun-java6-jdk",
        }

        file {"/var/cache/debconf/sun-java6.preseed":
                ensure => "present",
                source => "puppet:///modules/java/sun-java6.preseed",
        }

        package { "sun-java6-jdk":
                ensure => installed,
                responsefile => "/var/cache/debconf/sun-java6.preseed",
                require => [ File["/var/cache/debconf/sun-java6.preseed"], Exec["sun-apt-update"] ],
        }

        file { "/etc/alternatives/java":
                ensure => "/usr/lib/jvm/java-6-sun/jre/bin/java",
                require => Package["sun-java6-jdk"],
        }

    }

    centos, redhat: {

	file {"/opt/jdk-6u45-linux-x64-rpm.bin":
                ensure => "present",
		mode   => 755,		
                source => "puppet:///modules/java/jdk-6u45-linux-x64-rpm.bin",
        }

	exec {"jdk-6u45-install":
      		command => "/bin/sh /opt/jdk-6u45-linux-x64-rpm.bin",
      		require => File["/opt/jdk-6u45-linux-x64-rpm.bin"],
      		creates => "/usr/java/jdk1.6.0_45/bin/java";
        }


    }

  }

}
