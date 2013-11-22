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
    if( $config->exists("radio-group") )
    {
        my @radio_groups = $config->listNodes("radio-group");
        my %radio_hash;

        for my $rg (@radio_groups)
        {
            $config->setLevel("$controller_level radio-group $rg");
            my %rg_hash;
            $rg_hash{"name"} = $rg;
            $rg_hash{"description"} = $config->returnValue("description");
            $rg_hash{"filters"}{"ext-ip"} = $config->returnValue("ip-address");
            $rg_hash{"filters"}{"mac"} = $config->returnValue("mac-address");
            $rg_hash{"filters"}{"mac-oui"} = $config->returnValue("mac-oui");
 
            push @{$radio_hash{"radio-group"}}, \%rg_hash;
            $config->setLevel($controller_level);
        }

        push @{$groups_hash{"radio-groups"}}, \%radio_hash;
    }

    # Get service groups
    if( $config->exists("service-group") )
    {
        my @service_groups = $config->listNodes("service-group");
        my %service_hash;

        for my $sg (@service_groups)
        {
            $config->setLevel("$controller_level service-group $sg");
            my %sg_hash;
            $sg_hash{"name"} = $sg;
            $sg_hash{"description"} = $config->returnValue("description");
            $sg_hash{"filters"}{"ext-ip"} = $config->returnValue("ip-address");
            $sg_hash{"filters"}{"uuid"} = $config->returnValue("uuid");
            $sg_hash{"filters"}{"ssid"} = $config->returnValue("ssid");

            push @{$service_hash{"service-group"}}, \%sg_hash;
            $config->setLevel($controller_level);
        }

        push @{$groups_hash{"service-groups"}}, \%service_hash;
    }

    # Get client groups
    if( $config->exists("client-group") )
    {
        my @client_groups = $config->listNodes("client-group");
        my %client_hash;

        for my $cg (@client_groups)
        {
            $config->setLevel("$controller_level client-group $cg");
            my %cg_hash;
            $cg_hash{"name"} = $cg;
            $cg_hash{"description"} = $config->returnValue("description");
            $cg_hash{"filters"}{"mac"} = $config->returnValue("mac-address");
            $cg_hash{"filters"}{"mac-oui"} = $config->returnValue("mac-oui");

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

            $this_app_hash{"database"}{"mysql"}{"host"} = $config->returnValue("database mysql host");
            $this_app_hash{"database"}{"mysql"}{"port"} = $config->returnValue("database mysql port");
            $this_app_hash{"database"}{"mysql"}{"schema"} = $config->returnValue("database mysql schema");
            $this_app_hash{"database"}{"mysql"}{"user"} = $config->returnValue("database mysql user");
            $this_app_hash{"database"}{"mysql"}{"password"} = $config->returnValue("database mysql password");
            $this_app_hash{"database"}{"mysql"}{"type"} = "mysql";
            
            for my $client ($config->listNodes("clients"))
            {
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }

            for my $service ($config->listNodes("services"))
            {
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }

            for my $radio ($config->listNodes("radios"))
            {
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }

            $this_app_hash{"policy"}{"min-signal-level"} = $config->returnValue("policy min-signal-level");
            $this_app_hash{"policy"}{"min-upstream-bandwidth"} = $config->returnValue("policy min-upstream-bandwidth");
            $this_app_hash{"policy"}{"min-downstream-bandwidth"} = $config->returnValue("policy min-downstream-bandwidth");
            $this_app_hash{"policy"}{"min-dwell-time"} = $config->returnValue("policy min-dwell-time");
            $this_app_hash{"policy"}{"kick-out"} = $config->returnValue("policy kick-out");

            push @{$app_hash{"app"}}, \%this_app_hash;
            $config->setLevel($controller_level);
        }

    }

    # Get mobile apps
    if( $config->exists("app mobile") )
    {
        my @simple_apps = $config->listNodes("app mobile");
        my %simple_hash;

        for my $app (@simple_apps)
        {
            $config->setLevel("$controller_level app mobile $app");
            my %this_app_hash;
            $this_app_hash{"type"} = "mobile";
            $this_app_hash{"name"} = $app;
            $this_app_hash{"description"} = $config->returnValue("description");

            for my $client ($config->listNodes("clients"))
            {
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }

            for my $service ($config->listNodes("services"))
            {
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }

            for my $radio ($config->listNodes("radios"))
            {
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }

            push @{$app_hash{"app"}}, \%this_app_hash;
            $config->setLevel($controller_level);
        }
    }

    # Get hotspot apps
    if( $config->exists("app hotspot") )
    {
        my @simple_apps = $config->listNodes("app hotspot");
        my %simple_hash;

        for my $app (@simple_apps)
        {
            $config->setLevel("$controller_level app hotspot $app");
            my %this_app_hash;
            $this_app_hash{"type"} = "hotspot";
            $this_app_hash{"name"} = $app;
            $this_app_hash{"description"} = $config->returnValue("description");

            for my $client ($config->listNodes("clients"))
            {
                push @{$this_app_hash{"clients"}{"client"}}, $client;
            }

            for my $service ($config->listNodes("services"))
            {
                push @{$this_app_hash{"services"}{"service"}}, $service;
            }

            for my $radio ($config->listNodes("radios"))
            {
                push @{$this_app_hash{"radios"}{"radio"}}, $radio;
            }

            $this_app_hash{"policy"}{"min-signal-level"} = $config->returnValue("policy min-signal-level");
            $this_app_hash{"policy"}{"min-upstream-bandwidth"} = $config->returnValue("policy min-upstream-bandwidth");
            $this_app_hash{"policy"}{"min-downstream-bandwidth"} = $config->returnValue("policy min-downstream-bandwidth");
            $this_app_hash{"policy"}{"min-dwell-time"} = $config->returnValue("policy min-dwell-time");
            $this_app_hash{"policy"}{"kick-out"} = $config->returnValue("policy kick-out");

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
