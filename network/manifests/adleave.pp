define network::adleave (
$domain
) {

  if ($centrifydc_joined == $domain) {	
    exec { "adleave-$domain":
      path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      command => "adleave -f",
    }
  }
}
