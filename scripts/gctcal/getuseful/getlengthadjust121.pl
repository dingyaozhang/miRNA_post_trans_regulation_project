use strict;
use warnings;

use Getopt::Std;
use vars qw($opt_i $opt_l $opt_o $opt_p);
getopts('i:l:o:p');

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

while (<IN>) {

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

	my $printtwo;


	for my $one (@oneline) {
		$ii += 1;
		
		
		if ($ii == 1) {
			$printtwo = "$one";
		}elsif($ii == 2){
			$printtwo = "$printtwo\t$one";
		}else{
			my ($yi, $er) =  (split(/\//, $one))[0,1];
			push @yi, "$yi";
			push @er, "$er";
		}

			
	}
		

	print OUT "$printtwo";

	my $yii = 0;

	for my $yi (@yi) {
		
		my $er = $er[$yii];
		$er = $er / $genelength;
		my $output =  "$yi/$er";

		print OUT "\t$output";
		
		$yii += 1;
	}
	print OUT "\n";
}
close IN;
close OUT;


