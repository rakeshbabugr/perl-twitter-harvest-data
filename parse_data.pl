#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: parse_data.pl
#
#        USAGE: ./parse_data.pl  
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
#      CREATED: Sunday 08 July 2012 03:22:19  IST
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Time::ParseDate;
use POSIX;

my @files = $ARGV[0];
my %equiv_loc_hash;
my @array_of_handler_hashes;
my @array_of_followers_count_bin_values; 
my @array_of_statuses_count_bin_values; 
my @array_of_status_created_at_bin_values; 
my @array_of_account_created_at_bin_values; 
my @array_of_description_bin_values; 
my %hash_of_description_aliter_bin_values; 

my	$conf_for_parse_data_file_name = 'parse_data.conf';		# input file name
my $master_r_string;
my $header_r_string;

#Main r string
my	$r_string_file_name = 'r_string.r';		# input file name

open  my $r_string_full, '<', $r_string_file_name
or die  "$0 : failed to open  input file '$r_string_file_name' : $!\n";
{
	local $/;
	$master_r_string = <$r_string_full>;
}

close  $r_string_full
or warn "$0 : failed to close output file '$r_string_file_name' : $!\n";

#Output r string
my	$r_string_op_file_name = 'r_script.r';		# output file name

open  my $r_string_op, '>', $r_string_op_file_name
or die  "$0 : failed to open  output file '$r_string_op_file_name' : $!\n";

#Header r string
my	$header_r_string_file_name  = 'r_header.r';		# output file name
open  my $header_r_string_pointer , '<', $header_r_string_file_name
or die  "$0 : failed to open  input file '$header_r_string_file_name' : $!\n";
{
	local $/;
	$header_r_string = <$header_r_string_pointer>;
}

close  $header_r_string_pointer
or warn "$0 : failed to close output file '$header_r_string_file_name' : $!\n";

print $r_string_op $header_r_string;

open  my $conf_for_parse_data, '<', $conf_for_parse_data_file_name
	or die  "$0 : failed to open  input file '$conf_for_parse_data_file_name' : $!\n";

while(<$conf_for_parse_data>) {
	#print "I am here 0\n";
	if(/^:equivalence/) {
		while(($_ = <$conf_for_parse_data>) !~ /^:equivalence/) {
			chomp($_);
			#print "I am here 1\n";
			(my $unique_location = $_) =~ s/(.*):(.*)$/$2/ ;
			(my $all_locs_line = $_) =~ s/(.*):(.*)$/$1/ ;
			my @all_locs = split(',' ,  $all_locs_line);
			foreach my $each_loc (@all_locs) {
				$equiv_loc_hash{$each_loc} = $unique_location;	
				#print "each_loc = $each_loc , unique_location = $unique_location\n";
			}
		}
	}
	#print "line = $_";
	if(/^:followers_count:/) {
			#print "hre: line = $_";
			chomp($_);
			$_ =~ s/.*://;
			@array_of_followers_count_bin_values = split(',',$_);
	}
	if(/^:statuses_count:/) {
			chomp($_);
			$_ =~ s/.*://;
			@array_of_statuses_count_bin_values = split(',',$_);
	}
	if(/^:status_created_at:/) {
			chomp($_);
			$_ =~ s/.*://;
			@array_of_status_created_at_bin_values = split(',',$_);
	}
	if(/^:account_created_at:/) {
			chomp($_);
			$_ =~ s/.*://;
			@array_of_account_created_at_bin_values = split(',',$_);
	}
	if(/^:description:/) {
			chomp($_);
			$_ =~ s/.*://;
			@array_of_description_bin_values = split(',',$_);
	}
	if(/^:description_aliter:/) {
			chomp($_);
			$_ =~ s/.*://;
			my @array_of_description_aliter_bin_values = split(',',$_);
			foreach my $each_description_aliter_bin_value (@array_of_description_aliter_bin_values) {
				$each_description_aliter_bin_value =~ s/(\w+)/\u\L$1/g;
				$hash_of_description_aliter_bin_values{$each_description_aliter_bin_value} = 1;
			}
	}
}
push @array_of_status_created_at_bin_values ,  "undef";
push @array_of_account_created_at_bin_values , "undef";

