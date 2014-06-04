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
    print STDERR "Error configuring anyfi controller: $msg\n";
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

sub generate_group_config {
    my $vyatta_level = $_[0];
    my $group_type = $_[1];

    my $config = new Vyatta::Config();  
    my %group_hash;
    
    my @groups = $config->listNodes($vyatta_level);
    for my $group (@groups) 
    {
        my %g_hash;
        $g_hash{"name"} = $group;
        $g_hash{"description"} = $config->returnValue("$vyatta_level $group description");
        
        $g_hash{"filters"} = {};
        
        my @filters = $config->listNodes("$vyatta_level $group");
        for my $filter (@filters) 
        {
            next unless $filter =~ m/.*-filter/;
            my @filter_values = $config->returnValues("$vyatta_level $group $filter");
            for my $filter_value (@filter_values) 
            {
                push @{$g_hash{"filters"}{"$filter"}}, $filter_value;                                   
            }                               
        }

        push @{$group_hash{"${group_type}-group"}}, \%g_hash;
    }
    
    return \%group_hash;
}

sub generate_license_config {
    my $vyatta_level = $_[0];

    my $config = new Vyatta::Config();  
    my @licenses_list;
    
    if ($config->exists("$vyatta_level license key"))
    {
      my $key = $config->returnValue("$vyatta_level license key");

      # Only print warnings and errors (and never fail):
      system("/usr/sbin/anyfi-controller --verify-key $key --verify-key-expiry > /dev/null");

      my %l_hash;
      $l_hash{"key"} = $key;
      push @licenses_list, \%l_hash;
    }
    
    return @licenses_list;
}

sub generate_radio_policy {
    my $vyatta_level = $_[0];
    my %result;

    my $config = new Vyatta::Config();
    
    if ( $config->exists("$vyatta_level min-dwell-time") ) 
    {
        $result{"min-dwell-time-sec"} = 
        $config->returnValue("$vyatta_level min-dwell-time");
    }
            
    if ( $config->exists("$vyatta_level min-signal-level") ) 
    {
        $result{"min-signal-level-dbm"} = 
        $config->returnValue("$vyatta_level min-signal-level");
    }
            
    if ( $config->exists("$vyatta_level min-uplink-capacity") ) 
    {
        $result{"min-uplink-bps"} = 
        int($config->returnValue("$vyatta_level min-uplink-capacity")*1024*1024);
    }
            
    if ( $config->exists("$vyatta_level min-downlink-capacity") ) 
    {
        $result{"min-downlink-bps"} = 
        int($config->returnValue("$vyatta_level min-downlink-capacity")*1024*1024);
    }
            
    if ( $config->exists("$vyatta_level kick-out") ) 
    {
        $result{"kick-out"} = "true";
    }
    
    if ( $config->exists("$vyatta_level suppress") ) 
    {
        $result{"suppress"} = "true";
    }
    
    return \%result;
}

sub generate_app_config {
    my $vyatta_level = $_[0];
    my $app_type = $_[1];
    
    my $config = new Vyatta::Config();
    my @apps;
    
    # Get app instances
    my @simple_apps = $config->listNodes($vyatta_level);   
    my %apps_hash;

    for my $app (@simple_apps)
    {
        my %this_app_hash;
        $this_app_hash{"type"} = $app_type;
        $this_app_hash{"name"} = $app;
        $this_app_hash{"description"} = $config->returnValue("$vyatta_level $app description");

        $this_app_hash{"config"} = {};
        $this_app_hash{"config"}{"name"} = "";
        if ( $config->exists("$vyatta_level $app broadcast-ssid") ) {
            $this_app_hash{"config"}{"broadcast-ssid"} = "true";
        }
        if ( $config->exists("$vyatta_level $app radio-policy") ) {
            # Read the radio policy settings
            $this_app_hash{"config"}{"radio-policy"} = generate_radio_policy("$vyatta_level $app radio-policy");                     
        }
        
        if ( $config->exists("$vyatta_level $app radio-policy when client has-preference-for nearby-service") ) {
            # Read the radio policy settings
            $this_app_hash{"config"}{"radio-policy-sta-local"} = generate_radio_policy("$vyatta_level $app radio-policy when client has-preference-for nearby-service");                     
        }
        
        if ( $config->exists("$vyatta_level $app radio-policy when service is-nearby") ) {
            # Read the radio policy settings
            $this_app_hash{"config"}{"radio-policy-service-local"} = generate_radio_policy("$vyatta_level $app radio-policy when service is-nearby");                     
        }
        
        for my $group_type ("client", "service", "radio")
        {
            $this_app_hash{"${group_type}s"} = {};
            for my $group_name ($config->returnValues("$vyatta_level $app ${group_type}s"))
            {
                check_group($group_name, $group_type);
                push @{$this_app_hash{"${group_type}s"}{$group_type}}, $group_name;
            }                               
        }
        push @apps, \%this_app_hash;
    }
    
    return @apps;
}

sub get_config
{
    my $config = new Vyatta::Config();
    $config->setLevel($controller_level);

    my %config_hash;
    my %groups_hash;
    my %app_hash;
    my %licenses_hash;

    # Get groups
    push @{$groups_hash{"radio-groups"}}, generate_group_config("$controller_level radio-group", "radio");
    push @{$groups_hash{"service-groups"}}, generate_group_config("$controller_level service-group", "service");
    push @{$groups_hash{"client-groups"}}, generate_group_config("$controller_level client-group", "client");

    $config_hash{"groups"} = \%groups_hash ;

    # Get apps
    push @{$app_hash{"app"}}, generate_app_config("$controller_level app simple", "simple");
    push @{$app_hash{"app"}}, generate_app_config("$controller_level app hotspot", "hotspot");
    
    $config_hash{"apps"} = \%app_hash;
    
    # Get license
    push @{$licenses_hash{"license"}}, generate_license_config("$controller_level");
    $config_hash{"licenses"} = \%licenses_hash;
    
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

open(HANDLE, '>', $config_path) or error("could not open $config_path for writing.");
print HANDLE generate_config(\%config_hash);
close HANDLE;

exit(0);
