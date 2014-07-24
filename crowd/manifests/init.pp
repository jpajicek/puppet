# init.pp
#

class crowd (

  # Crowd Settings
  $version      	= '2.7.2',
  $build		= '',
  $serverid		= '',
  $license		= '',
  $app_name		= '',
  $app_password		= '',
  $product      	= 'crowd',
  $format       	= 'tar.gz',
  $installdir   	= '/data',
  $crowddir        	= '/data/crowd',
  $homedir      	= '/data/crowd_home',
  $user         	= 'crowd',
  $group        	= 'crowd',
  

  # Database Settings
  $db           	= 'mssql',
  $dbuser       	= 'crowdadm',
  $dbpassword   	= 'mypassword',
  $dbserver     	= 'localhost',
  $dbname       	= 'crowddb',
  $dbport       	= '1433',
  $dbdriver     	= 'net.sourceforge.jtds.jdbc.Driver',
  $dbtype       	= 'mssql',
  $poolsize     	= '15',

  # JVM Settings
  $javahome		= '/usr/lib/jvm/java-7-oracle/',
  $jvm_xmx		= '1024m',
  $jvm_xms 		= '128m',
  $jvm_MaxPermSize	= '256m',

  # Misc Settings
  $downloadURL 		= 'http://www.atlassian.com/software/crowd/downloads/binary/',

) {

 $crowddir_real        = "${installdir}/atlassian-${product}-${version}" 

 
 if $db == 'mssql' {
    $dburl        	= "jdbc:jtds:sqlserver://${dbserver}:${dbport}/${dbname}"
  } else {
    $dburl        	= "jdbc:${db}://${dbserver}:${dbport}/${dbname}"
   }


  include crowd::install
  include crowd::config

  Class["crowd::install"] -> Class["crowd::config"]
 
}