close  $conf_for_parse_data
	or warn "$0 : failed to close input file '$conf_for_parse_data_file_name' : $!\n";

foreach my $file (@files)  {
	(my $handle = $file) =~ s/\.txt//;
	my	$twitter_info_file_file_name = $file;		# input file name
	my %current_handle_hash;
	my @array_of_follower_hashes;
	my $num_followers=0;
	my %handle_location_hash;
	my %handle_followers_count_hash;
	my %handle_statuses_count_hash;
	my %handle_status_created_at_hash;
	my %handle_account_created_at_hash;
	my %handle_description_hash;
	my %handle_description_aliter_hash;
	my %handle_time_zone_hash;
	
	open  my $twitter_info_file, '<', $twitter_info_file_file_name
		or die  "$0 : failed to open  input file '$twitter_info_file_file_name' : $!\n";
	
	#print "I am here asshole\n";

	while(<$twitter_info_file>) {
		if(/^\$VAR1/) {
			my %current_follower_hash;
			$num_followers++;
			while(1) {
				#print "1\n";
				$current_follower_hash{friends_count} = parse_field($twitter_info_file,"friends_count","num");
				#print "friends_count = $current_follower_hash{friends_count}\n";
				#print "2\n";
				$current_follower_hash{screen_name} = parse_field($twitter_info_file,"screen_name","str");
				#print "3\n";
				$current_follower_hash{location} = parse_field($twitter_info_file,"location","str");
				#print "4\n";
				$current_follower_hash{followers_count} = parse_field($twitter_info_file,"followers_count","num");
				#print "5\n";
				$current_follower_hash{statuses_count} = parse_field($twitter_info_file,"statuses_count","num");
				#print "6\n";
				$current_follower_hash{description} = parse_field($twitter_info_file,"description","str");
				while(<$twitter_info_file>) {
					if(/^\s*\'profile_background_tile\'/) {
						#print "6a\n";
						my $line = <$twitter_info_file>;
						#print "inside: 1 line = $line\n";
						if($line =~ /^\s*\'status\'/) {
							while(<$twitter_info_file>) {
								#print "inside: 2, line = $_\n";
								if(/^\s*\'place\'/) {
									my $line = <$twitter_info_file>;
									#print "inside: 3 line = $line\n";
									if($line =~ /^\s*\'retweeted_status\'/) {
										go_till_end_of_string($twitter_info_file,"},");
										last;
									}
									else {
										last;
									}
								}
							}
							$current_follower_hash{status_created_at} = parse_field($twitter_info_file,"created_at","str");
						}
						else {
							$current_follower_hash{status_created_at} = '';
						}
						last;		
					}
				}
				#print "7\n";
				$current_follower_hash{account_created_at} = parse_field($twitter_info_file,"created_at","str");
				#print "8\n";
				$current_follower_hash{time_zone} = parse_field($twitter_info_file,"time_zone","str");
				my $location = $current_follower_hash{location};
				$location =~ s/,.*//g;
				$location =~ s/\s+/ /g;
				$location =~ s/^\s*|\s*$//g;
				$location =~ s/(\w+)/\u\L$1/g;
				#print "location = :$location:\n";
				if(exists $equiv_loc_hash{$location}) {
					$location = $equiv_loc_hash{$location};
				}
				else {
					#print "location $location doesn't exist in hash  \n";
				}
				if(exists $handle_location_hash{$location}) {
					$handle_location_hash{$location}++;
				}
				else {
					$handle_location_hash{$location} = 1;
				}
				go_till_end_of_string($twitter_info_file,"};");
				last;	
			}
			
			#followers_count
			foreach my $followers_count_bin (@array_of_followers_count_bin_values) {
				#print "followers_count_bin = $followers_count_bin\n";
			    #print "followers_count = $current_follower_hash{followers_count}\n";
				if($current_follower_hash{followers_count} <= $followers_count_bin) {
					#print "followers_count less than $followers_count_bin\n";
					if(!(exists $handle_followers_count_hash{$followers_count_bin})) {
						$handle_followers_count_hash{$followers_count_bin} = 1;
					}
					else {
						$handle_followers_count_hash{$followers_count_bin}++;
					}
					last;
				}
			}
			#statuses_count
			foreach my $statuses_count_bin (@array_of_statuses_count_bin_values) {
				#print "statuses_count_bin = $statuses_count_bin\n";
			    #print "statuses_count = $current_follower_hash{statuses_count}\n";
				if($current_follower_hash{statuses_count} <= $statuses_count_bin) {
					#print "statuses_count less than $statuses_count_bin\n";
					if(!(exists $handle_statuses_count_hash{$statuses_count_bin})) {
						$handle_statuses_count_hash{$statuses_count_bin} = 1;
					}
					else {
						$handle_statuses_count_hash{$statuses_count_bin}++;
					}
					last;
				}
			}
		
			my $current_time;
			if ($handle eq 'bdutt') {
				$current_time = parsedate("Fri Jul 6 12:00:00 2012");
			}
			else {
				$current_time = parsedate("Sun Jul 8 12:00:00 2012");
			}
			
			(my $status_created_at = $current_follower_hash{status_created_at}) =~ s/(\S*)(\s*)(\S*)$/$2$3/; 
			#print "time = $status_created_at\n";
			my $status_created_at_time;
			my $status_created_at_time_from_now;
			my $status_created_at_time_days_from_now;
			if($status_created_at ne '') {
				$status_created_at_time = parsedate($status_created_at) if ($status_created_at ne '');	
				$status_created_at_time_from_now = $current_time - $status_created_at_time;
				$status_created_at_time_days_from_now = $status_created_at_time_from_now / (3600 * 24 );	
				#print "status_created_at days from now = $status_created_at_time_days_from_now\n";		
			}
			
			(my $account_created_at = $current_follower_hash{account_created_at}) =~ s/(\S*)(\s*)(\S*)$/$2$3/; 
			#print "time = $account_created_at\n";
			my $account_created_at_time;
			my $account_created_at_time_from_now;
			my $account_created_at_time_days_from_now;
			if($account_created_at ne '') {
				$account_created_at_time = parsedate($account_created_at) if ($account_created_at ne '');	
				$account_created_at_time_from_now = $current_time - $account_created_at_time;
				$account_created_at_time_days_from_now = $account_created_at_time_from_now/ (3600 * 24 );	
				#print "account_created_at days from now = $account_created_at_time_days_from_now\n";		
			}

		    #print "\n";
			#status_created_at
			foreach my $status_created_at_bin (@array_of_status_created_at_bin_values) {
				#print "status_created_at_bin = $status_created_at_bin\n";
				if($status_created_at eq '') {
					if(!(exists $handle_status_created_at_hash{undef})){
						$handle_status_created_at_hash{undef} = 1;
					}
					else {
						$handle_status_created_at_hash{undef}++;
					}
					last;
				}
				if($status_created_at_bin eq 'undef') {
					print "screen_name = $current_follower_hash{screen_name}\n";
					die  "undef came\n";
					next;
				}
			    #print "status_created_at_time_days_from_now = $status_created_at_time_days_from_now\n";
				
				if($status_created_at_time_days_from_now <= $status_created_at_bin) {
					#print "status_created_at less than $status_created_at_bin\n";
					if(!(exists $handle_status_created_at_hash{$status_created_at_bin})) {
						$handle_status_created_at_hash{$status_created_at_bin} = 1;
					}
					else {
						$handle_status_created_at_hash{$status_created_at_bin}++;
					}
					last;
				}
			}
			#print "\n";
	
			#account_created_at
			foreach my $account_created_at_bin (@array_of_account_created_at_bin_values) {
				#print "account_created_at_bin = $account_created_at_bin\n";
				if($account_created_at eq '') {
					if(!(exists $handle_account_created_at_hash{undef})){
						$handle_account_created_at_hash{undef} = 1;
					}
					else {
						$handle_account_created_at_hash{undef}++;
					}
					last;
				}
				if($account_created_at_bin eq 'undef') {
					next;
				}
			    #print "account_created_at_time_days_from_now = $account_created_at_time_days_from_now\n";
				
				if($account_created_at_time_days_from_now <= $account_created_at_bin) {
					#print "account_created_at less than $account_created_at_bin\n";
					if(!(exists $handle_account_created_at_hash{$account_created_at_bin})) {
						$handle_account_created_at_hash{$account_created_at_bin} = 1;
					}
					else {
						$handle_account_created_at_hash{$account_created_at_bin}++;
					}
					last;
				}
			}

			#description
			foreach my $description_bin (@array_of_description_bin_values) {
				#print "description_bin = $description_bin\n";
			    #print "description = $current_follower_hash{description}\n";
				if($current_follower_hash{description} =~ /$description_bin/i) {
					#print "description contains $description_bin\n";
					if(!(exists $handle_description_hash{$description_bin})) {
						$handle_description_hash{$description_bin} = 1;
					}
					else {
						$handle_description_hash{$description_bin}++;
					}
				}
			}

		    my @all_words = split('\W+',$current_follower_hash{description});
			foreach my $current_word (@all_words) {
				$current_word =~ s/(\w+)/\u\L$1/g;
				eval {($current_follower_hash{description} =~ /$current_word/i) };
				if((exists $hash_of_description_aliter_bin_values{$current_word})||($current_word=~/\d/)||($current_word eq '')) {
					next;
				}	
    			if(!($@)) {	
					if($current_follower_hash{description} =~ /$current_word/i) {
    					if(!(exists $handle_description_aliter_hash{$current_word})) {
    						$handle_description_aliter_hash{$current_word} = 1;
    					}
    					else {
    						$handle_description_aliter_hash{$current_word}++;
    					}
    				}	
				}
				else {
					print "Eval is going mad at $current_word \n";
				}	
			}
	
			my $time_zone = $current_follower_hash{time_zone};
    		if(!(exists $handle_time_zone_hash{$time_zone})) {
    			$handle_time_zone_hash{$time_zone} = 1;
    		}
    		else {
    			$handle_time_zone_hash{$time_zone}++;
    		}

			#print Dumper(%current_follower_hash);
			#print "\n";
			push @array_of_follower_hashes,\%current_follower_hash;
		}
	}
	
	$current_handle_hash{handle} = $handle; 
	$current_handle_hash{num_followers} = $num_followers; 
	$current_handle_hash{array_of_follower_hashes} = \@array_of_follower_hashes; 
	$current_handle_hash{handle_location_hash} = \%handle_location_hash;
	$current_handle_hash{handle_followers_count_hash} = \%handle_followers_count_hash;
	$current_handle_hash{handle_statuses_count_hash} = \%handle_statuses_count_hash;
	$current_handle_hash{handle_status_created_at_hash} = \%handle_status_created_at_hash;
	$current_handle_hash{handle_account_created_at_hash} = \%handle_account_created_at_hash;
	$current_handle_hash{handle_description_hash} = \%handle_description_hash;
	$current_handle_hash{handle_description_aliter_hash} = \%handle_description_aliter_hash;
	$current_handle_hash{handle_time_zone_hash} = \%handle_time_zone_hash;
		my $flag=0;
 
	push @array_of_handler_hashes , \%current_handle_hash;
	
	close  $twitter_info_file
		or warn "$0 : failed to close input file '$twitter_info_file_file_name' : $!\n";
}

