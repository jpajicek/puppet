# init.pp
# This module is a fork of the original puppet-jira module by Bryce Johnson https://github.com/brycejohnson/puppet-jira
#

class jira (

  # Jira Settings
  $version      = '6.0',
  $product      = 'jira',
  $format       = 'tar.gz',
  $installdir   = '/data',
  $jiradir	= '/data/jira',
  $homedir      = '/data/jira_home',
  $user         = 'jira',
  $group        = 'jira',
  $proxyname	= '',
  $proxyport    = '443',

  # Database Settings
  $db           = 'mssql',
  $dbuser       = 'jiraadm',
  $dbpassword   = 'mypassword',
  $dbserver     = 'localhost',
  $dbname       = 'jira',
  $dbport       = '1433',
  $dbdriver     = 'net.sourceforge.jtds.jdbc.Driver',
  $dbtype       = 'mssql',
  $poolsize     = '25',

  # JVM Settings
  $javahome	= '',
  $jvm_xms	= '256m',
  $jvm_xmx      = '2048m',
  $jvm_optional = '',

  # Misc Settings
  $downloadFilename = '',
  $downloadURL  = 'http://www.atlassian.com/software/jira/downloads/binary/'

) {

  $jiradir_real = "${installdir}/atlassian-${product}-${version}-standalone"
  
  if $db == 'mssql' {
    $dburl        = "jdbc:jtds:sqlserver://${dbserver}:${dbport}/${dbname}"
  } else {
    $dburl        = "jdbc:${db}://${dbserver}:${dbport}/${dbname}"
   }


  include jira::install
  include jira::config
  # include jira::service

  Class["jira::install"] -> Class["jira::config"]
  # Class["jira::install"] -> Class["jira::config"] -> Class["jira::service"]
 

}



   
