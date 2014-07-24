Puppet module for Altassian JIRA

This module is a fork of the original puppet-jira module by Bryce Johnson https://github.com/brycejohnson/puppet-jira

# Requirements

   Java Sun 

    class {"apt::debian::akqa": stage => prep }
    class {"apt::debian::puppetlabs": stage => prep } 
    class {"essential::debian": stage => essentials }
    class {"java::sun": stage => essentials }

# Installation 


Puppet will automatically download the jira tar.gz from Atlassian and extract it into /usr/local/atlassian-jira-$version
and then create a symlink to /usr/local/jira

An example how to use this module:

    class { 'jira':
       version     => '6.1.3',
       user        => 'jira1',
       group       => 'jira1',
       dbuser      => 'jiradb_user',
       dbpassword  => 'Closed00r',
       dbserver    => 'ldnwpatdb11',
       dbname      => 'jira_sandbox05_test',
    }


# Module default parameters

Jira Settings

    $version      = '6.0'
    $product      = 'jira'
    $format       = 'tar.gz'
    $installdir   = '/usr/local,
    $jiradir      = '/usr/local/jira'
    $homedir      = '/usr/local/jira_home'
    $user         = 'jira'
    $group        = 'jira'

 Database Settings
 
    $db           = 'mssql',
    $dbuser       = 'jiraadm',
    $dbpassword   = 'mypassword',
    $dbserver     = 'localhost',
    $dbname       = 'jira',
    $dbport       = '1433',
    $dbdriver     = 'net.sourceforge.jtds.jdbc.Driver',
    $dbtype       = 'mssql',
    $poolsize     = '15',

 JVM Settings
 
    $javahome     = '',
    $jvm_xmx      = '2048m',
    $jvm_optional = '',

 Misc Settings

    $downloadURL  = 'http://www.atlassian.com/software/jira/downloads/binary/'


# Optional #


These steps are completely optional, but relevent to our current setup


# Preroute Rules


    iptables::template {"jira-preroute":}


Creates iptables rules and auto-load them on boot 

  * -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
  * -A PREROUTING -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 8443



# Migration from existing server
  

This will rsync plugins, data, and caches dirs from the remote server.
 
If the remote server you are migrating from wasn't deployed by puppet a few additional step are needed to make this work

 Remote jira user with valid shell and ssh authorised key in place.
 Read permissions for jira user to ${jira::homedir} on the remote machine.
 Jira service  has to be stopped on the remote server during migration.


Example how to use:

    class {"jira::migrate":
      source      => "ldnxpjira01",   # remote jira box
      remote_user => "jira1",         # remote jira user with authorized keys in ${jira::homedir}./ssh
      plugins     => "true",
      data        => "true",
      caches      => "true",
    }


# Sandbox Manifest Example 


    node /^ldnxvsand20.*$/ {

      class {"apt::debian::akqa": stage => prep }
      class {"apt::debian::puppetlabs": stage => prep }
      class {"essential::debian": stage => essentials }
      class {"java::sun": stage => essentials }

      class { 'jira':
        version     => '6.1.3',
        user        => 'jira1',
        group       => 'jira1',
        dbuser      => 'jiradb_user',
        dbpassword  => 'Closed00r',
        dbserver    => 'ldnwpatdb11',
        dbname      => 'jira_sandbox05_test',
      }

      iptables::template {"jira-preroute":}

      class {"jira::migrate":
        source      => "ldnxpjira01",
        remote_user => "jira1",
        plugins     => "true",
        data        => "true",
        caches      => "true",
      }
    )
