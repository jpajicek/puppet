#!/usr/bin/perl -w
#
# ============================== SUMMARY =====================================
#
# Program : check_dell_openmanage.pl
# Version : 1.3
# Date    : March 31 2010
# Author  : Jason Ellison - infotek@gmail.com
# Summary : This is a nagios plugin that checks the status of objects
#           monitored by Dell OpenManage on Dell PowerEdge servers via SNMP
#
# Licence : GPL - summary below, full text at http://www.fsf.org/licenses/gpl.txt
#
# =========================== PROGRAM LICENSE =================================
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# ===================== INFORMATION ABOUT THIS PLUGIN =========================
#
# This plugin checks the status of objects monitored by OpenManage via SNMP
# and returns OK, WARNING, CRITICAL or UNKNOWN.  If a failure occurs it will
# describe the subsystem that failed and the failure code.
#
# This program is written and maintained by:
#   Jason Ellison - infotek(at)gmail.com
#
# It is based on check_snmp_temperature.pl plugin by:
#   William Leibzon - william(at)leibzon.org
#
# Using information from
# Dell OpenManage Server Administrator Version 5.4 SNMP Reference Guide
# http://support.dell.com/support/edocs/software/svradmin/
#
# System Types 
#
# "dellom" monitors the following OID's:
#  systemStateChassisStatus .1.3.6.1.4.1.674.10892.1.200.10.1.4.1
#  systemStatePowerSupplyStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.9.1
#  systemStateVoltageStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.12.1
#  systemStateCoolingDeviceStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.21.1
#  systemStateTemperatureStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.24.1
#  systemStateMemoryDeviceStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.27.1
#  systemStateChassisIntrusionStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.30.1
#  systemStateEventLogStatus .1.3.6.1.4.1.674.10892.1.200.10.1.41.1
#
# "dellom_storage" test all of the OID's "dellom" tests plus the storage OID
#  systemStateChassisStatus .1.3.6.1.4.1.674.10892.1.200.10.1.4.1
#  systemStatePowerSupplyStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.9.1
#  systemStateVoltageStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.12.1
#  systemStateCoolingDeviceStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.21.1
#  systemStateTemperatureStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.24.1
#  systemStateMemoryDeviceStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.27.1
#  systemStateChassisIntrusionStatusCombined .1.3.6.1.4.1.674.10892.1.200.10.1.30.1
#  systemStateEventLogStatus .1.3.6.1.4.1.674.10892.1.200.10.1.41.1
#  StorageManagement-MIB::agentGlobalSystemStatus .1.3.6.1.4.1.674.10893.1.20.110.13.0
#
# "global" monitors
#  GlobalSystemStatus .1.3.6.1.4.1.674.10892.1.200.10.1.2.1
#
# "chassis" monitors
#  ChassisStatus .1.3.6.1.4.1.674.10892.1.200.10.1.4.1
#
# "custom" is meant to be customised by advanced users
#
# ============================= SETUP NOTES ====================================
#
# Copy this file to your Nagios installation folder in "libexec/". Rename
# to "check_dell_openmanage.pl".
#
# You must have Dell OpenManage installed on the server that you want to
# monitor. You must have enabled SNMP on the server and allow SNMP queries. 
# On the server that will be running the plugin you must have the perl
# "Net::SNMP" module installed.
#
# perl -MCPAN -e shell
# cpan> install Net::SNMP
#
# For SNMPv3 support make sure you have the following modules installed:
#   Crypt::DES, Digest::MD5, Digest::SHA1, and Digest::HMAC
#
# Check Dell OpenManage on the local host for alert thresholds like min/max
# fan speeds and temperatures...
#
# To test using SNMPv1 use the following syntax:
#
# ./check_dell_openmanage.pl -v -H <host> -C <snmp_community> -T <type>
#
# Where <type> is "test", "dellom", "dellom_storage", "blade", "global", "chassis" or "custom"
#
# ========================= SETUP EXAMPLES ==================================
#
# define command{
#       command_name    check_dell_open_manage
#       command_line    $USER1$/check_dell_openmanage.pl -H $HOSTADDRESS$ -C $ARG1$ -T $ARG2$
#       }
#
# define service{
#       use                     generic-service
#       host_name               DELL-SERVER-00
#       service_description     Dell OpenManage Status
#       check_command           check_dell_open_manage!public!dellom
#       normal_check_interval   3
#       retry_check_interval    1
#       }
#
# define service{
#       use                     generic-service
#       host_name               DELL-SERVER-01
#       service_description     Dell OpenManage Status plus Storage
#       check_command           check_dell_open_manage!public!dellom_storage
#       normal_check_interval   3
#       retry_check_interval    1
#       }
#
# =================================== TODO ===================================
#
# Fix bugs and make more user friendly.
#
# ================================ REVISION ==================================
#
#
# ver 1.3
#
# If non-numeric codes are returned just add the text to the statusinfo 
# This was done to allow adding machine information Dell Model Number and Service Tag to output.
#
# ver 1.2
#
# Major rewrite.  Simplified the way new systems are defined.  Added system
# type "test" which can be used to easly generate new system definitions.
#
# ver 1.1
# formating of text output
# add blade system type... blades apparently do not support 
# systemStatePowerSupplyStatusCombined, systemStateCoolingDeviceStatusCombined
# or systemStateChassisIntrusionStatusCombined

