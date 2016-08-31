# jira.pp

class profile::jira (
  $servername 	= '',
  $version     	= '',
  $product	= 'jira',
  $user        	= 'jira',
  $group       	= 'jira',
  $jvm_xms     	= '2048m',
  $jvm_xmx     	= '4096m',
  $dbuser      	= '',
  $dbpassword  	= '',
  $dbserver    	= '',
  $dbname      	= '',
  $openmanage	= false,
  $syslog	= false,
  $downloadFilename = '',
  $ssl_crt 	= '',
  $ssl_key	= '',
  $ssl_ca	= ''
) {

  include profile::base
  include java::oracle::jdk8

  include ulimit

  ulimit::rule {
    'jira-rule-1':
      ulimit_domain => 'jira',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '4096';

    'jira-rule-2':
      ulimit_domain => 'jira',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '8192';
  }

  if $syslog {

    class { 'rsyslog':
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
          host      => 'localhost',
          port      => '514',
          pattern   => 'local1.*',
          protocol  => 'tcp',
          format    => 'GRAYLOGRFC5424',
        },
      ]
    }

    rsyslog::imfile { 'atlassian-jira.log':
      file_name     => '/data/jira_home/log/atlassian-jira.log ',
      file_tag      => $servername,
      file_facility => 'local1',
    }

    rsyslog::imfile { 'atlassian-jira-security.log':
      file_name     => '/data/jira_home/log/atlassian-jira-security.log ',
      file_tag      => $servername,
      file_facility => 'local1',
    }

    rsyslog::imfile { 'apache-error.log':
      file_name     => '/var/log/apache2/jira-SSL_error_ssl.log',
      file_tag      => "apache.error.log.$servername",
      file_facility => 'local1',
    }

    rsyslog::imfile { 'apache-access.log':
      file_name     => '/var/log/apache2/jira-SSL_access_ssl.log',
      file_tag      => "apache.access.log.$servername",
      file_facility => 'local1',
    }
  
  }
 
  class { '::jira':
   version     		=> $version,
   product		=> $product,
   downloadFilename 	=> $downloadFilename,
   user        		=> $user,
   group       		=> $group,
   jvm_xms     		=> $jvm_xms,
   jvm_xmx     		=> $jvm_xmx,
   dbuser      		=> $dbuser,
   dbpassword  		=> $dbpassword,
   dbserver    		=> $dbserver,
   dbname      		=> $dbname,
   proxyname   		=> $servername,
  }

  include jira::migrate
  
  class {'apache': default_vhost => false,}

   class { 'apache::mod::ssl': }
   class { 'apache::mod::rewrite': }
   class { 'apache::mod::proxy_http': }
   class { 'apache::mod::headers': }
   class { 'apache::mod::status': }

  apache::vhost { 'jira':
      port    	      => '80',
      servername      => $servername,
      docroot 	      => '/var/www',
      redirect_status => 'permanent',
      redirect_dest   => "https://$servername/",
  }

  apache::vhost { 'jira-ssl':
      servername      => $servername,
      custom_fragment => ' ProxyTimeout 1800',
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
      proxy_pass       => [ 
	{ 'path' => '/robots.txt', 'url' => "!" },
	{ 'path' => '/error/', 'url' => "!" },
	{ 'path' => '/', 'url' => "http://$servername:8080/" }, ],
  }

  apache::vhost { 'apache-status':
      port            => '3000',
      servername      => $servername,
      docroot         => '/var/www',
      custom_fragment => '
        <Location /server-status>
          SetHandler server-status
          Order allow,deny
          Allow from all
        </Location>',
   }

  apache::vhost { 'jira-ssl-maintenance':
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

  apache_error_html { 'error':}
  ssl::cert::files { 'jira': before => Apache::Vhost['jira-ssl']}  
  
  file {"/var/www/robots.txt":
    content => "User-agent: * \nDisallow: /",
    mode    => 666,
    owner   => www-data,
    require => Class['apache'],
  }

}


