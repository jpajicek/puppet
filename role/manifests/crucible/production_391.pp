class role::crucible::production_391 {

  class {"profile::crucible":
    version             => '3.9.1',
    servername          => 'crucible.foo.com',
    dbuser              => 'user',
    dbpassword          => 'password',
    dbserver            => 'ip',
    dbname              => 'database',
  }

}