my $table_num = 0;
#print "Printing stuff\n";
foreach my $current_handle_hash (@array_of_handler_hashes)  {
	my $handle = $current_handle_hash->{handle};	
	print "Handle = $current_handle_hash->{handle}\n\n";
	print "Number of followers = $current_handle_hash->{num_followers}\n\n";
	my $num_followers = $current_handle_hash->{num_followers};
	print "Percentage of followers, Location{Have taken only followers with non blank location into consideration}\n";
	my $num_followers_with_non_blank;
	$num_followers_with_non_blank = $current_handle_hash->{num_followers} - $current_handle_hash->{handle_location_hash}->{''};
	
	my @left_val;
	my @right_val;
	for(my $count = 0; $count < 31;$count++) {
		my $current_max_value = -1;
		my $current_location = "";
		foreach my $key (keys %{$current_handle_hash->{handle_location_hash}}) {
			if($current_handle_hash->{handle_location_hash}->{$key} > $current_max_value) {
				$current_max_value = $current_handle_hash->{handle_location_hash}->{$key};
				$current_location = $key;
				#print "$current_handle_hash->{handle_location_hash}->{$key} = number of users staying in $key\n";
			} 
		} 
		$current_handle_hash->{handle_location_hash}->{$current_location} = -($current_handle_hash->{handle_location_hash}->{$current_location});
		if($current_location ne '') {
			my $per_val = ($current_max_value/$num_followers_with_non_blank)*100;
			$per_val = sprintf("%.2f",$per_val);
			print $per_val . ",$current_location\n";
			push @right_val , $current_location;
			push @left_val , $per_val;
		}
	}
	
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Location","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,0);

	@left_val = ();
	@right_val = ();	
	print "\n";
	my $prev_num_count=-1;
	print "% of followers,followers_count of follower\n";
	foreach my $key (sort { $a <=> $b } keys(%{$current_handle_hash->{handle_followers_count_hash}}) ) {
		my $per_val = sprintf("%.2f",($current_handle_hash->{handle_followers_count_hash}->{$key}/$num_followers)*100);
		my $key_print = "<=$key";
		if($prev_num_count != -1) {
			$key_print = ">$prev_num_count && ". $key_print;
		}	
		$prev_num_count = $key;
		print "$per_val,$key_print\n";
		push @right_val , $key_print;
		push @left_val , $per_val;
	} 
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Followers count","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,1);
	
	@left_val = ();
	@right_val = ();	
	$prev_num_count=-1;
	print "% of followers,statuses_count of follower\n";
	foreach my $key (sort { $a <=> $b } keys(%{$current_handle_hash->{handle_statuses_count_hash}}) ) {
		my $per_val = sprintf("%.2f",($current_handle_hash->{handle_statuses_count_hash}->{$key}/$num_followers)*100);
		my $key_print = "<=$key";
		if($prev_num_count != -1) {
			$key_print = ">$prev_num_count && ". $key_print;
		}	
		$prev_num_count = $key;
		print "$per_val,$key_print\n";
		push @right_val , $key_print;
		push @left_val , $per_val;
	} 
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Statuses count","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,1);
	
	@left_val = ();
	@right_val = ();	
	$prev_num_count=-1;
	print "% of followers,last status(of follower) created at(Number of days from now)\n";
	foreach my $key (sort { $a <=> $b } keys(%{$current_handle_hash->{handle_status_created_at_hash}}) ) {
		my $per_val = sprintf("%.2f",($current_handle_hash->{handle_status_created_at_hash}->{$key}/$num_followers)*100);
		my $key_print = "<=$key";
		if($key eq "undef") {
			$key_print = "undef";
		}
		if($prev_num_count != -1) {
			$key_print = ">$prev_num_count && ". $key_print;
			if($prev_num_count eq "undef") {
				$key_print = "<=$key";
			}
		}	
		$prev_num_count = $key;
		print "$per_val,$key_print\n";
		push @right_val , $key_print;
		push @left_val , $per_val;
	} 
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Status last created at(in days)","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,1);
	
	@left_val = ();
	@right_val = ();	
	$prev_num_count=-1;
	print "% of followers,account(of follower) created at(Number of days from now)\n";
	foreach my $key (sort { $a <=> $b } keys(%{$current_handle_hash->{handle_account_created_at_hash}}) ) {
		my $per_val = sprintf("%.2f",($current_handle_hash->{handle_account_created_at_hash}->{$key}/$num_followers)*100);
		my $key_print = "<=$key";
		if($prev_num_count != -1) {
			$key_print = ">$prev_num_count && ". $key_print;
		}	
		$prev_num_count = $key;
		print "$per_val,$key_print\n";
		push @right_val , $key_print;
		push @left_val , $per_val;
	} 
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Account created at(in days)","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,1);
	
	@left_val = ();
	@right_val = ();	
	print "% of followers having certain pattern in descripton,pattern\n";
	foreach my $key (sort { hashValueDecendingNum (%{$current_handle_hash->{handle_description_hash}}) } keys %{$current_handle_hash->{handle_description_hash}}) {
		#my $per_val = sprintf("%.2f",($current_handle_hash->{handle_description_hash}->{$key}/$num_followers)*100);
		my $per_val = $current_handle_hash->{handle_description_hash}->{$key};
		print "$per_val,$key\n";
		push @right_val , $key;
		push @left_val , $per_val;
	} 
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Pattern","Number of occurences in bio's of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,0);
	
	@left_val = ();
	@right_val = ();	
	print "Most occuring words in bio's of the followers\n";
	print "% of followers having certain word in descripton,word(counted more than once if it exists)\n";
	for(my $count = 0; $count < 30;$count++) {
		my $current_max_value = -1;
		my $current_location = "";
		foreach my $key (keys %{$current_handle_hash->{handle_description_aliter_hash}}) {
			if($current_handle_hash->{handle_description_aliter_hash}->{$key} > $current_max_value) {
				$current_max_value = $current_handle_hash->{handle_description_aliter_hash}->{$key};
				$current_location = $key;
				#print "$current_handle_hash->{handle_description_aliter_hash}->{$key} = number of users staying in $key\n";
			} 
		} 
		$current_handle_hash->{handle_description_aliter_hash}->{$current_location} = -($current_handle_hash->{handle_description_aliter_hash}->{$current_location});
			#my $per_val = sprintf("%.2f",($current_max_value/$num_followers)*100);
			my $per_val = $current_max_value;
			print $per_val . ",$current_location\n";
			push @right_val , $current_location;
			push @left_val , $per_val;
	}
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Word","Number of occurences in bio's of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,0);
	
	@left_val = ();
	@right_val = ();	
	$num_followers_with_non_blank = $current_handle_hash->{num_followers} - $current_handle_hash->{handle_time_zone_hash}->{''};
	print "% of followers in time_zone,time_zone{Have taken only followers with non blank time_zone}\n";
	for(my $count = 0; $count < 22;$count++) {
		my $current_max_value = -1;
		my $current_location = "";
		foreach my $key (keys %{$current_handle_hash->{handle_time_zone_hash}}) {
			if($current_handle_hash->{handle_time_zone_hash}->{$key} > $current_max_value) {
				$current_max_value = $current_handle_hash->{handle_time_zone_hash}->{$key};
				$current_location = $key;
				#print "$current_handle_hash->{handle_time_zone_hash}->{$key} = number of users staying in $key\n";
			} 
		} 
		$current_handle_hash->{handle_time_zone_hash}->{$current_location} = -($current_handle_hash->{handle_time_zone_hash}->{$current_location});
		if($current_location ne '') {
			my $per_val = sprintf("%.2f",($current_max_value/$num_followers_with_non_blank)*100);
			print $per_val . ",$current_location\n";
			push @right_val , $current_location;
			push @left_val , $per_val;
		}
	}
	print "\n";
	$table_num = print_r_files_and_tables(\@left_val,\@right_val,$r_string_op,$handle,"Time zone","% of followers",$table_num,"$handle:Number of followers = $num_followers",$master_r_string,0,1);

	close  $r_string_op
	or warn "$0 : failed to close input file '$r_string_op_file_name' : $!\n";

}

