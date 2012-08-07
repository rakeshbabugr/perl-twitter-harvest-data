#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: cut_r.pl
#
#        USAGE: ./cut_r.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Rakesh Gilikenahalli (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: Thursday 02 August 2012 11:06:30  IST
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;


my	$ip_file_name = $ARGV[0];		# input file name

open  my $ip, '<', $ip_file_name
or die  "$0 : failed to open  input file '$ip_file_name' : $!\n";
my @lines = <$ip>;

#Constant definitions
my $total_tables = 17;

for(my $i=0;$i<$total_tables;$i++) {
	my	$op_file_name = "$i.txt" ;		# output file name

		open  my $op, '>>', $op_file_name
		or die  "$0 : failed to open  output file '$op_file_name' : $!\n";

		for(my $count = 1+3*$i; $count < 1 + 3*($i+1);$count++) {
			print $op $lines[$count];	
		}

		close  $op
		or warn "$0 : failed to close output file '$op_file_name' : $!\n";
}


close  $ip
or warn "$0 : failed to close input file '$ip_file_name' : $!\n";

