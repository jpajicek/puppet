
define network::adjoin (
$domain,
$svc_user,
$svc_pass,
$ou,
) {
  
  exec { "adjoin-$domain":
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    command => "adjoin -w $domain -c $ou -u $svc_user@$domain -p $svc_pass",
    onlyif  => "adinfo | grep 'Not joined to any domain'",
  }

}