#
# ver 1.0
#
# while in verbose mode report which OID failed in a more readable manner.
# add "global", "chassis", and "custom" type.
#
# ver 0.9
# change added type dellom_storage as this is more accurate. This plugin works
# with all PowerEdge servers it has been tested with. left pe2950 in for compat
# remove min max int options from help text as they are no longer relevant
#
# ver 0.8
#
# removed ucdavis definition.  Added note about SNMPv3 dependencies
# check that perl environment has "Net::SNMP" if not found complain.
# missing "Net::SNMP" is the most common issue users report.
#
# ver 0.7
#
# removed ucdavis definition.  Added note about SNMPv3 dependencies
#
# ver 0.6
#
# + Added StorageManagement GlobalSystemStatus
# StorageManagement-MIB::agentGlobalSystemStatus
# .1.3.6.1.4.1.674.10893.1.20.110.13.0
#
# ver 0.5
#
# + Cleaned up verbose output for debugging
#
# ver 0.4
#
# + Fixed major flaw in logic that cause errors to not be reported.
#
# + Added to the system_types error warning and unkown variables like seen on
# http://www.mail-archive.com/intermapper-talk@list.dartware.com/msg02687.html
# below section: "This section performs value to text conversions"
#
# ========================== START OF PROGRAM CODE ============================

use strict;

use Getopt::Long;
my %system_types = (
	"dellom" => [
		'systemStateChassisStatus',
		'systemStatePowerSupplyStatusCombined',
		'systemStateVoltageStatusCombined',
		'systemStateCoolingDeviceStatusCombined',
		'systemStateTemperatureStatusCombined',
		'systemStateMemoryDeviceStatusCombined',
		'systemStateChassisIntrusionStatusCombined',
		'systemStateEventLogStatus',
	],
	"dellom_storage" => [
		'systemStateChassisStatus',
		'systemStatePowerSupplyStatusCombined',
		'systemStateVoltageStatusCombined',
		'systemStateCoolingDeviceStatusCombined',
		'systemStateTemperatureStatusCombined',
		'systemStateMemoryDeviceStatusCombined',
		'systemStateChassisIntrusionStatusCombined',
		'systemStateEventLogStatus',
		'StorageManagementGlobalSystemStatus'
	],
	"blade" => [
		'systemStateChassisStatus',
		'systemStateVoltageStatusCombined',
		'systemStateTemperatureStatusCombined',
		'systemStateMemoryDeviceStatusCombined',
		'systemStateEventLogStatus',
		'StorageManagementGlobalSystemStatus'
	],
	"global" => [
		'systemStateGlobalSystemStatus'
	],
	"chassis" => [
		'systemStateChassisStatus'
	],
	"custom" => [
		'systemStateChassisStatus',
		'systemStatePowerSupplyStatusCombined',
		'systemStateCoolingDeviceStatusCombined',
		'systemStateTemperatureStatusCombined',
		'systemStateChassisIntrusionStatusCombined',
		'systemStateEventLogStatus',
		'chassisModelName',
		'chassisServiceTagName'
	]
);

