
# Usage example: confluence::patch {"webwork-2.1.5-atlassian-3.jar": version => '5.5.6', directory => '/confluence/WEB-INF/lib', discard => 'webwork-2.1.5-atlassian-2.jar' }

# $directory: relative patch to 

define confluence::patch (
  $ensure 		= 'file',
  $version 		= '',
  $installdir 		= '/data',
  $directory		= '',
  $discard		= undef,
) {

   $confluencedir_real = "${installdir}/atlassian-confluence-${version}"

  File {
    owner => $confluence::user,
    group => $confluence::group,
  }

  if $discard {
    exec { "backup-${discard}":
      cwd	=> "${confluencedir_real}${directory}",
      command 	=> "mv ${discard} ${discard}.discarded",
      onlyif 	=> "test -f $discard",
      before    => File["${confluencedir_real}${directory}/${name}"],
    } 
  }

  file {"${confluencedir_real}${directory}/${name}":
    ensure  => $ensure,
    backup  => true,
    source  => "puppet:///modules/confluence/patches/${name}",
    require => Class["confluence::install"],
  }

}


