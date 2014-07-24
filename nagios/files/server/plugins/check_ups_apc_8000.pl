#!/usr/bin/perl

#    Copyright (C) 2004 Altinity Limited
#    E: info@altinity.com    W: http://www.altinity.com/
#    
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#    
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
#    GNU General Public License for more details.
#    
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA    02111-1307    USA

use Net::SNMP;
use Getopt::Std;

$script    = "check_ups_apc_8000.pl";
$script_version = "2.1.0";

$metric = 1;

$ipaddress = "192.168.1.1"; 	# default IP address, if none supplied
$version = "1";			# SNMP version
$timeout = 2;			# SNMP query timeout
# $warning = 100;			
# $critical = 150;
$status = 0;
$returnstring = "";

$community = "public"; 			# Default community string


# .1.3.6.1.4.1.
# enterprises.318.1.1.1.1.1.1.0 = STRING: "SMART-UPS 1000"		upsIdent

# enterprises.318.1.1.1.2.2.1.0			Battery capacity (%)
# enterprises.318.1.1.1.2.2.2.0			Temperature (Celcius)
# enterprises.318.1.1.1.2.2.3.0			Battery runtime remaining
# enterprises.318.1.1.1.2.2.4.0			Battery replace indicator (1=ok, 2=replace)
# enterprises.318.1.1.1.2.2.5.0			Number of battery packs
# enterprises.318.1.1.1.2.2.6.0			Number of bad battery packs
 
# enterprises.318.1.1.1.3.2.1.0			Input voltage
# enterprises.318.1.1.1.3.2.4.0			Input frequency
# enterprises.318.1.1.1.3.2.5.0			Reason for last transfer to UPS battery power:

# enterprises.318.1.1.1.4.2.1.0			Output voltage
# enterprises.318.1.1.1.4.2.2.0			Output frequency
# enterprises.318.1.1.1.4.2.3.0			Output load as % of capacity
# enterprises.318.1.1.1.4.2.4.0			Output current in ampheres

# enterprises.318.1.1.1.4.2.1.0			Configured voltage
# enterprises.318.1.1.1.8.1.0			Whether agent is communicating with UPS (1)

$oid_upstype = ".1.3.6.1.4.1.318.1.1.1.1.1.1.0";
$oid_battery_capacity = ".1.3.6.1.4.1.318.1.1.1.2.2.1.0";
$oid_battery_temperature = ".1.3.6.1.4.1.318.1.1.1.2.2.2.0";
$oid_battery_runtimeremain = ".1.3.6.1.4.1.318.1.1.1.2.2.3.0";
$oid_battery_replace = ".1.3.6.1.4.1.318.1.1.1.2.2.4.0";
$oid_input_voltage = ".1.3.6.1.4.1.318.1.1.1.3.2.1.0";
$oid_input_frequency = ".1.3.6.1.4.1.318.1.1.1.3.2.4.0";
$oid_input_reasonforlasttransfer = ".1.3.6.1.4.1.318.1.1.1.3.2.5.0";
$oid_output_voltage = ".1.3.6.1.4.1.318.1.1.1.4.2.1.0";
$oid_output_frequency = ".1.3.6.1.4.1.318.1.1.1.4.2.2.0";
$oid_output_load = ".1.3.6.1.4.1.318.1.1.1.4.2.3.0";
$oid_output_current = ".1.3.6.1.4.1.318.1.1.1.4.2.4.0";
$oid_output_configuredvoltage = ".1.3.6.1.4.1.318.1.1.1.4.2.1.0";
$oid_comms = ".1.3.6.1.4.1.318.1.1.1.8.1.0";
$oid_test_result = ".1.3.6.1.4.1.318.1.1.1.7.2.3.0";
$oid_test_date = ".1.3.6.1.4.1.318.1.1.1.7.2.4.0";
$oid_sysDescr = ".1.3.6.1.2.1.1.1.0";

$upstype = "";
$battery_capacity = 0;
$battery_temperature = 0;
$battery_runtimeremain = 0;
$battery_replace = "";
$input_voltage = 0;
$input_frequency = 0;
$input_reasonforlasttransfer = "";
$output_voltage = 0;
$output_frequency = 0;
$output_load = 0;
$output_current = 0;
$output_configuredvoltage = 0;
$outagecause = "";
$test_result = "";
$test_date = "";


# Do we have enough information?
if (@ARGV < 1) {
     print "Too few arguments\n";
     usage();
}

getopts("h:H:C:w:c:");
if ($opt_h){
    usage();
    exit(0);
}
if ($opt_H){
    $hostname = $opt_H;
}
else {
    print "No hostname specified\n";
    usage();
}
if ($opt_C){
    $community = $opt_C;
}
else {
}



# Create the SNMP session
my ($s, $e) = Net::SNMP->session(
     -community  =>  $community,
     -hostname   =>  $hostname,
     -version    =>  $version,
     -timeout    =>  $timeout,
);

main();

# Close the session
$s->close();

if ($returnstring eq ""){
    $status = 3;
}

if ($status == 0){
    print "Status is OK - $returnstring\n";
    # print "$returnstring\n";
}
elsif ($status == 1){
    print "Status is a WARNING level - $returnstring\n";
}
elsif ($status == 2){
    print "Status is CRITICAL - $returnstring\n";
}
else{
    print "Problem with plugin. No response from SNMP agent.\n";
}
 
