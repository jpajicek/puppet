
class cq::55 (
$installation_type	= $cq::params::installation_type,
$license_url		= $cq::params::license_url,
$install_packages	= $cq::params::install_packages,
$sling_run_modes	= $cq::params::sling_run_modes

) inherits cq::params {

  $cq_port = $installation_type ? {
    "author"  => $port_author,
    "publish" => $port_publish,
    default   => "4502",
  }
  
  if $installation_type in [ author, publish ] {
        $type_real = $installation_type
      } else {
        fail('installation_type parameter must be author or publish')
  }

  file { [ "$data_dir", "$install_path", "$ssl_dir", "$install_path/$type_real" ]: 
    ensure	=> "directory",
    mode	=> 0755,
    before	=> [ Exec ["download_jar"], Exec["download_license"] ],
  }	
  
  exec {'download_jar':
    command 	=> "wget $jar_url",
    cwd		=> "$install_path/$type_real",
    creates	=> "$install_path/$type_real/$jar_name"
		   
  }

  exec {'download_license':
    command     => "wget $license_url",
    cwd         => "$install_path/$type_real",
    creates     => "$install_path/$type_real/license.properties"
  }

  exec {'unpack_CQ_jar':
    command     => "java -jar $jar_name -unpack",
    cwd         => "$install_path/$type_real",
    creates     => "$install_path/$type_real/crx-quickstart",
    require	=> Exec["download_jar"],
  }
 
  file {'install_package':
    path	=> "$install_path/$type_real/crx-quickstart/install",
    source	=> "puppet:///modules/cq/packages",
    mode	=> 0775,
    recurse	=> true,
    purge	=> true,
    require     => Exec["unpack_CQ_jar"],
  }

  file {"$install_path/$type_real/crx-quickstart/bin":
    ensure	=> directory,
    require     => Exec["unpack_CQ_jar"],
  }

  file {'start_script':
    path        => "$install_path/$type_real/crx-quickstart/bin/start",
    content 	=> template('cq/cq_5_5_start.erb'),
    mode        => 0777,
    require     => File["$install_path/$type_real/crx-quickstart/bin"],
    before	=> File["initd_script_$type_real"],
  }
  
  file {"initd_script_$type_real":
    path        => "/etc/init.d/cq-$type_real",
    content     => template('cq/cq_init_d_5_5.erb'),
    mode        => 0777,
  }
  
  file {'cqkeystore.keystore':
    path        => "$ssl_dir/cqkeystore.keystore",
    source      => "puppet:///modules/cq/ssl_keystore",
    mode        => 0775,
    require     => File[$ssl_dir],
  }

  service {"cq-$type_real":
    ensure 	=> running,
    hasrestart	=> false,
    hasstatus   => true,
    require 	=> [ File["initd_script_$type_real"], File["cqkeystore.keystore"] ],
  }

  
}

