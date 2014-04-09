#!/usr/bin/perl
#
# vyatta-anyfi-controller.pl: anyfi-controller config generator
#
# Maintainer: Anyfi Networks <eng@anyfinetworks.com>
#
# Copyright (C) 2013-2014 Anyfi Networks AB. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use lib "/opt/vyatta/share/perl5/";

use strict;
use warnings;
use Vyatta::Config;
use Data::Dumper;
use XML::Simple;

my $controller_level = "service anyfi controller";
my $config_path = "/etc/anyfi-controller.xml";

sub error
{
    my $msg = shift;
    print "Error configuring anyfi controller: $msg\n";
    exit(1);
}

sub check_group {
    my $name = $_[0];
    my $type = $_[1];
    my $config = new Vyatta::Config();
    $config->setLevel($controller_level);

    error("$type group $name is not defined.") unless $config->exists("${type}-group $name")
}

sub check_client_group {
    my $client = $_[0];
    check_group($client, "client");
}

sub check_service_group {
    my $service = $_[0];
    check_group($service, "service");
}

sub check_radio_group {
    my $radio = $_[0];
    check_group($radio, "radio");
}

sub get_config
{
    my $config = new Vyatta::Config();
    $config->setLevel($controller_level);

    my %config_hash;
    my %groups_hash;
    my %app_hash;

    # Get radio groups
    {
        my @radio_groups = $config->listNodes("radio-group");
        my %radio_hash;

        for my $rg (@radio_groups)
        {
            $config->setLevel("$controller_level radio-group $rg");
            my %rg_hash;
            $rg_hash{"name"} = $rg;
            $rg_hash{"description"} = $config->returnValue("description");
            $rg_hash{"filters"}{"ip-filter"} = $config->returnValue("ip-filter");
            $rg_hash{"filters"}{"mac-filter"} = $config->returnValue("mac-filter");

            unless( defined($rg_hash{"filters"}{"ip-filter"}) )
            {
                $rg_hash{"filters"}{"ip-filter"} = "*";
            }

            unless( defined($rg_hash{"filters"}{"mac-filter"}) )
            {
                $rg_hash{"filters"}{"mac-filter"} = "*";
            }
            
            push @{$radio_hash{"radio-group"}}, \%rg_hash;
            $config->setLevel($controller_level);
        }

        push @{$groups_hash{"radio-groups"}}, \%radio_hash;
    }

    # Get service groups
    {
        my @service_groups = $config->listNodes("service-group");
        my %service_hash;

        for my $sg (@service_groups)
        {
            $config->setLevel("$controller_level service-group $sg");
            my %sg_hash;
            $sg_hash{"name"} = $sg;
            $sg_hash{"description"} = $config->returnValue("description");
            $sg_hash{"filters"}{"ip-filter"} = $config->returnValue("ip-filter");
            $sg_hash{"filters"}{"uuid-filter"} = $config->returnValue("uuid-filter");

            unless( defined($sg_hash{"filters"}{"ip-filter"}) )
            {
                $sg_hash{"filters"}{"ip-filter"} = "*";
            }

            unless( defined($sg_hash{"filters"}{"uuid-filter"}) )
            {
                $sg_hash{"filters"}{"uuid-filter"} = "*";
            }

            
            push @{$service_hash{"service-group"}}, \%sg_hash;
            $config->setLevel($controller_level);
        }

        push @{$groups_hash{"service-groups"}}, \%service_hash;
    }

    # Get client groups
    {
        my @client_groups = $config->listNodes("client-group");
        my %client_hash;

        for my $cg (@client_groups)
        {
            $config->setLevel("$controller_level client-group $cg");
            my %cg_hash;
            $cg_hash{"name"} = $cg;
            $cg_hash{"description"} = $config->returnValue("description");
            $cg_hash{"filters"}{"mac-filter"} = $config->returnValue("mac-filter");

            unless( defined($cg_hash{"filters"}{"mac-filter"}) )
            {
                $cg_hash{"filters"}{"mac-filter"} = "*";
            }
            
            push @{$client_hash{"client-group"}}, \%cg_hash;
            $config->setLevel($controller_level);
        }

        push @{$groups_hash{"client-groups"}}, \%client_hash;
    }

    $config_hash{"groups"} = \%groups_hash ;

    # Get simple apps
    if( $config->exists("app simple") )
    {
        my @simple_apps = $config->listNodes("app simple");
        my %simple_hash;

        for my $app (@simple_apps)
        {
            $config->setLevel("$controller_level app simple $app");
            my %this_app_hash;
            $this_app_hash{"type"} = "simple";
            $this_app_hash{"name"} = $app;
            $this_app_hash{"description"} = $config->returnValue("description");

            if ( $config->exists("radio-policy") ) {
              $this_app_hash{"radio-policy"} = {};
              if ( $config->exists("radio-policy min-dwell-time") ) {
                  $this_app_hash{"radio-policy"}{"min-dwell-time-sec"} = $config->returnValue("radio-policy min-dwell-time");
              }
              if ( $config->exists("radio-policy min-signal-level") ) {
                  $this_app_hash{"radio-policy"}{"min-signal-level-dbm"} = $config->returnValue("radio-policy min-signal-level");
              }
              if ( $config->exists("radio-policy min-uplink-capacity") ) {
                  $this_app_hash{"radio-policy"}{"min-uplink-bps"} = int($config->returnValue("radio-policy min-uplink-capacity")*1024*1024);
              }
              if ( $config->exists("radio-policy min-downlink-capacity") ) {
                  $this_app_hash{"radio-policy"}{"min-downlink-bps"} = int($config->returnValue("radio-policy min-downlink-capacity")*1024*1024);
              }
            }

            $this_app_hash{"clients"} = {};
            $this_app_hash{"services"} = {};
            $this_app_hash{"radios"} = {};
            
            for my $client ($config->returnValues("clients"))
            {
                check_client_group($client);
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }

            for my $service ($config->returnValues("services"))
            {
                check_service_group($service);
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }

            for my $radio ($config->returnValues("radios"))
            {
                check_radio_group($radio);
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }

            $this_app_hash{"config"} = {};

            push @{$app_hash{"app"}}, \%this_app_hash;
            $config->setLevel($controller_level);
        }
    }

    # Get hotspot apps
    if( $config->exists("app hotspot") )
    {
        my @hotspot_apps = $config->listNodes("app hotspot");
        my %hotspot_hash;

        for my $app (@hotspot_apps)
        {
            $config->setLevel("$controller_level app hotspot $app");
            my %this_app_hash;
            $this_app_hash{"type"} = "hotspot";
            $this_app_hash{"name"} = $app;
            $this_app_hash{"description"} = $config->returnValue("description");

            if ( $config->exists("radio-policy") ) {
                $this_app_hash{"radio-policy"} = {};
                if ( $config->exists("radio-policy min-dwell-time-s") ) {
                    $this_app_hash{"radio-policy"}{"min-dwell-time-sec"} = $config->returnValue("radio-policy min-dwell-time-s");
                }
                if ( $config->exists("radio-policy min-signal-level-dBm") ) {
                    $this_app_hash{"radio-policy"}{"min-signal-dbm"} = $config->returnValue("radio-policy min-signal-level-dBm");
                }
                if ( $config->exists("radio-policy min-uplink-capacity-Mbps") ) {
                    $this_app_hash{"radio-policy"}{"min-uplink-bps"} = int($config->returnValue("radio-policy min-uplink-capacity-Mbps")*1024*1024);
                }
                if ( $config->exists("radio-policy min-downlink-capacity-Mbps") ) {
                    $this_app_hash{"radio-policy"}{"min-downlink-bps"} = int($config->returnValue("radio-policy min-downlink-capacity-Mbps")*1024*1024);
                }
            }

            $this_app_hash{"clients"} = {};
            $this_app_hash{"services"} = {};
            $this_app_hash{"radios"} = {};

            for my $client ($config->returnValues("clients"))
            {
                check_client_group($client);
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }

            for my $service ($config->returnValues("services"))
            {
                check_service_group($service);
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }

            for my $radio ($config->returnValues("radios"))
            {
                check_radio_group($radio);
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }

            $this_app_hash{"config"} = {};

            push @{$app_hash{"app"}}, \%this_app_hash;
            $config->setLevel($controller_level);
        }
    }

    $config_hash{"groups"} = \%groups_hash ;
    $config_hash{"apps"} = \%app_hash;

    # Hardcoded parts
    $config_hash{"interface"}{"port"} = 6726;
    $config_hash{"interface"}{"address"} = "0.0.0.0";

    return %config_hash;
}

sub generate_config
{
    my $config_hash = shift;
    my $xml = new XML::Simple;
    return( $xml->XMLout($config_hash, NoAttr => 1, XMLDecl => 1, RootName => "server") );
}

my %config_hash = get_config();

open(HANDLE, '>', $config_path) or error("Error opening $config_path: $!");
print HANDLE generate_config(\%config_hash);
close HANDLE;


exit(0);
