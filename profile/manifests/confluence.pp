class profile::confluence (
  $serveralias  = '',
  $version	= '',
  $build	= '',
  $jvm_xmx	= '4096m',
  $jvm_xms	= '4096m',
  $javahome	= '/usr/lib/jvm/java-8-oracle',
  $dbuser	= '',
  $dbpassword	= '',
  $dbserver	= '',
  $dbname	= '',
  $syslog	= false,
  $ssl_crt 	= '',
  $ssl_key	= '',
  $ssl_ca	= ''
) {

  include profile::base
  include java::oracle::jdk8
  package {"graphviz": ensure => present}
  nagios::nrpe::plugin {"check_jmx":}
  nagios::nrpe::plugin {"jmxquery.jar":}

 if $syslog {

  class { '::rsyslog':
    preserve_fqdn => true,
    default_template => 'RSYSLOG_TraditionalFileFormat',
  }

  class { 'rsyslog::client':
    log_templates => [
      {
        name      => 'GRAYLOGRFC5424',
        template  => '<%PRI%>%PROTOCOL-VERSION% %TIMESTAMP:::date-rfc3339% %HOSTNAME% %APP-NAME% %PROCID% %MSGID% %STRUCTURED-DATA% %msg%\n',
      },
    ],
    remote_servers => [
      {
        host      => '127.0.0.1',
        port      => '514',
        pattern   => 'local1.*',
        protocol  => 'tcp',
        format    => 'GRAYLOGRFC5424',
      },
    ]
  }

  rsyslog::imfile { 'atlassian-confluence.log':
    file_name     => '/data/confluence_home/logs/atlassian-confluence.log ',
    file_tag      => $serveralias,
    file_facility => 'local1',
  }

 
  rsyslog::imfile { 'apache-access-log':
    file_name     => '/var/log/apache2/confluence-SSL_access_ssl.log ',
    file_tag      => "apache.access.log.$serveralias",
    file_facility => 'local1',
  }
 

  rsyslog::imfile { 'apache-error.log':
    file_name     => '/var/log/apache2/confluence-SSL_error_ssl.log',
    file_tag      => "apache.error.log.$serveralias",
    file_facility => 'local1',
  }

 }

# When upgrading confluence, Bump up the build number after first confluence start

 class { '::confluence':
   version     => $version,
   proxyname   => $serveralias,
   build       => $build,
   jvm_xmx     => $jvm_xmx,
   jvm_xms     => $jvm_xms,
   javahome    => $javahome,
   user        => 'confluence',
   group       => 'confluence',
   dbuser      => $dbuser,
   dbpassword  => $dbpassword,
   dbserver    => $dbserver,
   dbname      => $dbname,
 }

 class {"confluence::migrate":}

 class {'apache': default_vhost => false,}

 $apache_fragment = '
   ProxyTimeout 1800
   # GZIP COMPRESSION
   DeflateBufferSize 8192
   DeflateCompressionLevel 9
   DeflateMemLevel 9
   DeflateWindowSize 15
   KeepAlive On
   SetEnvIf User-Agent ".*MSIE.*" \
     nokeepalive ssl-unclean-shutdown \
     downgrade-1.0 force-response-1.0
   BrowserMatch "MSIE [1-5]" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
   BrowserMatch "MSIE [6-9]" ssl-unclean-shutdown
   # DISK CACHE
   CacheEnable disk /s
   CacheRoot /var/cache/apache2/mod_cache_disk
   CacheDirLevels 5
   CacheDirLength 3
   CacheIgnoreHeaders Set-Cookie
   CacheMaxFileSize 1000000
   CacheMinFileSize 1
   CacheLastModifiedFactor 0.1
   CacheDefaultExpire 3600
   CacheMaxExpire 86400
 '

   class { 'apache::mod::ssl': }
   class { 'apache::mod::rewrite': }
   class { 'apache::mod::proxy_http': }
   class { 'apache::mod::headers': }
   class { 'apache::mod::status': }
   class { 'apache::mod::cache': }
   class { 'apache::mod::disk_cache': }

  apache::vhost { 'confluence':
      port            => '80',
      servername      => $serveralias,
      docroot         => '/var/www',
      redirect_status => 'permanent',
      redirect_dest   => "https://$serveralias/",
  }

  apache::vhost { 'confluence-SSL':
      servername      => $serveralias,
      port            => '443',
      docroot         => '/var/www',
      ssl             => true,
      ssl_cert        => "$ssl_crt",
      ssl_key         => "$ssl_key",
      ssl_chain       => "$ssl_ca",
      error_documents => [
        { 'error_code' => '500', 'document' => '/error/500.html' },
        { 'error_code' => '503', 'document' => '/error/503.html' },
      ],
      proxy_preserve_host => true,
      proxy_pass      => [
	{ 'path' => '/robots.txt', 'url' => "!" }, 
        { 'path' => '/error/', 'url' => "!" },
        { 'path' => '/', 'url' => "http://$serveralias:8090/" }, ],
      # rewrite_cond => ['^/collaboration(.*)'],
      rewrite_rule => "^/collaboration/?(.*) https://$serveralias/\$1",
      custom_fragment => $apache_fragment
  }

  apache::vhost { 'confluence-status':
      port            => '3000',
      servername      => $serveralias,
      docroot         => '/var/www',
      custom_fragment => '
        <Location /server-status>
          SetHandler server-status
          Order allow,deny
          Allow from all
        </Location>',
      }

  apache::vhost { 'Confluence-SSL-maintenance':
      port            => '8888',
      servername      => $servername,
      docroot         => '/var/www',
      directoryindex  => '/error/maintenance.html',
      ssl             => true,
      ssl_cert        => "$ssl_crt",
      ssl_key         => "$ssl_key",
      ssl_chain       => "$ssl_ca",
      rewrites => [ {
      rewrite_cond    => ['%{REQUEST_URI} !/error'],
      rewrite_rule    => ['!/(error|$) / [R=301,L]'],
      } ],
  }

  ssl::cert::files { 'confluence': before => Apache::Vhost['confluence-SSL']}
  apache_error_html { 'error':}

  file {"/var/www/robots.txt":
    content => "User-agent: * \nDisallow: /",
    mode    => 666,
    owner   => www-data,
    require => Class['apache'],
  }

  ## -------------------------------
  ## Patch confluence 5.5.6

  # confluence::patch {"webwork-2.1.5-atlassian-3.jar": version => '5.5.6', directory => '/confluence/WEB-INF/lib', discard => 'webwork-2.1.5-atlassian-2.jar'}

}
