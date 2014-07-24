# Server Plugins and dependencies


class nagios::server::plugins {

  include nagios::server::service

  package {
    "nagios-plugins": 			ensure 	=> installed; 
    "nagios-plugins-extra":  		ensure	=> installed;
    "nagios-snmp-plugins": 		ensure	=> installed;

  ## 3rd party plugins dependecies
    "libnet-mac-perl":			ensure  => installed;
    "libnet-snmp-perl":			ensure  => installed;
    "libnagios-plugin-perl":		ensure  => installed;
    "libnet-telnet-cisco-perl":		ensure  => installed;
    "libauthen-tacacsplus-perl":	ensure  => installed;	
    "python-pywbem":			ensure  => installed;
    "libxml-libxml-perl":		ensure  => installed;
    "perl-doc":				ensure  => installed;
    "libtest-mockobject-perl":		ensure  => installed;
    "libcrypt-ssleay-perl":		ensure  => installed;
    "libarchive-zip-perl":		ensure  => installed;
    "libclass-methodmaker-perl":	ensure  => installed;	
    "libdata-uuid-libuuid-perl":	ensure  => installed;
    "libdata-dump-perl":		ensure  => installed;	
    "libdata-dumper-concise-perl":	ensure  => installed;
    "libsoap-lite-perl":		ensure  => installed;
    "libnet-dns-perl":			ensure  => installed;
    "libssl-dev":			ensure  => installed;
    "python-paramiko":			ensure  => installed;
    "python-requests":			ensure  => installed;
    "python-setuptools":		ensure  => installed;
    "python-pynetsnmp":                 ensure  => installed;
    "libsnmp-python":                   ensure  => installed;
    "python-suds":			ensure  => installed;
    "snmp-mibs-downloader":		ensure  => installed;
    "snmptt":				ensure  => installed;
    # "snmpd":				ensure  => installed; Handled by snmp module			    
    "sendxmpp":				ensure  => installed;
  }

  file { "/usr/lib/nagios/plugins":
     ensure  => directory,
     source  => "puppet:///modules/nagios/server/plugins",
     recurse => true,
     owner   => "root",
     group   => "root",
     mode    => 755,
  }

  file { "/etc/nagios-plugins/config":
    ensure  => directory,
    source  => "puppet:///modules/nagios/server/plugins-config",
    recurse => true,
    owner   => "root",
    group   => "root",
    notify  => Class["nagios::server::service"],
  }

}
