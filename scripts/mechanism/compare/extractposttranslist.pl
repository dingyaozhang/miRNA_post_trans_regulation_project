use strict;
use warnings;



use Getopt::Std;
use vars qw($opt_i $opt_s $opt_o);
getopts('i:so:');


open OUT, '>', "$opt_o".'post.txt' or die;
open OUTT, '>', "$opt_o".'trans.txt' or die;

my $ahash;
my $i = 0;
if ($opt_s) {
	$ahash = &spein($opt_i);
}else{
	$ahash = &norin($opt_i);
}

my %ahash = %{$ahash};



for my $var (keys(%ahash)) {
	
	if ($ahash{$var} eq 'post') {
		print OUT "$var\n";
	}else{
		print OUTT "$var\n";
	}
	
	
}

close OUT;


sub norin {
	open IN, "$_[0]" or die "$_[0]";
	my $firstline = <IN>;
	my %ref;
	
	
	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;
	
		chomp($inaa);
		my @array = split(/\t/, $inaa);
		if ($array[5] > $array[8]) {
			$ref{"$array[0]"} = 'post';
		}elsif ($array[5] < $array[8]) {
			$ref{"$array[0]"} = 'trans';
		}else{
			print "why same $array[0]?\n";
		}
	}
	close IN;
	return(\%ref);
}

sub spein {
	open IN, "$_[0]" or die "$_[0]";
	my $firstline = <IN>;
	my %ref;
	

	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;
	
		chomp($inaa);
		my @array = split(/\t/, $inaa);
		if ($array[6] > $array[9]) {
			$ref{"$array[0]"} = 'post';
		}elsif ($array[6] < $array[9]) {
			$ref{"$array[0]"} = 'trans';
		}else{
			print "why same $array[0]?\n";
		}
	}
	close IN;
	return(\%ref);

}