exit $status;


####################################################################
# This is where we gather data via SNMP and return results         #
####################################################################

sub main {

    #######################################################
 
    if (!defined($s->get_request($oid_comms))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $temp = $s->var_bind_list()->{$_};
    }
    
    if ($temp eq "1"){
    }
    else {
        append("SNMP agent not communicating with UPS");
        $status = 2;
        return 1;
    }
    
    
    #######################################################
 
    if (!defined($s->get_request($oid_upstype))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $upstype = $s->var_bind_list()->{$_};
    }
    
    #######################################################
 
    if (!defined($s->get_request($oid_battery_capacity))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $battery_capacity = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_battery_temperature))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $battery_temperature = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_battery_runtimeremain))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $battery_runtimeremain = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_battery_replace))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $battery_replace = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_input_voltage))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $input_voltage = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_input_frequency))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $input_frequency = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_input_reasonforlasttransfer))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $input_reasonforlasttransfer = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_voltage))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_voltage = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_frequency))) {
        if (!defined($s->get_request($oid_sysDescr))) {            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_frequency = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_load))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_load = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_test_result))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $test_result = $s->var_bind_list()->{$_};
    }
    #######################################################

    if (!defined($s->get_request($oid_test_date))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $test_date = $s->var_bind_list()->{$_};
    }
    #######################################################
     
    $issue = "";

    if ($input_reasonforlasttransfer eq "1"){
        $outagecause = "No events"
    }
    elsif ($input_reasonforlasttransfer eq "2"){
        $outagecause = "High line voltage"
    }
    elsif ($input_reasonforlasttransfer eq "3"){
        $outagecause = "Brownout"
    }
    elsif ($input_reasonforlasttransfer eq "4"){
        $outagecause = "Loss of mains power"
    }
    elsif ($input_reasonforlasttransfer eq "5"){
        $outagecause = "Small temporary power drop"
    }
    elsif ($input_reasonforlasttransfer eq "6"){
        $outagecause = "Large temporary power drop"
    }
    elsif ($input_reasonforlasttransfer eq "7"){
        $outagecause = "Small spike"
    }
    elsif ($input_reasonforlasttransfer eq "8"){
        $outagecause = "Large spike"
    }
    elsif ($input_reasonforlasttransfer eq "9"){
        $outagecause = "UPS self test"
    }
    elsif ($input_reasonforlasttransfer eq "10"){
        $outagecause = "Excessive input voltage fluctuation"
    }
    else {
        $outagecause = "Cannot establish reason"
    }


    if ($test_result eq "1") {
        $test_result_string = "Passed";
    }
    elsif ($test_result eq "2") {
        $test_result_string = "Failed";
    }
    elsif ($test_result eq "4") {
        $test_result_string = "In Progress";
    }
    else {
        $test_result_string = "Unknown";
    }


    if ($battery_capacity < 50) {
        $issue = $issue . "BATTERY CAPACITY WARNING! ";
        $status = 1;
    }
    if ($output_load > 80) {
        $status = 1;
        $issue = $issue . "OUTPUT LOAD WARNING! ";
    }
    if ($test_result eq "2") {
        $issue = $issue . "SELF TEST FAILED! ";
        $status = 1;
    }
    if ($input_voltage < 1){
        $status = 2;
        $issue = $issue . "RUNNING ON BATTERY! ";
    }
    if ($battery_capacity < 25) {
        $issue = $issue . "BATTERY RUNNING LOW! ";
        $status = 2;
    }
    if ($output_load > 90) {
        $issue = $issue . "HIGH OUTPUT LOAD! ";
        $status = 2;
    }
    if ($battery_replace eq "2") {
        $issue = $issue . "REPLACE BATTERY! ";
        $status = 2; 
    }



    if ($status == 0){
        $temp = sprintf "$upstype - BATTERY:(capacity $battery_capacity%%, temperature $battery_temperature C, runtime $battery_runtimeremain) INPUT:(voltage $input_voltage V, frequency $input_frequency Hz) OUTPUT:(voltage $output_voltage V, frequency $output_frequency Hz, load $output_load%%) SELF TEST:($test_result_string on $test_date) LAST EVENT:($outagecause)";
    }
    else {
        $temp = sprintf "$issue - $upstype - BATTERY:(capacity $battery_capacity%%, temperature $battery_temperature C, runtime $battery_runtimeremain) INPUT:(voltage $input_voltage V, frequency $input_frequency Hz) OUTPUT:(voltage $output_voltage V, frequency $output_frequency Hz, load $output_load%%)    LAST EVENT:$outagecause";
    }
    append($temp);

}

####################################################################
# help and usage information                                       #
####################################################################

sub usage {
    print << "USAGE";
-----------------------------------------------------------------	 
$script v$script_version

Monitors APC SmartUPS via AP9617 SNMP management card.

Usage: $script -H <hostname> -c <community> [...]

Options: -H 	Hostname or IP address
         -C 	Community (default is public)
	 
-----------------------------------------------------------------	 
Copyright 2004 Altinity Limited	 
	 
This program is free software; you can redistribute it or modify
it under the terms of the GNU General Public License
-----------------------------------------------------------------

USAGE
     exit 1;
}

####################################################################
# Appends string to existing $returnstring                         #
####################################################################

sub append {
    my $appendstring =    @_[0];    
    $returnstring = "$returnstring$appendstring";
}

