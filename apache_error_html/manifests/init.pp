define apache_error_html (
  $ensure  = 'directory',
  $wwwroot = '/var/www',
  $owner   = 'root',
  $mode    = '555',
) {

  file { "${wwwroot}/${name}":
    ensure	=> $ensure,
    recurse	=> true,
    source	=> "puppet:///modules/apache_error_html/${name}",
    owner	=> $owner,
    mode	=> $mode,
    require     => Class["apache"],
  }

}