my %dell_oids = (
  'systemStateGlobalSystemStatus'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.2.1',
  'systemStateChassisStatus'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.4.1',
  'systemStatePowerSupplyStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.9.1',
  'systemStateVoltageStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.12.1',
  'systemStateAmperageStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.15.1',
  'systemStateCoolingDeviceStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.21.1',
  'systemStateTemperatureStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.24.1',
  'systemStateMemoryDeviceStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.27.1',
  'systemStateChassisIntrusionStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.30.1',
  'systemStateACPowerCordStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.36.1',
  'systemStateEventLogStatus'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.41.1',
  'systemStatePowerUnitStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.42.1',
  'systemStateCoolingUnitStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.44.1',
  'systemStateACPowerSwitchStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.46.1',
  'systemStateProcessorDeviceStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.50.1',
  'systemStateBatteryStatusCombined'=>'.1.3.6.1.4.1.674.10892.1.200.10.1.52.1',
  'StorageManagementGlobalSystemStatus'=>'.1.3.6.1.4.1.674.10893.1.20.110.13.0',
  'chassisManufacturerName'=>'1.3.6.1.4.1.674.10892.1.300.10.1.8.1',
  'chassisModelName'=>'1.3.6.1.4.1.674.10892.1.300.10.1.9.1',
  'chassisServiceTagName'=>'1.3.6.1.4.1.674.10892.1.300.10.1.11.1',
  'chassisSystemName'=>'1.3.6.1.4.1.674.10892.1.300.10.1.15.1',
  'operatingSystemOperatingSystemName'=>'1.3.6.1.4.1.674.10892.1.400.10.1.6.1',
  'operatingSystemOperatingSystemVersionName'=>'1.3.6.1.4.1.674.10892.1.400.10.1.7.1'
);

my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);
my @DELLSTATUS=('DellStatus', 'other', 'unknown', 'ok', 'nonCritical', 'critical', 'nonRecoverable');
my $Version='1.3';
my $o_host=     undef;          # hostname
my $o_community= undef;         # community
my $o_port=     161;            # SNMP port
my $o_help=     undef;          # help option
my $o_verb=     undef;          # verbose mode
my $o_version=  undef;          # version info option
my $o_warn=     undef;          # warning level option
my @o_warnL=    ();             # array for above list
my $o_crit=     undef;          # Critical level option
my @o_critL=    ();             # array for above list
my $o_timeout=  5;              # Default 5s Timeout
my $o_version2= undef;          # use snmp v2c
# SNMPv3 specific
my $o_login=    undef;          # Login for snmpv3
my $o_passwd=   undef;          # Pass for snmpv3
my $o_attr=     undef;          # What attribute(s) to check (specify more then one separated by '.')
my @o_attrL=    ();             # array for above list
my $o_unkdef=   2;              # Default value to report for unknown attributes
my $o_type=     undef;          # Type of system to check 

sub print_version { print "$0: $Version\n" };

sub print_usage {
        print "Usage: $0 [-v] -H <host> -C <snmp_community> [-2] | (-l login -x passwd)  [-P <port>] -T test|dellom|dellom_storage|blade|global|chassis|custom [-t <timeout>] [-V] [-u <unknown_default>]\n";
}

# Return true if arg is a number
sub isnum {
        my $num = shift;
        if ( $num =~ /^(\d+\.?\d*)|(^\.\d+)$/ ) { return 1 ;}
        return 0;
}

