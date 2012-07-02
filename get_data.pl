#!/usr/bin/env perl
use Net::Twitter;
use Data::Dumper;
use Getopt::Long;

my $handle = "arbit";
my $consumer_key = "arbit";
my $consumer_secret = "arbit";
my $access_token = "arbit";
my $access_token_secret = "arbit";
my $file_name = "get_data.conf";

#Opening the conf file
open ($CONF_FILE, "<$file_name");

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

my @ids;
my $count=1;

for ( my $cursor = -1, my $r; $cursor; $cursor = $r->{next_cursor} ) {
	$r = $nt->followers_ids({ cursor => $cursor , screen_name => $handle });
	push @ids, @{ $r->{ids} };
        #sleep 240;
	#print "count = $count\n";
	$count++;
}

my $num_ids_in_array = @ids;
print "Number of followers = $num_ids_in_array\n";
print "Array of ids start:\n @ids \nArray of ids ends\n";

while(@ids) {
	my @ids_100 = splice @ids,0,100;
        # get a result set of users
        my $friends = $nt->lookup_users({user_id=>\@ids_100});

        # Loop over the array ref to get each user?
        foreach (@$friends) {
        	my $user = $_;
        	my $screen_name = $user->{"screen_name"};
        	print Dumper($user);
	}
	#sleep 30;
}

my $num_api_acc_left = $nt->rate_limit_status->{remaining_hits};
print "Number of api acc left = $num_api_acc_left\n";
