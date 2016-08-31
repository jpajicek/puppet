class role::confluence::production589 {

  class {"profile::confluence":
    serveralias => 'confluence.foo.com',
    version     => '5.8.9',
    # build     => '5527', 		#Before upgrade
    build       => '5988',                      
    javahome    => '/usr/lib/jvm/java-8-oracle',
    dbuser      => 'user',
    dbpassword  => 'password',
    dbserver    => 'ip',
    dbname      => 'database',
  }

}
