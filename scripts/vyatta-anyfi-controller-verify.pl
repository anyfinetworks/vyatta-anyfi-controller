#!/usr/bin/perl
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

use strict;
use warnings;
use Getopt::Long;
use NetAddr::IP;

use constant{ SUCCESS => 0, FAIL => 1};

## Reusable expressions
my $exp_byte = qr/([1-9]?\d|1\d\d|2[0-4]\d|25[0-5])/;
my $exp_hex = qr/[0-9A-Fa-f]/;

sub check_uuid
{
    my $exp_uuid = qr/^!?$exp_hex{8}-$exp_hex{4}-$exp_hex{4}-$exp_hex{4}-$exp_hex{12}$/;
    my $arg = shift;

    if( $arg =~ /$exp_uuid/ )
    {
        return(SUCCESS)
    }
    else
    {
        return(FAIL);
    }
}

sub check_mac {
    my $mac_oui_expr = qr/^!?$exp_hex{2}([:-]$exp_hex{2}){2}$/;
    my $mac_expr = qr/^!?$exp_hex{2}([:-]$exp_hex{2}){5}$/;
    my $arg = shift;

    if( ($arg =~ /$mac_oui_expr/) ||
        ($arg =~ /$mac_expr/) )
    {
        return(SUCCESS);
    }
    else
    {
        return(FAIL);
    }
}

# Check if a string is a valid IPv4 address
# by creating a NetAddr::IP objects from it
# and looking if it succeeds
sub check_ip
{
    my $arg = shift;

    # Match full ip
    my $exp_ip = qr/$exp_byte\.$exp_byte\.$exp_byte\.$exp_byte/;
    # Match 0-32
    my $exp_netmask = qr/([1-2]?\d|3[0-2])/;
    # Full CIDR
    my $exp_ip_filter = qr/^!?$exp_ip(\/$exp_netmask)?$/;

    if( $arg =~ /$exp_ip_filter/ )
    {
        return(SUCCESS);
    } else {
        return(FAIL);
    }
}


my $option = undef;
my $data = undef;

GetOptions(
  "check=s" => \$option,
  "data=s" => \$data
);

if( !defined($option) ||
    !defined($data) )
{
    exit(FAIL);
}

if( $option eq "ip" )
{
    exit( check_ip($data) );
}
elsif( $option eq "mac" )
{
    exit( check_mac($data) );
}
elsif( $option eq "uuid" )
{
    exit( check_uuid($data) );
}

