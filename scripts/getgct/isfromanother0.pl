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

my @icols = split(/\s+/, $icols);
my @rcols = split(/\s+/, $rcols);
my @irows = split(/\s+/, $irows);
my @rrows = split(/\s+/, $rrows);

our %hash1;
our %hash2;

my %ref;
while (<REF>) {
	chomp($_);
	my @array2 = split(/\t/, $_);
	my $yy = 0;
	my $xx = $. - 1;
	for my $var (@array2) {
		my $rowname = $rrows[$xx];
		my $colname = $rcols[$yy];
		$ref{$rowname}{$colname} = $var;
		$yy += 1;

	}
	
}


while (<IN>) {
	chomp($_);
	my @array2 = split(/\t/, $_);
	my $yy = 0;
	my $xx = $. - 1;
	for my $var (@array2) {
		my $rowname = $irows[$xx];
		my $colname = $icols[$yy];
		if (exists($ref{$rowname}{$colname})) {
				my $refv = $ref{$rowname}{$colname};
				#print "$rowname\t$colname\t$ref{$rowname}{$colname}\n";
				die "wrong $rowname\t$colname\t$var\t$refv\n!!" if $refv ne $var; 
			}else{
				die "no have $rowname\t$colname\n";
			}
		$yy += 1;
	}
	
}


close IN;
close REF;
