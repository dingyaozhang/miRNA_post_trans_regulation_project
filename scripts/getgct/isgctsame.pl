use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_r);
getopts('i:r:');

open IN, "$opt_i" or die;
open REF, "$opt_r" or die;

my $icols = `head $opt_i -n 1`;
my $rcols = `head $opt_r -n 1`;
my $irows = `cat $opt_i | cut -f 1`;
my $rrows = `cat $opt_r | cut -f 1`;
chomp($icols);
chomp($rcols);
chomp($irows);
chomp($rrows);

my @icols = split(/\t/, $icols);
my @rcols = split(/\t/, $rcols);
my @irows = split(/\n/, $irows);
my @rrows = split(/\n/, $rrows);

our %hash1;
our %hash2;


while (<IN>) {
	chomp($_);
	my @array1 = split(/\t/, $_);
	my $ref = <REF>;
	chomp($ref);
	my @array2 = split(/\t/, $ref);
	my $yy = 0;
	for my $var (@array1) {
		my $var2 = shift(@array2);
		#$var =~ s/\s//g;
		#$var2 =~ s/\s//g;
		my $xx = $. - 1;
		my $key1 = $irows[$xx]."\t".$icols[$yy];
		my $key2 = $rrows[$xx]."\t".$rcols[$yy];
		if (($var ne $var2) || ($key1 ne $key2)) {
			#print "$var\t$var2\t$yy\t$.\n";
			
			if (exists($hash1{$key1})) {
				die "fffffffffffffffffuck!1\t$key1\n";
			}else{
				$hash1{$key1} = $var;
			}
			if (exists($hash2{$key2})) {
				die "fffffffffffffffffuck!2\t$key2\n";
			}else{
				$hash2{$key2} = $var2;
			}
		}
		$yy += 1;
	}
	
}

while (<REF>) {
	die "refmore!!\n";
}

close IN;
close REF;


for my $var (keys(%hash1)) {
	my $hash1var = $hash1{$var};
	my $hash2var = $hash2{$var};
	print "pos1\t$var\t$hash1{$var}\t$hash2{$var}\n" if $hash1var ne $hash2var;
}

for my $var (keys(%hash2)) {
	my $hash1var = $hash1{$var};
	my $hash2var = $hash2{$var};
	print "pos2\t$var\n" if $hash1var ne $hash2var;
}
