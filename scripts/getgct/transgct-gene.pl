use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_r $opt_o);
getopts('i:o:r:');

open REF, "$opt_r" or die;
open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;


our %ref;
my %hash;
my %refc;

my $line1 = <REF>;
print "delete in ref. $line1";

while (<REF>) {
	chomp;
	my ($fileid, $sampleid) = (split(/\t/, $_))[0,6];
	if (exists($ref{$fileid})) {
		die "double samples\n";
	}

	if (exists($hash{$sampleid})) {
		my $previousfile = $hash{$sampleid};
		unless ($ref{$previousfile} =~ m/--/) {
			$ref{$previousfile} = $ref{$previousfile}."--$previousfile";
		}
		$ref{$fileid} = $sampleid."--$fileid";
	}else{
		$hash{$sampleid} = $fileid;
		$ref{$fileid} = $sampleid;
	}
	$refc{$fileid} += 1;

}

close REF;

my @matrix;


while (<IN>) {

	chomp;
	my @array = split(/\t/, $_);
	if ($. >= 3) {
		if (exists($ref{$array[0]})) {
			$array[0] = $ref{$array[0]};
		}else{
			die "$array[0]\n";
		}
		$refc{$array[0]} += 1;
		
	}else{
		my %temphash;
		my $therowname = $array[0];
		for my $var1 (@array) {
			if ($var1 =~ m/([0-9A-Z]+)([^0-9A-Z])(.+)/) {
				$var1 = $1;
				if (exists($temphash{$var1})) {
					die "double gene $var1\n";
				}else{
					$temphash{$var1} = 1;
				}
				
			}
		}
		$array[0] = $therowname;
		
	}
	push @matrix, [@array];

}


close IN;


for my $var (keys(%refc)) {
	if ($refc{$var} >= 2) {
		die "two files $var\n";
	}
}

my $genelength = scalar @{$matrix[0]};
my $samplelength = scalar @matrix;

for (my $var = 0; $var < $genelength; $var++) {
	my @array;
	push @array, $matrix[$_][$var] for 0..($samplelength-1);
	my $array = join("\t", @array);
	if ( ($array[0] =~ m/^ENSG/) or ($array[0] =~ m/^Name/) ) {
		print OUT "$array\n";
	}
	
}


close OUT;