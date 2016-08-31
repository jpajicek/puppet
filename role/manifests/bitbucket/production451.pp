#

class role::bitbucket::production451 {

  class {"profile::bitbucket": 
    servername   => 'bitbucket.foo.com',
    version      => '4.5.1',
    dbuser       => 'user',
    dbpassword   => 'password',
    dbserver     => 'ip',
    dbname       => 'database',
    jvm_xmx      => '8192m',
    jvm_xms      => '2048m',
  }

}
