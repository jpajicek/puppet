# install sun-java 1.7
# prerequirement: AKQA APT Repository
# Usage: include java::oracle::jdk7
# Alternatively, if you need to stage installation - > class {"java::oracle::7": stage => essentials }

class java::oracle::jdk7 {

case $::operatingsystem {
    debian, ubuntu: {
        exec { "java-7-apt-update":
                path => "/bin:/usr/bin",
                command => "apt-get update",
                unless => "apt-cache search oracle-java7 | grep oracle-java7-installer",
        } ->

        file {"/var/cache/debconf/sun-java7.preseed":
                ensure => "present",
                source => "puppet:///modules/java/sun-java7.preseed",
        } ->

        package { "oracle-jdk7-installer":
                ensure => installed,
                responsefile => "/var/cache/debconf/sun-java7.preseed",
        } ->

        file { "/etc/alternatives/java":
                ensure => "/usr/lib/jvm/java-7-oracle/jre/bin/java",
        }

     }

  }

}

