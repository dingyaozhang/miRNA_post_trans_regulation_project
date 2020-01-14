use strict;
use warnings;
use Math::BigInt;

open IN, "result/gctcal/ratio121count.gct" or die;
open OUT, '>', "result/mechanism/evolution/boardgene.gct" or die;

my $firstline = <IN>;


LINE: while (<IN>) {

	chomp;
	my $zeronum = 0;
	my $sum = 0;
	my $sumvar = 0;
	my @array = split(/\t/, $_);
	my $mirone = shift(@array);
	my $geneone = shift(@array);

	
	
	for my $var (@array) {
		my $genevalue = (split(/\//, $var))[1];
		if ($genevalue < 8) {
			$zeronum += 1;
		}
	}
	
	print OUT "$mirone\t$geneone\t1\t$zeronum\n";

}

close IN;
close OUT;