sub help {
        print "\nSNMP Dell OpenManage Monitor for Nagios version ",$Version,"\n";
        print " by Jason Ellison - infotek(at)gmail.com\n\n";
        print_usage();
        print <<EOD;
-v, --verbose
        print extra debugging information
-h, --help
        print this help message
-H, --hostname=HOST
        name or IP address of host to check
-C, --community=COMMUNITY NAME
        community name for the host's SNMP agent (implies v 1 protocol)
-2, --v2c
        use SNMP v2 (instead of SNMP v1)
-P, --port=PORT
        SNMPd port (Default 161)
-t, --timeout=INTEGER
        timeout for SNMP in seconds (Default: 5)
-V, --version
        prints version number
-u, --unknown_default=INT
        If attribute is not found then report the output as this number (i.e. -u 0)
-T, --type=test|dellom|dellom_storage|blade|global|chassis|custom
        This allows to use pre-defined system type
        Currently support systems types are:
              test (tries all OID's in verbose mode can be used to generate new system type)
              dellom (Dell OpenManage general detailed)
              dellom_storage (Dell OpenManage plus Storage Management detailed)
              blade (some features are on the chassis not the blade)
              global (only check the global health status)
              chassis (only check the system chassis health status)
              custom (intended for customization)
EOD
}

# For verbose output - don't use it right now
sub verb { my $t=shift; print $t,"\n" if defined($o_verb) ; }
# Get the alarm signal (just in case snmp timout screws up)
$SIG{'ALRM'} = sub {
     print ("ERROR: Alarm signal (Nagios time-out)\n");
     exit $ERRORS{"UNKNOWN"};
};
sub check_options {
    Getopt::Long::Configure ("bundling");
    GetOptions(
        'v'     => \$o_verb,            'verbose'       => \$o_verb,
        'h'     => \$o_help,            'help'          => \$o_help,
        'H:s'   => \$o_host,            'hostname:s'    => \$o_host,
        'P:i'   => \$o_port,            'port:i'        => \$o_port,
        'C:s'   => \$o_community,       'community:s'   => \$o_community,
        'l:s'   => \$o_login,           'login:s'       => \$o_login,
        'x:s'   => \$o_passwd,          'passwd:s'      => \$o_passwd,
        't:i'   => \$o_timeout,         'timeout:i'     => \$o_timeout,
        'V'     => \$o_version,         'version'       => \$o_version,
        '2'     => \$o_version2,        'v2c'           => \$o_version2,
        'u:i'   => \$o_unkdef,          'unknown_default:i' => \$o_unkdef,
        'T:s'   => \$o_type,            'type:s'        => \$o_type
    );
    if (defined($o_help) ) { help(); exit $ERRORS{"UNKNOWN"}; }
    if (defined($o_version)) { print_version(); exit $ERRORS{"UNKNOWN"}; }
    if (! defined($o_host) ) # check host and filter
        { print "No host defined!\n";print_usage(); exit $ERRORS{"UNKNOWN"}; }
    # check snmp information
    if (!defined($o_community) && (!defined($o_login) || !defined($o_passwd)) )
        { print "Put snmp login info!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; }
    if (!defined($o_type)) { print "Must define system type!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; }
    if (defined ($o_type)) {
        if ($o_type eq "test"){
          print "TEST MODE:\n"; 
        } elsif (!defined($system_types{$o_type}))  {
          print "Unknown system type $o_type !\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; 
        }
    }
}
########## MAIN #######
check_options();
# Check global timeout if something goes wrong
if (defined($o_timeout)) {
  verb("Alarm at $o_timeout");
  alarm($o_timeout);
} else {
  verb("no timeout defined : using 5s");
  alarm (5);
}

eval "use Net::SNMP";
if ($@) {
  verb("ERROR: You do NOT have the Net:".":SNMP library \n"
  . "  Install it by running: \n"
  . "  perl -MCPAN -e shell \n"
  . "  cpan[1]> install Net::SNMP \n");
  exit 1;
} else {
  verb("The Net:".":SNMP library is available on your server \n");
}

# SNMP Connection to the host
my ($session,$error);
if (defined($o_login) && defined($o_passwd)) {
  # SNMPv3 login
  verb("SNMPv3 login");
  ($session, $error) = Net::SNMP->session(
      -hostname         => $o_host,
      -version          => '3',
      -username         => $o_login,
      -authpassword     => $o_passwd,
      -authprotocol     => 'md5',
      -privpassword     => $o_passwd,
      -timeout          => $o_timeout
   );
} else {
   if (defined ($o_version2)) {
     # SNMPv2 Login
         ($session, $error) = Net::SNMP->session(
        -hostname  => $o_host,
            -version   => 2,
        -community => $o_community,
        -port      => $o_port,
        -timeout   => $o_timeout
     );
   } else {
    # SNMPV1 login
    ($session, $error) = Net::SNMP->session(
       -hostname  => $o_host,
       -community => $o_community,
       -port      => $o_port,
       -timeout   => $o_timeout
    );
  }
}
# next part of the code builds list of attributes to be retrieved
my $i;
my $oid;
my $line;
my $resp;
my $attr;
my $key;
my %varlist = ();
my $result;

if ( $o_type eq "test" ) {
  print "Trying all preconfigured Dell OID's against target...\n";
  for $attr (sort keys %dell_oids) {
    print "$attr\t\($dell_oids{$attr}\)\n";
    $result = $session->get_request(
      -varbindlist => [$dell_oids{$attr}]
    );
    print "RESULT: ";
    if (!defined($result)) {
      print "NO RESPONSE\n";
    } else {
      if ( $result->{$dell_oids{$attr}} =~ /^[123456]$/ ) {
        push @{ $varlist{$attr} }, "$attr", "$dell_oids{$attr}", "$result->{$dell_oids{$attr}}";
        print "$result->{$dell_oids{$attr}}\($DELLSTATUS[$result->{$dell_oids{$attr}}]\)\n";
      } else {
        print "$result->{$dell_oids{$attr}}\n";
      }
    }
  }
  $session->close();
  print "\nPlease email the results to Jason Ellison - infotek\@gmail.com\n";
  print "\nTo add this system to check_dell_openmanage, use something like the following:\n\n";
  print "        \"pexxxx\" => [\n";
  $i = 1;
  my $count = keys %varlist;
  for $attr (sort keys %varlist){
    print "                \'$varlist{$attr}[0]\'";
    if ( $i lt $count ) {
      print ",\n";
    } else {
      print "\n";
    }
    $i++;
  }
  print "        ],\n";
  exit 0 ;
} 

my $statusinfo = "";

verb("SNMP responses...");
for $attr ( @{ $system_types{$o_type} } ) {
  $result = $session->get_request( 
    -varbindlist => [$dell_oids{$attr}]
  );
  if (!defined($result)) {
    verb("RESULT: $attr \n$dell_oids{$attr} = undef");
    push @{ $varlist{$attr} }, "$attr", "$dell_oids{$attr}", "$o_unkdef"; 
  }
  else {
    if ( $result->{$dell_oids{$attr}} =~ /^[123456]$/ ) {
        verb("RESULT: $attr \n$dell_oids{$attr} = $result->{$dell_oids{$attr}}\($DELLSTATUS[$result->{$dell_oids{$attr}}]\)");
        push @{ $varlist{$attr} }, "$attr", "$dell_oids{$attr}", "$result->{$dell_oids{$attr}}"; 
      } else {
        verb("RESULT: $attr \n$dell_oids{$attr} = $result->{$dell_oids{$attr}}");
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$result->{$dell_oids{$attr}}";
      }
    }
}

$session->close();

# loop to check if warning & critical attributes are ok
verb("\nDell Status to Nagios Status mapping...");

my $statuscode = "OK";

my $statuscritical = "0";
my $statuswarning = "0";
my $statusunknown = "0";

foreach $attr (keys %varlist) {
    if ($varlist{$attr}[2] eq "6") {
        $statuscritical = "1";
        $statuscode="CRITICAL";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=Non-Recoverable";
    }
    elsif ($varlist{$attr}[2] eq "5") {
        $statuscritical="1";
        $statuscode="CRITICAL";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=Critical";
    }
    elsif ($varlist{$attr}[2] eq "4") {
        $statuswarning = "1";
        $statuscode="WARNING";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=Non-Critical";
    }
    elsif ($varlist{$attr}[2] eq "2") {
        $statusunknown = "1";
        $statuscode="UNKNOWN";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=UKNOWN";
    }
    elsif ($varlist{$attr}[2] eq "1") {
        $statusunknown = "1";
        $statuscode="UNKNOWN";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=Other";
    }
    elsif ($varlist{$attr}[2] eq "3") {
        $statuscode="OK";
    }
    else {
        $statusunknown = "1";
        $statuscode="UNKNOWN";
        $statusinfo .= ", " if ($statusinfo);
        $statusinfo .= "$attr=UKNOWN";
    }
    verb("$attr: statuscode = $statuscode");
}

$statuscode="OK";

if ($statuscritical eq '1'){
  $statuscode="CRITICAL";
}
elsif ($statuswarning eq '1'){
  $statuscode="WARNING";
}
elsif ($statusunknown eq '1'){
  $statuscode="UNKNOWN";
}

printf("$statuscode: $statusinfo\n");

verb("\nEXIT CODE: $ERRORS{$statuscode} STATUS CODE: $statuscode\n");

exit $ERRORS{$statuscode};