sub parse_field {
	my $fh	= shift ;
	my $field = shift;
	my $field_type = shift;
	#print "field_type = $field_type \n";
	my $line;
	my $return_val;
	#print "I am here\n";
	while(<$fh>) {
		if(/^\s*\'$field\'/) {
			$line = $_;
			last;
		}
	}
	
	if($field_type eq "str") {
		#print "I am here 2\n";
		if($line =~ /^\s*\'$field\'\s*\=\>\s*undef\s*,\s*$/) {
			return('');
		}
		while($line !~ /^\s*\'$field\'\s*\=\>\s*(\S).*\1,\s*$/) {
			#print "line = $line\n";
			$line =~ s/\r//;
			$line =~ s/\n//;
			$line .= " ";
			$line .= <$fh>;
			#print "line = $line\n";
		}
		($return_val = $line ) =~ s/^\s*\'$field\'\s*\=\>\s*(\S)(.*)\1,\s*$/$2/;
		return($return_val);
	}
	elsif ($field_type eq "num") {
		#print "I am here 2\n";
		#print "line = $line\n";
		($return_val = $line ) =~ s/^\s*\'$field\'\s*\=\>\s*(\S*)\s*,\s*$/$1/;
		#print "return_val = $return_val\n";
		return($return_val);
	}
	
	return ;
} ## --- end sub parse_field

