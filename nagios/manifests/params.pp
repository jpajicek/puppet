
class nagios::params {

$nagios_tag	  	= "default"
$user_home		= "/var/lib/nagios"
$confd_hosts            = "/etc/nagios3/conf.d/hosts"
$confd_hostgroups       = "/etc/nagios3/conf.d/hostgroups"
$confd_servicegroups    = "/etc/nagios3/conf.d/servicegroups"
$confd_services         = "/etc/nagios3/conf.d/services"
$confd_dependecies	= "/etc/nagios3/conf.d/dependencies"
$confd_gui         	= "/etc/nagios3/gui"
$plugin_configdir	= "/etc/nagios-plugins/config"
# Misc

$livestatus		= true
$thruk			= false
$thruk_template		= 'thruk-default'
$pnp			= false
$adagios		= false
$gearman_mod		= true

}
