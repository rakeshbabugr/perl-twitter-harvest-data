#!/usr/bin/env perl
use Net::Twitter;
use Data::Dumper;

my $handle = "arbit";
my $consumer_key = "arbit";
my $consumer_secret = "arbit";
my $access_token = "arbit";
my $access_token_secret = "arbit";
my $file_name = "get_data.conf";

#Opening the conf file
open ($CONF_FILE, "<$file_name");
open ($WRITE_FILE, ">temp_write");

while (<$CONF_FILE>) {
 	chomp;
	if(/handle\s*:\s*/) {
		$_ =~ s/\s*//g;
		($handle = $_) =~ s/handle\://;
	}
	elsif(/consumer_key\s*:\s*/) {
		$_ =~ s/\s*//g;
		($consumer_key = $_) =~ s/consumer_key://;
	}
	elsif(/consumer_secret\s*:\s*/) {
		$_ =~ s/\s*//g;
		($consumer_secret = $_) =~ s/consumer_secret://;
	}
	elsif(/access_token\s*:\s*/) {
		$_ =~ s/\s*//g;
		($access_token = $_) =~ s/access_token://;
	}
	elsif(/access_token_secret\s*:\s*/) {
		$_ =~ s/\s*//g;
		($access_token_secret = $_) =~ s/access_token_secret://;
	}
}
close ($CONF_FILE); 

#print Dumper($handle);
#print Dumper($consumer_key);
#print Dumper($consumer_secret);
#print Dumper($access_token);
#print Dumper($access_token_secret);

my $nt = Net::Twitter->new(
  consumer_key        => $consumer_key,
  consumer_secret     => $consumer_secret,
  access_token        => $access_token,
  access_token_secret => $access_token_secret,
  traits   => [qw/OAuth API::REST/]
);

my $num_api_acc_left = $nt->rate_limit_status->{remaining_hits};
print "Number of api acc left = $num_api_acc_left\n";

my $reset_time_in_seconds = $nt->rate_limit_status->{reset_time_in_seconds} - time;
print "Reset time in seconds = $reset_time_in_seconds\n";

my @ids;
my $count=1;

for ( my $cursor = -1, my $r; $cursor; $cursor = $r->{next_cursor} ) {
API_CALLED_HERE:
	print "API called here\n";
	eval { 
		$r = $nt->followers_ids({ cursor => $cursor , screen_name => $handle });
	};
	if($@) {
		print "There was some error : $@ \n";
		#sleep 60;
		goto API_CALLED_HERE;
	}
	push @ids, @{ $r->{ids} };
        #sleep 12;
API_CALLED_HERE_AGAIN_PLUS_0:
	print "Seeing how many accesses left\n";
	eval { $num_api_acc_left = $nt->rate_limit_status->{remaining_hits}; };
	if($@) {
		print "There was some error : $@ \n";
		goto API_CALLED_HERE_AGAIN_PLUS_0;
	}
	print "Number of api acc left = $num_api_acc_left\n";
API_CALLED_HERE_AGAIN_PLUS_PLUS_0:
	print "Seeing how much time is left for reseting\n";
	eval { $reset_time_in_seconds = $nt->rate_limit_status->{reset_time_in_seconds}; };
	if($@) {
		print "There was some error : $@ \n";
		goto API_CALLED_HERE_AGAIN_PLUS_PLUS_0;
	}
	$reset_time_in_seconds = $reset_time_in_seconds - time;
	if($num_api_acc_left <= 5) {
		sleep ($reset_time_in_seconds + 180);	
	}
	print "Reset time in seconds = $reset_time_in_seconds\n";
	print "count = $count\n";
	$count++;
}

my $num_ids_in_array = @ids;
print $WRITE_FILE  "Number of followers = $num_ids_in_array\n";
print $WRITE_FILE  "Array of ids start:\n @ids \nArray of ids ends\n";

$count = 1;
while(@ids) {
	my @ids_100 = splice @ids,0,100;
        # get a result set of users
API_CALLED_HERE_AGAIN:
	print "API called here again\n";
        my $friends;
	eval {
		$friends = $nt->lookup_users({user_id=>\@ids_100});
	};
	if($@) {
		print "There was some error : $@ \n";
		#sleep 60;
		goto API_CALLED_HERE_AGAIN;
	}
        # Loop over the array ref to get each user?
        foreach (@$friends) {
        	my $user = $_;
        	my $screen_name = $user->{"screen_name"};
        	print $WRITE_FILE  Dumper($user);
	}
	#sleep 12;
API_CALLED_HERE_AGAIN_PLUS:
	print "Seeing how many accesses left\n";
	eval { $num_api_acc_left = $nt->rate_limit_status->{remaining_hits}; };
	if($@) {
		print "There was some error : $@ \n";
		goto API_CALLED_HERE_AGAIN_PLUS;
	}
	print "Number of api acc left = $num_api_acc_left\n";
API_CALLED_HERE_AGAIN_PLUS_PLUS:
	print "Seeing how much time is left for reseting\n";
	eval { $reset_time_in_seconds = $nt->rate_limit_status->{reset_time_in_seconds}; };
	if($@) {
		print "There was some error : $@ \n";
		goto API_CALLED_HERE_AGAIN_PLUS_PLUS;
	}
	$reset_time_in_seconds = $reset_time_in_seconds - time;
	if($num_api_acc_left <= 5) {
		sleep ($reset_time_in_seconds + 180);	
	}
	print "Reset time in seconds = $reset_time_in_seconds\n";
	
	print "count = $count\n";
	$count++;
}

