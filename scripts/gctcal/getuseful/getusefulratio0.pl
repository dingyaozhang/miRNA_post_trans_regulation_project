use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

use List::Util qw/max min/;

my %ref;
open REF, "data/gctcal/exons_gene_lens.txt" or die;
while (<REF>) {
	my ($name, $len) = (split(/\t/, $_))[0,1];
	$name =~ s/\..*//g;
	
	$ref{$name} = $len;
}
	


open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %hash;
my $firstline = <IN>;
$firstline =~ s/\r//g;
print OUT "$firstline";

LINE: while (<IN>) {

	$_ =~ s/\r//g;
	chomp;
	my @oneline = split(/\t/, $_);
	my $ii = 0;
	
	my $genename = $oneline[1];
	my $genelength;
	if (exists($ref{$oneline[1]})) {
		$genelength = $ref{$oneline[1]};
	}else{
		die "$oneline[1]\n";
	}
	
	my @yi;
	my @er;
	my $shouldfront;
	my $finalout = '';
	

	for my $one (@oneline) {
		$ii += 1;
		
		
		if ($ii == 1) {
			$finalout = $finalout."$one";
		}elsif($ii == 2){
			$finalout = $finalout."\t$one";
		}else{
			my ($yi, $er) =  (split(/\//, $one))[0,1];
			if (($yi == 0) || ($er == 0)) {
				next LINE;
			}
			my $output = $genelength * ( ($yi) / ($er));
			$finalout = $finalout."\t$output";
		}
		

	}


	print OUT "$finalout\n";
}
close IN;
close OUT;
