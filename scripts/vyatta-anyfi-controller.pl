#!/usr/bin/perl
#
# vyatta-anyfi-controller.pl: AnyFi controller config generator
#
# Maintainer: Daniil Baturin <daniil@baturin.org>
#
# Copyright (C) 2013 AnyFi Networks
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
#

use lib "/opt/vyatta/share/perl5/";

use strict;
use warnings;
use Vyatta::Config;
use Data::Dumper;
use XML::Simple;

my $controller_level = "service anyfi controller";
my $config_path = "/etc/anyfi-controller.xml";

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

        # Create the any group
        {
            my %rg_hash;
            $rg_hash{"name"} = "any";
            $rg_hash{"description"} = "automatically generated wildcard group";
            $rg_hash{"filters"}{"ip-filter"} = "*";
            $rg_hash{"filters"}{"mac-filter"} = "*";
            push @{$radio_hash{"radio-group"}}, \%rg_hash;
        }

        for my $rg (@radio_groups)
        {
            $config->setLevel("$controller_level radio-group $rg");
            my %rg_hash;
            $rg_hash{"name"} = $rg;
            $rg_hash{"description"} = $config->returnValue("description");
            $rg_hash{"filters"}{"ip-filter"} = $config->returnValue("ip-filter");
            $rg_hash{"filters"}{"mac-filter"} = $config->returnValue("mac-filter");

            if( defined($rg_hash{"filters"}{"ip-filter"}) )
            {
                $rg_hash{"filters"}{"ip-filter"} =~ s/any/\*/g;
            }
            else
            {
                $rg_hash{"filters"}{"ip-filter"} = "*";
            }

            if( defined($rg_hash{"filters"}{"mac-filter"}) )
            {
                $rg_hash{"filters"}{"mac-filter"} =~ s/any/\*/g;
            }
            else
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

        # Create the any group
        {
            my %sg_hash;
            $sg_hash{"name"} = "any";
            $sg_hash{"description"} = "automatically generated wildcard group";
            $sg_hash{"filters"}{"ip-filter"} = "*";
            $sg_hash{"filters"}{"uuid-filter"} = "*";
            push @{$service_hash{"service-group"}}, \%sg_hash;
        }

        for my $sg (@service_groups)
        {
            $config->setLevel("$controller_level service-group $sg");
            my %sg_hash;
            $sg_hash{"name"} = $sg;
            $sg_hash{"description"} = $config->returnValue("description");
            $sg_hash{"filters"}{"ip-filter"} = $config->returnValue("ip-filter");
            $sg_hash{"filters"}{"uuid-filter"} = $config->returnValue("uuid-filter");

            if( defined($sg_hash{"filters"}{"ip-filter"}) )
            {
                $sg_hash{"filters"}{"ip-filter"} =~ s/any/\*/g;
            }
            else
            {
                $sg_hash{"filters"}{"ip-filter"} = "*";
            }

            if( defined($sg_hash{"filters"}{"uuid-filter"}) )
            {
                $sg_hash{"filters"}{"uuid-filter"} =~ s/any/\*/g;
            }
            else
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

        # Create the any group
        {
            my %cg_hash;
            $cg_hash{"name"} = "any";
            $cg_hash{"description"} = "automatically generated wildcard group";
            $cg_hash{"filters"}{"mac-filter"} = "*";
            push @{$client_hash{"client-group"}}, \%cg_hash;
        }

        for my $cg (@client_groups)
        {
            $config->setLevel("$controller_level client-group $cg");
            my %cg_hash;
            $cg_hash{"name"} = $cg;
            $cg_hash{"description"} = $config->returnValue("description");
            $cg_hash{"filters"}{"mac-filter"} = $config->returnValue("mac-filter");

            if( defined($cg_hash{"filters"}{"mac-filter"}) )
            {
                $cg_hash{"filters"}{"mac-filter"} =~ s/any/\*/g;
            }
            else
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

	    if ( $config->exists("visibility-policy") ) {
		$this_app_hash{"visibility-policy"} = {};
		if ( $config->exists("visibility-policy min-dwell-time-s") ) {
		    $this_app_hash{"visibility-policy"}{"min-dwell-time-sec"} = $config->returnValue("visibility-policy min-dwell-time-s");
		}
		if ( $config->exists("visibility-policy min-signal-level-dBm") ) {
		    $this_app_hash{"visibility-policy"}{"min-signal-dbm"} = $config->returnValue("visibility-policy min-signal-level-dBm");
		}
		if ( $config->exists("visibility-policy min-uplink-capacity-Mbps") ) {
		    $this_app_hash{"visibility-policy"}{"min-uplink-bps"} = int($config->returnValue("visibility-policy min-uplink-capacity-Mbps")*1024*1024);
		}
		if ( $config->exists("visibility-policy min-downlink-capacity-Mbps") ) {
		    $this_app_hash{"visibility-policy"}{"min-downlink-bps"} = int($config->returnValue("visibility-policy min-downlink-capacity-Mbps")*1024*1024);
		}
	    }

            $this_app_hash{"clients"} = {};
            $this_app_hash{"services"} = {};
            $this_app_hash{"radios"} = {};
            
            for my $client ($config->returnValues("clients"))
            {
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }
	    if (!%{$this_app_hash{"clients"}}) 
	    {
		push @{$this_app_hash{"clients"}{"client"}}, "any";
	    }

            for my $service ($config->returnValues("services"))
            {
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }
	    if (!%{$this_app_hash{"services"}}) 
	    {
		push @{$this_app_hash{"services"}{"service"}}, "any";
	    }

            for my $radio ($config->returnValues("radios"))
            {
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }
	    if (!%{$this_app_hash{"radios"}}) 
	    {
		push @{$this_app_hash{"radios"}{"radio"}}, "any";
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

	    if ( $config->exists("visibility-policy") ) {
		$this_app_hash{"visibility-policy"} = {};
		if ( $config->exists("visibility-policy min-dwell-time-s") ) {
		    $this_app_hash{"visibility-policy"}{"min-dwell-time-sec"} = $config->returnValue("visibility-policy min-dwell-time-s");
		}
		if ( $config->exists("visibility-policy min-signal-level-dBm") ) {
		    $this_app_hash{"visibility-policy"}{"min-signal-dbm"} = $config->returnValue("visibility-policy min-signal-level-dBm");
		}
		if ( $config->exists("visibility-policy min-uplink-capacity-Mbps") ) {
		    $this_app_hash{"visibility-policy"}{"min-uplink-bps"} = int($config->returnValue("visibility-policy min-uplink-capacity-Mbps")*1024*1024);
		}
		if ( $config->exists("visibility-policy min-downlink-capacity-Mbps") ) {
		    $this_app_hash{"visibility-policy"}{"min-downlink-bps"} = int($config->returnValue("visibility-policy min-downlink-capacity-Mbps")*1024*1024);
		}
	    }

            $this_app_hash{"clients"} = {};
            $this_app_hash{"services"} = {};
            $this_app_hash{"radios"} = {};

            for my $client ($config->returnValues("clients"))
            {
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }
	    if (!%{$this_app_hash{"clients"}}) 
	    {
		push @{$this_app_hash{"clients"}{"client"}}, "any";
	    }

            for my $service ($config->returnValues("services"))
            {
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }
	    if (!%{$this_app_hash{"services"}}) 
	    {
		push @{$this_app_hash{"services"}{"service"}}, "any";
	    }

            for my $radio ($config->returnValues("radios"))
            {
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }
	    if (!%{$this_app_hash{"radios"}}) 
	    {
		push @{$this_app_hash{"radios"}{"radio"}}, "any";
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

open(HANDLE, '>', $config_path) or die "Error opening $config_path: $!";
print HANDLE generate_config(\%config_hash);
close HANDLE;


exit(0);
