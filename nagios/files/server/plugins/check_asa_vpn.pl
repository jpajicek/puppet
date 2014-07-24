#!/usr/bin/perl
 
use strict;
use warnings;
use vars qw($VERSION $VERBOSE $PROGNAME);

use Nagios::Plugin;
use File::Basename;
use Net::SNMP;
#use 5.016;

my $VERSION     = 1.0;

my $PROGNAME    =  basename($0);
my $OID_BASE    = '.1.3.6.1.4.1.9.9.171.1.2.3.1';
my $ENDPOINT_KEY = '.7';

my $table       = {};

# --verbose, --help, --usage, --timeout, and --host are defined
my $p = Nagios::Plugin->new(
        usage           => "Usage: %s [ -v ] [ -H hostname] [ -P snmp port] [ -C snmp_community] [ --nonblocking] [ --retries] [ --debug]
                            [ --snmpver 1 | v2c] [ --vpnpeer=172.16.1.10 ] ",
        version         => $VERSION,
        blurb           => "This plugin checks the status of an IPSEC VPN connected to a Cisco ASA running 8.2 or later",
        extra           => "",
        );


$p->add_arg(
        spec            => 'host|H=s',
        help            => '-H, --host hostname or IP address',
        required        => 1,
        );
$p->add_arg(
        spec            => 'port|P=i',
        help            => '-P, --port=INTEGER',
        default         => 161,
        required        => 0,
        );
$p->add_arg(
        spec            => 'nonblocking=s',
        help            => 'Use Nonblocking UDP',
        default         => 0x00,
        required        => 0,
        );
$p->add_arg(
        spec            => 'community|C=s',
        help            => 'SNMP Community string',
        default         => 'public',
        required        => 0,
        );
$p->add_arg(
        spec            => 'retries=i',
        help            => 'SNMP Retries - see Net::SNMP',
        default         => 3,
        required        => 0,
        );
$p->add_arg(
        spec            => 'snmpver=s',
        help            => 'SNMP Version to use, eg 1, v2c',
        default         => 'v2c',
        required        => 0,
        );

$p->add_arg(
        spec            => 'vpnpeer=s',
        help            => 'IP Address of VPN peer',
        required        => 1,
        );
$p->getopts;


snmpquery();

if ($p->opts->verbose) {
        use Data::Dumper;
        print Dumper $table;
}

# check and see if the VPN peer exists
if (! defined ($table->{$p->opts->vpnpeer})) {
        #$p->nagios_die("Could not find VPN Peer ". $p->opts->vpnpeer);
	$p->nagios_exit(CRITICAL, "Could not find VPN Peer ". $p->opts->vpnpeer);
}

# check and make sure the VPN is up
# SNMP returns 1 for VPN UP, 0 for VPN DOWN

if ($table->{$p->opts->vpnpeer}->{tunnel_status} != 1) {
        $p->nagios_exit(CRITICAL, "VPN " . $p->opts->vpnpeer ." is down");
}


# Add the performance data

$p->add_perfdata(
        label => 'tunnel_output_octets',
        value => $table->{$p->opts->vpnpeer}->{tunnel_output_octets},
        uom   => "B",
        );

$p->add_perfdata(
        label => 'tunnel_output_drop_pkts',
        value => $table->{$p->opts->vpnpeer}->{tunnel_output_drop_pkts},
        uom   => '',
        );
$p->add_perfdata(
        label => 'tunnel_input_octets',
        value => $table->{$p->opts->vpnpeer}->{tunnel_input_octets},
        uom => "B",
        );
$p->add_perfdata(
        label => 'tunnel_input_drop_pkts',
        value => $table->{$p->opts->vpnpeer}->{tunnel_input_drop_pkts},
        uom   => '',
        );

$p->nagios_exit(
        return_code     => 0,
        message         => "VPN Peer " . $table->{$p->opts->vpnpeer}->{ipaddr} ." is up",
        );


sub snmpquery {

        my ($session, $error) = Net::SNMP->session(
                        -hostname       => $p->opts->host,
                        -port           => $p->opts->port,
                        -nonblocking    => $p->opts->nonblocking,
                        -version        => $p->opts->snmpver,
                        -timeout        => int(($p->opts->timeout / 3) + 1),
                        -retries        => $p->opts->retries,
                        -community      => $p->opts->community,
                        -debug          => 0x00,
                        );


        if ( ! defined $session) {
                $p->nagios_die("Error gathering snmp information: $error");
        }

        find_vpn_endpoint($session);
}

sub find_vpn_endpoint {
        my $session = shift || return;

        my @endpoint; # list of ip addresses terminating vpns.

        my $query       = $OID_BASE . $ENDPOINT_KEY;

        # go grab a list of vpn endpoints

        my $resp      = $session->get_table($query);
        if ( ! defined $resp) {
                $p->nagios_die("SNMP Query failed");
        }

        foreach (keys $resp) {
                my $index = $_;
                $index =~ s/.*?\.(\d+)$/$1/;
                push (@endpoint, $index);
        }

        foreach my $index (@endpoint) {
                my $cikeTunStatus       = join('.', $OID_BASE, '35', $index);
                my $cikeTunOutOctets    = join('.', $OID_BASE, '27', $index); 
                my $cikeTunOutDropPkts  = join('.', $OID_BASE, '31', $index);
                my $cikeTunInOctets     = join('.', $OID_BASE, '19', $index);
                my $cikeTunInDropPkts   = join('.', $OID_BASE, '21', $index);
                my $ipaddr              = join('.', $OID_BASE, '7',  $index);

                my $r = $session->get_request( -varbindlist => [
                                        $cikeTunStatus, 
                                        $cikeTunOutOctets, 
                                        $cikeTunOutDropPkts, 
                                        $cikeTunInOctets, 
                                        $cikeTunInDropPkts, 
                                        $ipaddr]);

                my $h = {
                        tunnel_status           => $r->{$cikeTunStatus},
                        tunnel_output_octets    => $r->{$cikeTunOutOctets},
                        tunnel_output_drop_pkts => $r->{$cikeTunOutDropPkts},
                        tunnel_input_octets     => $r->{$cikeTunInOctets},
                        tunnel_input_drop_pkts  => $r->{$cikeTunInDropPkts},
                        ipaddr                  => $r->{$ipaddr},
                };

                $table->{$r->{$ipaddr}} = $h;

        }

}
