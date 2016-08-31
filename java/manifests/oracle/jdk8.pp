# install sun-java 8
# prerequirement: AKQA APT Repository
# Usage: include java::oracle::jdk8
# Alternatively, if you need to stage installation - > class {"java::oracle::8": stage => essentials }

class java::oracle::jdk8 {

case $::operatingsystem {
    debian, ubuntu: {
        exec { "java-8-apt-update":
                path => "/bin:/usr/bin",
                command => "apt-get update",
                unless => "apt-cache search oracle-java8 | grep oracle-java8-installer",
        } ->

        file {"/var/cache/debconf/sun-java8.preseed":
                ensure => "present",
                source => "puppet:///modules/java/sun-java8.preseed",
        } ->

        package { "oracle-java8-installer":
                ensure => installed,
                responsefile => "/var/cache/debconf/sun-java8.preseed",
        } ->

        file { "/etc/alternatives/java":
                ensure => "/usr/lib/jvm/java-8-oracle/jre/bin/java",
        }

     }

  }

}

