 
class confluence::config {

  require confluence

  File {
    owner => $confluence::user,
    group => $confluence::group,
  }

  file { "${confluence::confluencedir_real}/bin/user.sh":
    content => template('confluence/user.sh.erb'),
    mode    => '0755',
  } ->

  file { "${confluence::confluencedir_real}/bin/setenv.sh":
    content => template('confluence/setenv.sh.erb'),
    mode    => '0755',
#    notify  => Class['confluence::service'],
  } ->

  file { "${confluence::confluencedir_real}/confluence/WEB-INF/classes/confluence-init.properties":
    content => template('confluence/confluence-init.properties.erb'),
    mode    => '0755',
  } ->

  file { "${confluence::homedir}/confluence.cfg.xml":
    content => template("confluence/dbconfig.${confluence::db}.xml.erb"),
    mode    => '0600',
  } ->

  file { "${confluence::confluencedir_real}/conf/server.xml":
    content => template('confluence/server.xml.erb'),
    mode    => '0755',
  } ->


  ## Logging properties
 
  file_line { "log4j.category.com.atlassian.confluence.util.AccessLogFilter":
    path  => "${confluence::confluencedir_real}/confluence/WEB-INF/classes/log4j.properties",
    line  => "log4j.category.com.atlassian.confluence.util.AccessLogFilter=INFO",
    match => "log4j.category.com.atlassian.confluence.util.AccessLogFilter=INFO",
  } 

  file_line { "web.xml.filter-mapping":
    path  => "${confluence::confluencedir_real}/confluence/WEB-INF/web.xml",
    line  => "<!-- uncomment this mapping in order to log page views to the access log, see log4j.properties also --><filter-mapping><filter-name>AccessLogFilter</filter-name><url-pattern>/admin/*</url-pattern><url-pattern>/plugins/*</url-pattern></filter-mapping>",
    match => "<!-- uncomment this mapping in order to log page views to the access log, see log4j.properties also -->",
  }

}
