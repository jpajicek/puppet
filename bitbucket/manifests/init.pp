# init.pp
#

class bitbucket (

  # Stash Settings
  $version      	= '3.0',
  $build		 = '',
  $product      	= 'bitbucket',
  $format       	= 'tar.gz',
  $installdir   	= '/data',
  $bitbucketdir        	= '/data/bitbucket',
  $homedir      	= '/data/bitbucket_home',
  $user         	= 'bitbucket',
  $group        	= 'bitbucket',
  $jvmlibary       	= 'CATALINA_HOME/lib/native:$BITBUCKET_HOME/lib/native',
  

  # Database Settings
  $db           	= 'mssql',
  $dbuser       	= 'bitbucketadm',
  $dbpassword   	= 'mypassword',
  $dbserver     	= 'localhost',
  $dbname       	= 'bitbucketdb',
  $dbport       	= '1433',
  $dbdriver     	= 'net.sourceforge.jtds.jdbc.Driver',
  $dbtype       	= 'mssql',
  $poolsize     	= '15',

  # JVM Settings
  $javahome		= '/usr/lib/jvm/java-7-oracle/',
  $jvm_xmx		= '4092m',
  $jvm_xms 		= '2048m',

  # Misc Settings
  $downloadURL          = "http://www.atlassian.com/software/stash/downloads/binary/",
  $feature_public_access = 'false', 

  #Tomcat Proxy settings
  $proxyName		= '',
  $proxyPort		= '443',

) {
 
  $bitbucketdir_real        = "${installdir}/atlassian-${product}-${version}" 

 
 if $db == 'mssql' {
    $dburl        	= "jdbc:jtds:sqlserver://${dbserver}:${dbport};databaseName=${dbname}"
  } else {
    $dburl        	= "jdbc:${db}://${dbserver}:${dbport}/${dbname}"
   }

  if $version =~ /^[2,3].[0,1].[0-9]$/ {
    $sharedir 		= "${homedir}"
  } else {
    $sharedir           = "${homedir}/shared"
  }

  include bitbucket::install
  include bitbucket::config
  #include bitbucket::service

  Class["bitbucket::install"] -> Class["bitbucket::config"]
  #Class["bitbucket::install"] -> Class["bitbucket::config"] -> Class["bitbucket::service"]
 

}

