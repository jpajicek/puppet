class java::openjdk {

        package { "openjdk-6-jdk":        ensure => installed;
                  "openjdk-6-jre":        ensure => installed;
        }

}