sub go_till_end_of_string {
	my $fh = shift;
	my $end_string = shift;

	while(<$fh>) {
		#print $_;
		if(/^\s*$end_string\s*$/) {
			#print $_;
			last;
		}
	}
}

sub hashValueAscendingNum {
   my (%hash) = @_;
   return $hash{$a} <=> $hash{$b};
}

sub hashValueDecendingNum {
   my (%hash) = @_;
   return $hash{$b} <=> $hash{$a};
}

sub print_r_files_and_tables {
	my $left_val_ref = shift;
	my $right_val_ref = shift;
	my $file_pointer = shift;
	my $handle = shift;
	my $xlab = shift;
	my $ylab = shift;
	my $table_num = shift;
	my $title = shift;
	my $r_string = shift;
	my $no_ylim = shift;
	my $five_per_page = 0;
	$five_per_page = shift if @_;
	my @left_val = @{$left_val_ref};
	my @right_val = @{$right_val_ref};
	my $ylim;
	my $count = 0 ;
	my $num_keys = @left_val;
	my $r_file_string;
	my $num_per_graph;
	if($five_per_page) {
		$num_per_graph = 7;
	} else {
		$num_per_graph = 10;
	}
	
	
	print "left_val = @left_val , right_val = @right_val , file_pointer = $file_pointer , handle = $handle , xlab = $xlab , ylab = $ylab , table_num = $table_num , title = $title , r_string = $r_string \n";
	
	for(my $i=0;$i<int(($num_keys+$num_per_graph-1)/$num_per_graph);$i++) {
		print "num_keys = $num_keys\n";		
		print "i = $i\n";		
		
		#print "I am here\n";		

		my	$op_file_name = $handle . "table" . $table_num. ".txt" ;		# output file name

		open  my $op, '>', $op_file_name
		or die  "$0 : failed to open  output file '$op_file_name' : $!\n";
				
		$r_file_string = $r_string;	
		$r_file_string =~ s/#table#/${handle}table${table_num}/;	
		
		for(my $j=0;($i*$num_per_graph+$j<$num_keys) && ($j<$num_per_graph);$j++) {
			print $op $left_val[$i*$num_per_graph+$j] . "," . $right_val[$i*$num_per_graph+$j] . "\n";	
			if($i == 0 && $j ==0) {
				$ylim = $left_val[0];
				$ylim = POSIX::ceil($ylim);
			}
			$count++;
		}
		close  $op
		or warn "$0 : failed to close output file '$op_file_name' : $!\n";
		
		$r_file_string =~ s/#title#/${title}/;	
		$r_file_string =~ s/#xlab#/${xlab}/;	
		$r_file_string =~ s/#ylab#/${ylab}/;	
		if($no_ylim) {
			$r_file_string =~ s/,ylim.*#\)//;	
		}
		else {
			$r_file_string =~ s/#ylim#/${ylim}/;
		}
		print $file_pointer $r_file_string;
		$table_num++;
	}
	return($table_num);		
}
