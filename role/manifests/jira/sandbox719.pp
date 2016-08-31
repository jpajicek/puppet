class role::jira::sandbox719 {

  class {"profile::jira":  
    servername   => 'jira.foo.com',
    product	 => 'jira-software',
    version      => '7.1.9',
    user         => 'jira',
    group        => 'jira',
    jvm_xms      => '2048m',
    jvm_xmx      => '4096m',
    dbuser       => 'user',
    dbpassword   => 'password',
    dbserver     => 'ip',
    dbname       => 'database',
    openmanage   => false,
    syslog       => false
  }

}

