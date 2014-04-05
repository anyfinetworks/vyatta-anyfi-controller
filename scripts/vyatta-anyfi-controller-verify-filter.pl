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

if ($#ARGV+1 < 2) {
  print "Usage: $0 <filter name> <filter string>\n";  
  print "filter names: ip-filter, uuid-filter, mac-filter\n"; 
  exit;
}

$filter_name = $ARGV[0];
$filter_string = $ARGV[1];

# Match 0-255
$exp_byte = qr/([1-9]?\d|1\d\d|2[0-4]\d|25[0-5])/;
# Match full ip
$exp_ip = qr/$exp_byte\.$exp_byte\.$exp_byte\.$exp_byte/;
# Match 0-32
$exp_netmask = qr/([1-2]?\d|3[0-2])/;
# Match one hex characted
$exp_hex = qr/[0-9A-Fa-f]/;
# Match uuid
$exp_uuid = qr/$exp_hex{8}-$exp_hex{4}-$exp_hex{4}-$exp_hex{4}-$exp_hex{12}/;

if ($filter_name eq "ip-filter") {
  # Full ip-filter pattern, ip or ip/netmask
  $exp_ip_filter = qr/^$exp_ip(\/$exp_netmask)?$/;

  if ($filter_string =~ /$exp_ip_filter/) {
    exit 0
  }

  exit -1;
}

if ($filter_name eq "uuid-filter") {
  # Full uuid-filter pattern, full uuid
  $exp_uuid_filter = qr/^$exp_uuid$/;

  if ($filter_string =~ /$exp_uuid_filter/) {
    exit 0
  }

  exit -1;
}

if ($filter_name eq "mac-filter") {
  # Match uuid
  $exp_oui = qr/$exp_hex{2}([:-]$exp_hex{2}){2}/;
  $exp_mac = qr/$exp_hex{2}([:-]$exp_hex{2}){5}/;

  # Full mac-filter pattern, full mac or oui
  $exp_mac_filter = qr/^($exp_oui|$exp_mac)$/;

  if ($filter_string =~ /$exp_mac_filter/) {
    exit 0
  }

  exit -1;
}

# Bad filter name
exit -2;


