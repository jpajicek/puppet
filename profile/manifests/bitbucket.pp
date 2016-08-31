class profile::bitbucket (
  $servername 	= '',
  $version     	= '',
  $dbuser      	= '',
  $dbpassword  	= '',
  $dbserver    	= '',
  $dbname      	= '',
  $jvm_xmx     	= '',
  $jvm_xms     	= '',
  $syslog	= false,
  $logserver    = '',
  $ssl_crt 	= '',
  $ssl_key	= '',
  $ssl_ca	= ''
) {

  include profile::base
  include java::oracle::jdk8
  include git

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
          host      => $logserver,
          port      => '514',
          pattern   => 'local1.*',
          protocol  => 'tcp',
          format    => 'GRAYLOGRFC5424',
        },
      ]
    }

    rsyslog::imfile { 'atlassian-bitbucket.log':
      file_name     => '/data/bitbucket_home/log/atlassian-bitbucket.log ',
      file_tag      => $servername,
      file_facility => 'local1',
    }

    rsyslog::imfile { 'atlassian-bitbucket-access.log':
      file_name     => '/data/bitbucket_home/log/atlassian-bitbucket-access.log ',
      file_tag      => $servername,
      file_facility => 'local1',
    }

    rsyslog::imfile { 'atlassian-bitbucket-audit.log':
      file_name     => '/data/bitbucket_home/log/audit/atlassian-bitbucket-audit.log ',
      file_tag      => $servername,
      file_facility => 'local1',
    }

    rsyslog::imfile { 'apache-error.log':
      file_name     => '/var/log/apache2/bitbucket-ssl_error_ssl.log',
      file_tag      => "apache.error.log.$servername",
      file_facility => 'local1',
    }

    rsyslog::imfile { 'apache-access.log':
      file_name     => '/var/log/apache2/bitbucket-ssl_access_ssl.log',
      file_tag      => "apache.access.log.$servername",
      file_facility => 'local1',
    }

  }

 class { '::bitbucket':
   version     => $version,
 # build       => '4731',
   dbuser      => $dbuser,
   dbpassword  => $dbpassword,
   dbserver    => $dbserver,
   dbname      => $dbname,
   jvm_xmx     => $jvm_xmx,
   jvm_xms     => $jvm_xms,
   proxyName   => $servername,
}

class {'apache': default_vhost => false,}

   class { 'apache::mod::ssl': }
   class { 'apache::mod::rewrite': }
   class { 'apache::mod::proxy_http': }
   class { 'apache::mod::headers': }

  apache::vhost { 'bitbucket':
      port            => '80',
      servername      => $servername,
      docroot         => '/var/www',
      redirect_status => 'permanent',
      redirect_dest   => "https://$servername/",
  }

  apache::vhost { 'bitbucket-ssl':
      servername      => $servername,
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
        { 'path' => '/', 'url' => "http://$servername:7990/" }, ],

   }

  apache::vhost { 'bitbucket-ssl-maintenance':
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

  class {"bitbucket::migrate":}

  apache_error_html { 'error':}
  ssl::cert::files { 'stash': before => Apache::Vhost['bitbucket-ssl']}

  file {"/var/www/robots.txt":
    content => "User-agent: * \nDisallow: /",
    mode    => 666,
    owner   => www-data,
    require => Class['apache'],
  }


}
