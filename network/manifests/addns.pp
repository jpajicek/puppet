
define network::addns (
$domain,
$svc_user,
$svc_pass,
$dns_server
) {

  exec { "addns-$domain":
    path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    command => "addns -u $svc_user -p $svc_pass -U -d $domain -s $dns_server@$domain -n $hostname -i $ipaddress ",
    onlyif  => "nslookup $hostname | grep SERVFAIL",
  }

}
