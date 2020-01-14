use strict;
use warnings;



use Getopt::Std;
use vars qw($opt_i $opt_c $opt_o);
getopts('i:c:o:');


open OUT, '>', "$opt_o" or die;


my $i = 0;

my $ahash = &tcgain($opt_i);
my $bhash = &cclein($opt_c);

my %ahash = %{$ahash};
my %bhash = %{$bhash};
my %outhash;
$outhash{'transsame'} = 0;
$outhash{'postsame'} = 0;
$outhash{'transdiff'} = 0;
$outhash{'postdiff'} = 0;


for my $var (keys(%bhash)) {
	
	my ($tissue, $mir) = split(/\t/, $var);
	next if $tissue ne 'all';
	if (exists($ahash{$var})) {
		if ($ahash{$var} eq $bhash{$var}) {
			$outhash{'transsame'} += 1 if $ahash{$var} eq 'trans';
			$outhash{'postsame'} += 1 if $ahash{$var} eq 'post';
		}else{
			$outhash{'transdiff'} += 1 if $ahash{$var} eq 'trans';
			$outhash{'postdiff'} += 1 if $ahash{$var} eq 'post';
		}
		print "$mir\t$ahash{$var}\t$bhash{$var}\n";
	}
	
}

print OUT "$outhash{'postsame'}\t$outhash{'postdiff'}\n$outhash{'transdiff'}\t$outhash{'transsame'}\n";

close OUT;


sub cclein {
	open IN, "$_[0]" or die "$_[0]";
	my $firstline = <IN>;
	my %ref;
	
	$ref{'post'} = 0;
	$ref{'trans'} = 0;
	$ref{'same'} = 0;
	
	
	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;
	
		chomp($inaa);
		my @array = split(/\t/, $inaa);
		if ($array[6] > $array[9]) {
			$ref{"$array[0]\t$array[1]"} = 'post';
		}elsif ($array[6] < $array[9]) {
			$ref{"$array[0]\t$array[1]"} = 'trans';
		}else{
			$ref{"$array[0]\t$array[1]"} += 'same';
		}
	}
	close IN;
	return(\%ref);
}

sub tcgain {
	open IN, "$_[0]" or die "$_[0]";
	my $firstline = <IN>;
	my %ref;
	
	$ref{'post'} = 0;
	$ref{'trans'} = 0;
	$ref{'same'} = 0;
	
		
	while (my $inaa = <IN>) {
		$inaa =~ s/\r//g;
	
		chomp($inaa);
		my @array = split(/\t/, $inaa);
		if ($array[7] > $array[10]) {
			$ref{"$array[0]\t$array[1]"} = 'post';
		}elsif ($array[7] < $array[10]) {
			$ref{"$array[0]\t$array[1]"} = 'trans';
		}else{
			$ref{"$array[0]\t$array[1]"} += 'same';
		}
	}
	close IN;
	return(\%ref);

}