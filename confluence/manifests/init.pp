# init.pp
#

class confluence (

  # Confluence Settings
  $version      	= '5.0',
  $build		= '',
  $product      	= 'confluence',
  $format       	= 'tar.gz',
  $installdir   	= '/data',
  $confluencedir	= '/data/confluence',
  $homedir      	= '/data/confluence_home',
  $user         	= 'confluence',
  $group        	= 'confluence',
  $webappcontextpath	= '/collaboration',

  # Database Settings
  $db           	= 'mssql',
  $dbuser       	= 'confluenceadm',
  $dbpassword   	= 'mypassword',
  $dbserver     	= 'localhost',
  $dbname       	= 'confluencedb',
  $dbport       	= '1433',
  $dbdriver     	= 'net.sourceforge.jtds.jdbc.Driver',
  $dbtype       	= 'mssql',
  $poolsize     	= '15',

  # JVM Settings
  $javahome		= '/usr/lib/jvm/java-6-sun',
  $jvm_xmx      	= '2048m',
  $jvm_xms 		= '1024m',

  # Misc Settings
  $downloadURL  = 'http://www.atlassian.com/software/confluence/downloads/binary/'

) {

  $confluencedir_real = "${installdir}/atlassian-${product}-${version}"
  
  if $db == 'mssql' {
    $dburl        = "jdbc:jtds:sqlserver://${dbserver}:${dbport}/${dbname}"
  } else {
    $dburl        = "jdbc:${db}://${dbserver}:${dbport}/${dbname}"
   }


  include confluence::install
  include confluence::config
  # include confluence::service

  Class["confluence::install"] -> Class["confluence::config"]
  # Class["confluence::install"] -> Class["confluence::config"] -> Class["confluence::service"]
 

}



   
